DROP TABLE IF EXISTS decapod_state CASCADE;

CREATE TABLE decapod_state (
  id               SERIAL PRIMARY KEY,
  agent_name       VARCHAR(255) NOT NULL DEFAULT 'decapod',
  current_model    VARCHAR(100) DEFAULT 'anthropic/claude-haiku-4-5',
  message_history  JSONB NOT NULL DEFAULT '[]',
  tools            JSONB NOT NULL DEFAULT '[]',
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_decapod_state_agent ON decapod_state(agent_name);

CREATE TRIGGER update_decapod_state_updated_at
  BEFORE UPDATE ON decapod_state
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();