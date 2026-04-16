# Decapod - Agent Development Guide

## Project Overview

Decapod is a Docker-based personal AI assistant platform designed as a safer alternative to cloud-based AI services. It provides a self-hosted infrastructure with workflow automation (n8n), AI chat interface (Open WebUI), object storage (MinIO), and a sandboxed execution environment.

**Key Philosophy**: "Hard Body, Soft Core" - The infrastructure is secure and isolated (hard shell), while the AI agents are flexible and customizable (soft core).

---

## Technology Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Reverse Proxy** | Caddy | Automatic HTTPS, request routing |
| **Database** | PostgreSQL | Shared state and job queue storage |
| **Workflow Engine** | n8n | Visual workflow automation, AI tool routing |
| **Chat Interface** | Open WebUI | AI conversation frontend |
| **Object Storage** | MinIO | S3-compatible storage for agent files |
| **Sandbox** | Ubuntu 24.04 + SSH | Isolated execution environment |
| **Database GUI** | NocoDB | Optional Postgres management interface |
| **CLI Tools** | Node.js + bash | Agent generation, deployment scripts |

---

## Project Structure

```
decapod_servers/
├── infrastructure/          # Caddy reverse proxy + PostgreSQL
│   ├── docker-compose.yml
│   ├── .env.example
│   └── caddy_config/
│       ├── Caddyfile.template   # Template for reverse proxy config
│       └── Caddyfile            # Generated config (gitignored)
│
├── n8n/                     # Workflow automation service
│   ├── docker-compose.yml
│   ├── Dockerfile           # Custom image with yamljs package
│   ├── .env.example
│   └── local_files/         # Mounted volume for file operations
│
├── openwebui/               # AI chat interface
│   ├── docker-compose.yml
│   └── .env.example
│
├── minio/                   # S3-compatible object storage
│   ├── docker-compose.yml
│   └── .env.example
│
├── nocodb/                  # Database management UI (optional)
│   ├── docker-compose.yml
│   └── .env.example
│
├── sandbox/                 # SSH sandbox container
│   ├── docker-compose.yml
│   ├── Dockerfile
│   └── .env.example
│
├── scripts/                 # Utility scripts
│   ├── create-agent.mjs     # Interactive agent generator
│   ├── start-all.sh         # Start all services
│   ├── stop-all.sh          # Stop all services
│   └── upload_S3_structure.sh  # Sync agent files to MinIO
│
├── components/              # Application data and configurations
│   ├── S3_structure/        # Agent definitions stored in S3
│   │   ├── agents/          # Agent configurations
│   │   │   ├── template/    # Template for new agents
│   │   │   │   ├── definitions/   # Agent instructions, skills, persona
│   │   │   │   │   ├── 1_instructions.md
│   │   │   │   │   ├── 2_skills.yaml
│   │   │   │   │   ├── 3_onboarding/
│   │   │   │   │   ├── 4_persona.md
│   │   │   │   │   └── 5_user.md
│   │   │   │   └── skills/  # Individual skill documentation
│   │   │   └── decapod/     # Default agent instance
│   │   └── system/tools/tools.json  # Tool definitions
│   ├── n8n_workflows/       # Exported n8n workflow JSON files
│   ├── pgsql_tables/        # Database schema definitions
│   └── docs/                # Additional documentation
│
├── package.json             # Node.js dependencies for scripts
├── README.md                # User-facing documentation
├── CONTRIBUTING.md          # Contribution guidelines
└── LICENSE                  # MIT License
```

---

## Architecture

### Network Topology

All services communicate via an external Docker network named `web`:

