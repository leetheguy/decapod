#!/bin/bash
# Decapod - Stop All Services

# Get the absolute path of the script's directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "========================================"
echo "Stopping Decapod Services... 🦀💤"
echo "========================================"

echo "1. Obsidian Sync..."
docker compose -f "$PROJECT_ROOT/obsidian/docker-compose.yml" down

echo "2. Data Container (Dataguy)..."
docker compose -f "$PROJECT_ROOT/dataguy/docker-compose.yml" down

echo "2. File Storage (SFTPGo)..."
docker compose -f "$PROJECT_ROOT/sftpgo/docker-compose.yml" down

echo "2. Forms (Typebot)..."
docker compose -f "$PROJECT_ROOT/typebot/docker-compose.yml" down

echo "2. Chat Interface (Open WebUI)..."
docker compose -f "$PROJECT_ROOT/openwebui/docker-compose.yml" down

echo "3. Automation Engine (n8n)..."
docker compose -f "$PROJECT_ROOT/n8n/docker-compose.yml" down

echo "4. Infrastructure (Postgres, Caddy)..."
docker compose -f "$PROJECT_ROOT/infrastructure/docker-compose.yml" down

echo ""
echo "All services stopped."
echo "========================================"
