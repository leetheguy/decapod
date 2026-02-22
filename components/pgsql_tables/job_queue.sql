DROP TABLE IF EXISTS job_queue CASCADE;

CREATE TABLE job_queue (
  id SERIAL PRIMARY KEY,
  job_name VARCHAR(255),
  job_description TEXT,
  job_tasks TEXT[],
  agent_name VARCHAR(255),
  state_id INTEGER REFERENCES decapod_state(id) ON DELETE SET NULL,
  suspended BOOLEAN DEFAULT FALSE,
  suspended_by_agent BOOLEAN DEFAULT FALSE,
  suspended_reason TEXT,
  tool_message_history JSONB DEFAULT '[]'::jsonb,
  priority INTEGER DEFAULT 0,
  notes TEXT,
  complete BOOLEAN DEFAULT FALSE,
  archived BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Index for worker query (priority desc, created_at asc)
CREATE INDEX idx_job_queue_priority_created 
ON job_queue(priority DESC, created_at ASC) 
WHERE complete = FALSE AND archived = FALSE;

-- Index for filtering active jobs
CREATE INDEX idx_job_queue_active 
ON job_queue(complete, archived, suspended);

-- Index for foreign key lookups
CREATE INDEX idx_job_queue_state_id 
ON job_queue(state_id);

-- Function to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at on any change
CREATE TRIGGER update_job_queue_updated_at 
BEFORE UPDATE ON job_queue 
FOR EACH ROW 
EXECUTE FUNCTION update_updated_at_column();
