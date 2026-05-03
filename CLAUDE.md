# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

**Decapod** is a self-hosted, Docker-based AI agent platform ("Hard Body, Soft Core"). The infrastructure provides secure, isolated services while AI agents are flexible and customizable. It combines n8n (visual workflow automation), Open WebUI (chat interface), PostgreSQL (state/persistence), and MinIO (S3-compatible storage for agent definitions).

## Common Commands

```bash
# Create the shared Docker network (one-time setup)
docker network create web
docker volume create n8n_data

# Start / stop all services
./scripts/start-all.sh
./scripts/stop-all.sh

# Check service status / logs (run from any service directory)
docker compose ps
docker compose logs -f

# Access Postgres
docker exec -it postgres psql -U postgres -d postgres

# Reload Caddy config without restart
docker exec caddy caddy reload --config /etc/caddy/Caddyfile

# Sync agent definitions to MinIO (WARNING: completely replaces bucket contents)
./scripts/upload_S3_structure.sh

# Create a new agent interactively
npm run create-agent
```

There are no automated tests. Verification is manual via logs, the n8n workflow debugger, and the Open WebUI chat interface.

## Architecture

All services communicate over a shared external Docker network named `web`, using container names as hostnames (e.g., `postgres:5432`, `n8n:5678`).

**Request flow for a user message:**
1. User sends message in Open WebUI → Caddy (reverse proxy/TLS) → n8n API middleware workflow
2. n8n middleware creates a job, worker workflow picks it up
3. Worker loads the agent's definition from MinIO (S3), constructs message history from `decapod_state`, calls Claude API
4. Claude returns tool calls → n8n routes them to skill sub-workflows → results returned to Claude
5. Final response streamed back to Open WebUI

**Key services:**

| Container | Port | Purpose |
|---|---|---|
| `caddy` | 80/443 | Reverse proxy, automatic HTTPS |
| `postgres` | 5432 | Shared DB (state, agents, job queue) |
| `n8n` | 5678 (internal) | Workflow engine; all agent logic lives here |
| `openwebui` | 8080 | Chat interface |
| `minio` | 9000/9001 | Object storage for agent definitions |
| `sandbox` | 2222 (SSH) | Unprivileged Ubuntu 24.04 container for code execution |
| `streamer` | 3000 | Custom streaming service |

## Database Schema

Core tables in PostgreSQL (defined in [components/pgsql_tables/schema.sql](components/pgsql_tables/schema.sql)):

- **`agents`** — Agent definitions (name, `model_name`, `model_source` — defaults to OpenRouter API URL)
- **`instructions`** — Skills and system prompts (`is_skill` boolean distinguishes them; `phase` controls load order)
- **`agent_instructions`** — M2M junction linking agents to their enabled instructions/skills
- **`tools`** — Tool JSON schemas for Claude (JSONB column)
- **`decapod_state`** — Per-session state (`agent_id`, `current_model`, `message_history` JSONB, `tools` JSONB)
- **`agent_logs`** — Audit trail of agent actions (event_type, payload, duration_ms)
- **`job_queue`** — Async job processing with suspend/resume support

Seed files (`seed_*.sql`) populate initial agents, instructions, and tools.

## Agent Structure (in MinIO/S3)

Agents live under `components/S3_structure/agents/{agent-name}/` and are uploaded to MinIO:

```
agents/{name}/
├── definitions/
│   ├── 1_instructions.md   # System prompt
│   ├── 2_skills.yaml       # YAML list of enabled skills
│   ├── 4_persona.md        # Personality
│   └── 5_user.md           # User-specific context
└── skills/
    └── {skill-name}.md     # Skill docs with embedded JSON spec
```

Skills are Markdown files with YAML frontmatter and a `specs:` JSON block defining parameters. The `2_skills.yaml` file for each agent lists which skills are active. The `template/` directory is the canonical reference for new agents. `components/S3_structure/system/agent_roster.json` lists all active agents.

## n8n Workflows

Core workflows live in `components/n8n_workflows/` (JSON files imported into n8n):

- `1_start_here_api_middleware.json` — Entry point; receives API calls, creates jobs
- `worker.json` — Main AI loop; loads agent, calls Claude, executes tools
- `construct_message_history.json` — Builds conversation context from DB
- `ai_tool_router.json` — Routes tool calls to skill sub-workflows
- `get_job_queue.json` — Polls for pending jobs

## Configuration

- Each service directory has a `.env.example`; copy to `.env` and fill in values
- Caddy config: copy `infrastructure/caddy_config/Caddyfile.template` → `Caddyfile`, set domain names
- The `Caddyfile` and all `.env` files are gitignored
- Passwords: use only letters and numbers to avoid shell parsing issues with Docker env vars
- The `n8n_data` volume must be created externally (`docker volume create n8n_data`) before first run
- n8n uses a custom Dockerfile (`n8n/Dockerfile`) that adds the `yamljs` npm package — required for YAML parsing in workflows; account for this when upgrading the n8n image version