```
┌─────────────────────────────────────────────────────────────┐
│                         Docker Network: web                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │  Caddy   │  │  n8n     │  │ OpenWebUI│  │  MinIO   │    │
│  │  (:80)   │  │ (:5678)  │  │ (:8080)  │  │(:9000/1) │    │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘    │
│       │             │             │             │           │
│  ┌────┴─────┐  ┌────┴─────┐  ┌────┴─────┐  ┌────┴─────┐    │
│  │ Postgres │  │ Sandbox  │  │  NocoDB  │  │          │    │
│  │ (:5432)  │  │  (:22)   │  │ (:8080)  │  │          │    │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **User Request**: Open WebUI → Caddy → n8n (API middleware workflow)
2. **Tool Execution**: n8n → S3 (read skills) → Execute → Postgres (save state)
3. **File Operations**: n8n → MinIO (S3) for persistent storage
4. **Sandbox Execution**: n8n → SSH → Sandbox container for code execution

---

## Configuration

### Environment Files

Each service has its own `.env` file (created from `.env.example`):

| Service | Key Variables |
|---------|---------------|
| `infrastructure/.env` | `DATA_FOLDER`, `DOMAIN_NAME`, `SSL_EMAIL`, `POSTGRES_*` |
| `n8n/.env` | `SUBDOMAIN`, `N8N_LICENSE_ACTIVATION_KEY`, `DATA_FOLDER` |
| `openwebui/.env` | `POSTGRES_*`, `MINIO_*`, `S3_*` |
| `minio/.env` | `MINIO_ROOT_USER`, `MINIO_ROOT_PASSWORD` |
| `nocodb/.env` | `SUBDOMAIN`, `NOCODB_*` |
| `sandbox/.env` | `AGENT_PASSWORD` |
| `scripts/.env` | `MINIO_ENDPOINT`, `MINIO_ACCESS_KEY`, `MINIO_SECRET_KEY` |

### Caddyfile Setup

1. Copy template: `cp infrastructure/caddy_config/Caddyfile.template infrastructure/caddy_config/Caddyfile`
2. Edit `Caddyfile` - replace `example.com` with your domain
3. Configure DNS A records for subdomains (n8n, owui, s3, etc.)

---

## Build and Deployment

### Prerequisites

- Docker and Docker Compose installed
- Docker network `web` created: `docker network create web`

### Starting Services

```bash
# Option 1: Use the start script
./scripts/start-all.sh

# Option 2: Manual startup (in order)
cd infrastructure && docker compose up -d
cd ../minio && docker compose up -d
cd ../n8n && docker compose up -d
cd ../openwebui && docker compose up -d
```

### Stopping Services

```bash
# Option 1: Use the stop script
./scripts/stop-all.sh

# Option 2: Manual shutdown (reverse order)
cd openwebui && docker compose down
cd ../n8n && docker compose down
cd ../minio && docker compose down
cd ../infrastructure && docker compose down
```

### Creating New Agents

```bash
# Run the interactive agent generator
npm run create-agent

# Follow prompts to:
# 1. Enter agent name
# 2. Select skills from template
# 3. Generate agent configuration in components/S3_structure/agents/
```

### Syncing Agent Files to S3

```bash
# Upload all agent definitions to MinIO
./scripts/upload_S3_structure.sh

# Or with explicit credentials:
./scripts/upload_S3_structure.sh http://localhost:9000 minioadmin changeme
```

**Warning**: This script completely replaces the S3 bucket contents with local files.

---

## Agent Structure

Agents are defined in `components/S3_structure/agents/` with this structure:

```
agents/{agent-name}/
├── definitions/
│   ├── 1_instructions.md    # System instructions for the agent
│   ├── 2_skills.yaml        # List of available skills
│   ├── 3_onboarding/        # Onboarding conversation flow
│   ├── 4_persona.md         # Personality definition
│   └── 5_user.md            # User-specific context
└── skills/
    ├── {skill-name}.md      # Individual skill documentation
    └── ...
```

### Skill File Format

Skills are Markdown files with YAML frontmatter:

```markdown
---
name: skill-name
description: What this skill does
---

# Skill Documentation

## Purpose
Description of the skill's functionality.

## Parameters
- `param1` (required): Description
- `param2` (optional): Description

## Usage
How to use this skill.

