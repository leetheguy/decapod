#!/usr/bin/env node

import fs from 'fs';
const logFile = '/app/logs/streamer.log';
try { fs.mkdirSync('/app/logs', { recursive: true }); } catch(e) {}
function log(...args) { const msg = args.join(' '); console.log(msg); fs.appendFileSync(logFile, new Date().toISOString() + ' ' + msg + '\n'); }

/**
 * Streamer - OpenAI-compatible streaming middleware for Decapod
 * 
 * POST /v1/decapod/chat/completions - Proxies to n8n init, returns stream
 * POST /stream - Adds message to existing stream (called by Decapod)
 * POST /stop - Adds final message and closes stream (called by Decapod)
 */

import express from 'express';
import cors from 'cors';

const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));

const PORT = process.env.PORT || 3000;
const N8N_BASE_URL = process.env.N8N_BASE_URL || 'http://n8n:5678';
const N8N_INIT_WEBHOOK = `${N8N_BASE_URL}/webhook/v1/decapod/init`;
const N8N_MODELS_WEBHOOK = `${N8N_BASE_URL}/webhook/v1/decapod/models`;

// Store active streams by id
const streams = new Map();

/**
 * Build OpenAI-compatible chunk
 */
function buildChunk(id, content, finishReason = null) {
  return {
    id: `stream-${id}`,
    object: 'chat.completion.chunk',
    created: Math.floor(Date.now() / 1000),
    model: 'streamer',
    choices: [{
      index: 0,
      delta: content ? { content, role: 'assistant' } : {},
      finish_reason: finishReason
    }]
  };
}

/**
 * GET /v1/decapod/models
 * Passthrough to n8n models endpoint
 */
