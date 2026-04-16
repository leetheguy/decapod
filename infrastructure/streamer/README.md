# Streamer

OpenAI-compatible streaming middleware for Decapod. Handles SSE streams between n8n and clients (like Open WebUI).

## Overview

Streamer sits between clients and n8n to manage streaming responses:
- Client calls streamer → streamer calls n8n init → stream starts
- n8n/Decapod calls `/stream` to add messages
- n8n/Decapod calls `/stop` to close the stream

## Endpoints

### Client Endpoints (called by OWUI/client)

#### List Models
```
GET http://streamer:3000/v1/decapod/models
```
Proxies to: `http://n8n:5678/webhook/v1/decapod/models`

#### Chat Completions (Streaming)
```
POST http://streamer:3000/v1/decapod/chat/completions
```
Starts an SSE stream. Calls n8n init webhook, returns stream to client.

**Request Body:** OpenAI-compatible chat completion request
```json
{
  "model": "moonshotai/kimi-k2",
  "messages": [{"role": "user", "content": "Hello"}],
  "stream": true
}
```

**Response:** SSE stream with OpenAI-compatible chunks

### n8n/Decapod Endpoints (called by your workflow)

#### Add Message to Stream
```
POST http://streamer:3000/stream
```

**Request Body:**
```json
{
  "id": 123,
  "message": "Hello from Decapod!"
}
```

#### Stop Stream
```
POST http://streamer:3000/stop
```

**Request Body:**
```json
{
  "id": 123,
  "message": "Final message"
}
```

Sends final chunk with `finish_reason: "stop"` and `[DONE]`, then closes stream.

### Health Check
```
GET http://streamer:3000/health
```

## n8n Webhook Requirements

You need to create these webhooks in n8n:

### GET /webhook/v1/decapod/models
Returns available models (passthrough to your model provider or static list).

### POST /webhook/v1/decapod/init
Called when a new stream starts. Must return:
```json
{
  "id": 123,
  "message": "Optional initial message"
}
```

The `id` is used for all subsequent `/stream` and `/stop` calls.

## Example n8n Flow

1. **Webhook trigger** (`/webhook/v1/decapod/init`) receives request
2. Generate unique ID (e.g., `Date.now()`)
3. Return `{id, message: "Thinking..."}`
4. Call LLM (OpenRouter, etc.)
5. As chunks arrive, call `POST http://streamer:3000/stream` with each chunk
6. When LLM finishes, call `POST http://streamer:3000/stop` with final message

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3000` | Server port |
| `N8N_BASE_URL` | `http://n8n:5678` | Base URL for n8n webhooks |

## Timeout

Streams automatically timeout after 10 minutes with an error message to the client.

## Logs

Logs are written to:
- Console (docker logs)
- `/app/logs/streamer.log` (inside container)
