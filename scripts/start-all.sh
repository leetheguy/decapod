#!/bin/bash
# Decapod - Start All Services

# Get the absolute path of the script's directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "========================================"
echo "Starting Decapod Services... 🦀🚀"
echo "========================================"

echo "1. Infrastructure (Postgres, Caddy)..."
docker compose -f "$PROJECT_ROOT/infrastructure/docker-compose.yml" up -d

echo "2. Automation Engine (n8n)..."
docker compose -f "$PROJECT_ROOT/n8n/docker-compose.yml" up -d

echo "3. Chat Interface (Open WebUI)..."
docker compose -f "$PROJECT_ROOT/openwebui/docker-compose.yml" up -d

echo "4. Forms (Typebot)..."
docker compose -f "$PROJECT_ROOT/typebot/docker-compose.yml" up -d

echo "5. File Storage (SFTPGo)..."
docker compose -f "$PROJECT_ROOT/sftpgo/docker-compose.yml" up -d

echo "6. Data Container (Dataguy)..."
docker compose -f "$PROJECT_ROOT/dataguy/docker-compose.yml" up -d

echo "7. Obsidian Sync..."
docker compose -f "$PROJECT_ROOT/obsidian/docker-compose.yml" up -d

echo ""
echo "All services are up! Check your domains for availability."
echo "========================================"