app.get('/v1/decapod/models', async (req, res) => {
  log(`[Streamer] Proxying models request to n8n`);

  try {
    const response = await fetch(N8N_MODELS_WEBHOOK, {
      method: 'GET',
      headers: {
        'Authorization': req.headers.authorization || '',
        'Accept': 'application/json'
      }
    });

    const data = await response.json();
    res.status(response.status).json(data);

  } catch (error) {
    log("ERROR:", '[Streamer] Error proxying models:', error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * POST /v1/decapod/chat/completions
 * Main entry point - proxies to n8n init, starts stream
 */
app.post('/v1/decapod/chat/completions', async (req, res) => {
  const body = req.body;
  const headers = req.headers;

  log(`[Streamer] Received request for decapod`);

  // Always set up SSE headers first - we ONLY stream
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');

  let id = null;

  try {
    // Call n8n init webhook with verbatim request
    const initResponse = await fetch(N8N_INIT_WEBHOOK, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': headers.authorization || '',
        'X-Request-ID': headers['x-request-id'] || ''
      },
      body: JSON.stringify(body)
    });

    if (!initResponse.ok) {
      const error = await initResponse.text();
      log("ERROR:", `[Streamer] Init failed: ${error}`);
      // Stream the error and close
      const errorChunk = buildChunk('error', `Init failed: ${error}`, 'stop');
      res.write(`data: ${JSON.stringify(errorChunk)}\n\n`);
      res.write('data: [DONE]\n\n');
      res.end();
      return;
    }

    let initData = await initResponse.json();
    log('[Streamer] Init response:', JSON.stringify(initData));
    // Handle array response from n8n
    if (Array.isArray(initData) && initData.length > 0) {
      initData = initData[0];
    }
    id = initData.id || initData.state_id;

    if (!id) {
      log("ERROR:", '[Streamer] No id returned from init. Response was:', JSON.stringify(initData));
      // Stream the error and close
      const errorChunk = buildChunk('error', 'No stream ID returned from init', 'stop');
      res.write(`data: ${JSON.stringify(errorChunk)}\n\n`);
      res.write('data: [DONE]\n\n');
      res.end();
      return;
    }

    if (streams.has(id)) {
      log("ERROR:", `[Streamer] Stream ${id} already exists`);
      // Stream the error and close
      const errorChunk = buildChunk(id, 'Stream already exists', 'stop');
      res.write(`data: ${JSON.stringify(errorChunk)}\n\n`);
      res.write('data: [DONE]\n\n');
      res.end();
      return;
    }

    streams.set(id, res);
    
    log(`[Streamer] Started stream: ${id} for decapod`);

    // Set 10-minute timeout
    const timeout = setTimeout(() => {
      if (streams.get(id) === res) {
        log(`[Streamer] Timeout for stream: ${id}`);
        const timeoutChunk = buildChunk(id, 'Stream timed out after 10 minutes', 'stop');
        res.write(`data: ${JSON.stringify(timeoutChunk)}\n\n`);
        res.write('data: [DONE]\n\n');
        res.end();
        streams.delete(id);
      }
    }, 10 * 60 * 1000); // 10 minutes

    // Handle connection close
    res.on('close', () => {
      clearTimeout(timeout);
      if (streams.get(id) === res) {
        streams.delete(id);
        log(`[Streamer] Client disconnected: ${id}`);
      }
    });

  } catch (error) {
    log("ERROR:", '[Streamer] Error:', error);
    // Stream the error and close
    const errorChunk = buildChunk(id || 'error', `Error: ${error.message}`, 'stop');
    res.write(`data: ${JSON.stringify(errorChunk)}\n\n`);
    res.write('data: [DONE]\n\n');
    res.end();
  }
});

/**
 * POST /stream
 * Body: { id: number, message: string }
 * Adds message to existing stream (called by Decapod)
 */
app.post('/stream', (req, res) => {
  const { id, message } = req.body;

  if (id === undefined || id === null) {
    return res.status(400).json({ error: 'id required' });
  }

  if (typeof message !== 'string') {
    return res.status(400).json({ error: 'message must be a string' });
  }

  const stream = streams.get(id);
  if (!stream) {
    return res.status(404).json({ error: 'stream not found' });
  }

  // Write message as OpenAI-compatible chunk
  const chunk = buildChunk(id, message);
  stream.write(`data: ${JSON.stringify(chunk)}\n\n`);
  if (stream.flush) stream.flush();
  log(`[Streamer] Streamed to: ${id}`);
  
  res.json({ status: 'ok', id });
});

/**
 * POST /stop
 * Body: { id: number, message: string }
 * Adds final message and closes stream (called by Decapod)
 */
app.post('/stop', (req, res) => {
  const { id, message } = req.body;

  if (id === undefined || id === null) {
    return res.status(400).json({ error: 'id required' });
  }

  const stream = streams.get(id);
  if (!stream) {
    return res.status(404).json({ error: 'stream not found' });
  }

  // Write final message chunk with finish_reason if message provided
  if (typeof message === 'string' && message) {
    const chunk = buildChunk(id, message, 'stop');
    stream.write(`data: ${JSON.stringify(chunk)}\n\n`);
    if (stream.flush) stream.flush();
  }
  
  // Send [DONE]
  stream.write('data: [DONE]\n\n');
  if (stream.flush) stream.flush();
  stream.end();
  streams.delete(id);
  
  log(`[Streamer] Stopped stream: ${id}`);
  res.json({ status: 'closed', id });
});

/**
 * GET /health
 */
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    active_streams: streams.size,
    stream_ids: Array.from(streams.keys()),
    timestamp: new Date().toISOString() 
  });
});

app.listen(PORT, '0.0.0.0', () => {
  log(`[Streamer] Running on port ${PORT}`);
  log(`[Streamer] GET /v1/decapod/models to list models`);
  log(`[Streamer] POST /v1/decapod/chat/completions to start`);
  log(`[Streamer] POST /stream to add, POST /stop to close`);
  log(`[Streamer] n8n init webhook: ${N8N_INIT_WEBHOOK}`);
  log(`[Streamer] n8n models webhook: ${N8N_MODELS_WEBHOOK}`);
});
