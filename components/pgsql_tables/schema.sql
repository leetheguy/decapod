-- Decapod Database Schema
-- Generated 2026-03-22

-- agents
CREATE TABLE IF NOT EXISTS agents (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  model_name TEXT NOT NULL,
  model_source TEXT NOT NULL DEFAULT 'https://openrouter.ai/api/v1/',
  notes TEXT,
  archived BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  tags TEXT[] DEFAULT '{}'
);

-- instructions
CREATE TABLE IF NOT EXISTS instructions (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  is_skill BOOLEAN NOT NULL DEFAULT false,
  is_default BOOLEAN NOT NULL DEFAULT false,
  phase NUMERIC NOT NULL DEFAULT 0,
  version INTEGER NOT NULL DEFAULT 1,
  archived BOOLEAN NOT NULL DEFAULT false,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  tags TEXT[] DEFAULT '{}'
);

-- agent_instructions
CREATE TABLE IF NOT EXISTS agent_instructions (
  agent_id INTEGER NOT NULL,
  instruction_id INTEGER NOT NULL
);

-- tools
CREATE TABLE IF NOT EXISTS tools (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  tool JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- decapod_state
CREATE TABLE IF NOT EXISTS decapod_state (
  id SERIAL PRIMARY KEY,
  agent_name VARCHAR NOT NULL DEFAULT 'decapod',
  current_model VARCHAR DEFAULT 'anthropic/claude-haiku-4-5',
  message_history JSONB NOT NULL DEFAULT '[]',
  tools JSONB NOT NULL DEFAULT '[]',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  archived BOOLEAN DEFAULT false,
  agent_id INTEGER
);

-- agent_logs
CREATE TABLE IF NOT EXISTS agent_logs (
  id SERIAL PRIMARY KEY,
  state_id INTEGER REFERENCES decapod_state(id),
  agent_id INTEGER,
  event_type VARCHAR NOT NULL,
  summary TEXT,
  payload JSONB,
  duration_ms INTEGER,
  archived BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- job_queue
CREATE TABLE IF NOT EXISTS job_queue (
  id SERIAL PRIMARY KEY,
  job_name VARCHAR,
  job_description TEXT,
  job_tasks TEXT[],
  agent_name VARCHAR,
  state_id INTEGER,
  suspended BOOLEAN DEFAULT false,
  suspended_by_agent BOOLEAN DEFAULT false,
  suspended_reason TEXT,
  tool_message_history JSONB DEFAULT '[]',
  priority INTEGER DEFAULT 0,
  notes TEXT,
  complete BOOLEAN DEFAULT false,
  archived BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);