specs:
```json
{
  "param1": { "type": "string", "required": true },
  "param2": { "type": "number", "required": false }
}
```
```

### Skills YAML Format

```yaml
skills:
  - name: skill-name
    description: Brief description
    location: /skills/skill-name.md
```

---

## Database Schema

### decapod_state Table

Stores agent conversation state and configuration:

```sql
CREATE TABLE decapod_state (
  id SERIAL PRIMARY KEY,
  state_name VARCHAR(255) NOT NULL DEFAULT 'decapod',
  agent_name VARCHAR(255) NOT NULL DEFAULT 'decapod',
  default_model VARCHAR(100) DEFAULT 'anthropic/claude-haiku-4.5',
  current_model VARCHAR(100) DEFAULT '',
  message_history JSONB DEFAULT '[]',
  tools JSONB DEFAULT '[]',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(agent_name, state_name)
);
```

### job_queue Table

Manages asynchronous job processing:

```sql
CREATE TABLE job_queue (
  id SERIAL PRIMARY KEY,
  job_name VARCHAR(255),
  job_description TEXT,
  job_tasks TEXT[],
  agent_name VARCHAR(255),
  state_id INTEGER REFERENCES decapod_state(id),
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
```

---

## Development Conventions

### Code Style

- **Shell Scripts**: Use `set -euo pipefail` for safety
- **Node.js Scripts**: ES modules (`.mjs`), async/await pattern
- **Docker Compose**: Always specify `container_name` for clarity
- **Environment Variables**: Use `.env.example` as templates, never commit secrets

### File Naming

- Agent definitions: Numbered prefix for ordering (`1_instructions.md`, `2_skills.yaml`)
- SQL files: Descriptive names with `.sql` extension
- Workflow files: Descriptive names with `.json` extension

### Git Practices

The `.gitignore` excludes:
- All `.env` files (except `.env.example`)
- Generated `Caddyfile` (keep `Caddyfile.template`)
- Data directories and volumes
- Backup files and logs
- `node_modules/`

### Security Considerations

1. **Never commit secrets** - Use `.env` files (gitignored)
2. **Use safe password characters** - Letters and numbers only to avoid shell parsing issues
3. **Sandbox resource limits** - CPU: 2 cores, Memory: 4GB max
4. **SSH access** - Sandbox uses password auth (configured via `AGENT_PASSWORD`)
5. **Network isolation** - All services on internal `web` network

---

## Testing

There are no automated test suites in this project. Testing is done via:

1. **Manual verification** - Start services and check endpoints
2. **Docker logs** - `docker compose logs -f`
3. **n8n workflow testing** - Use n8n's built-in workflow testing
4. **Database queries** - Connect to Postgres and verify data

---

## Troubleshooting

### Common Commands

```bash
# Check service status
docker compose ps
docker ps

# View logs
docker compose logs -f
docker logs [container-name]

# Network inspection
docker network inspect web

# Database connection
docker exec -it postgres psql -U postgres -d postgres

# Caddy reload
docker exec caddy caddy reload --config /etc/caddy/Caddyfile
```

### Common Issues

- **Port conflicts**: Check `docker ps` for port usage
- **Missing .env files**: Copy from `.env.example` and configure
- **DNS issues**: Verify A records point to server IP
- **Permission denied**: Check volume ownership (UID/GID 1000)

---

## n8n Workflows

Key workflows in `components/n8n_workflows/`:

| Workflow | Purpose |
|----------|---------|
| `1_start_here_api_middleware.json` | Main API entry point, intercepts AI calls |
| `worker.json` | Processes jobs from the job queue |
| `construct_message_history.json` | Builds conversation context |
| `ai_tool_router.json` | Routes tool calls to appropriate handlers |
| `get_job_queue.json` | Retrieves pending jobs |
| `send_hitl_yes_no_request.json` | Human-in-the-loop confirmation |

Import these into n8n via Settings → Workflows → Import.

---

## License

MIT License - See `LICENSE` file for details.

By contributing, you agree to the Contributor License Agreement in `CONTRIBUTING.md`.
