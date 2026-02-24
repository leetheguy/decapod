DROP TABLE IF EXISTS decapod_state CASCADE;

CREATE TABLE decapod_state (
  id SERIAL PRIMARY KEY,
  state_name VARCHAR(255) NOT NULL DEFAULT 'decapod',
  agent_name VARCHAR(255) NOT NULL DEFAULT 'decapod',
  working BOOLEAN DEFAULT FALSE,
  default_model VARCHAR(100) DEFAULT 'anthropic/claude-haiku-4.5',
  initial_session JSONB DEFAULT '{}',
  response_to_user JSONB DEFAULT '{}',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  -- Ensure one state per agent
  UNIQUE(agent_name, state_name)
);

-- Index for fast agent lookups
CREATE INDEX idx_decapod_state_agent 
ON decapod_state(agent_name);

-- Function to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Auto-update updated_at trigger (reuse function from job_queue)
CREATE TRIGGER update_decapod_state_updated_at 
BEFORE UPDATE ON decapod_state 
FOR EACH ROW 
EXECUTE FUNCTION update_updated_at_column();

-- Create a default state on table creation. Will work with default decapod structure.
INSERT INTO decapod_state DEFAULT VALUES;

-- Insert default states for agents
-- INSERT INTO decapod_state (state_name, agent_name, working, default_model)
-- VALUES ('light', 'scampi', FALSE, 'claude-haiku-4.5')
-- ON CONFLICT (agent_name, state_name) DO NOTHING;
-- INSERT INTO decapod_state (state_name, agent_name, working, default_model)
-- VALUES ('medium', 'rangoon', FALSE, 'claude-haiku-4.5')
-- ON CONFLICT (agent_name, state_name) DO NOTHING;
-- INSERT INTO decapod_state (state_name, agent_name, working, default_model)
-- VALUES ('heavy', 'etouffee', FALSE, 'claude-haiku-4.5')
-- ON CONFLICT (agent_name, state_name) DO NOTHING;