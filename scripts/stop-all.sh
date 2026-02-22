#!/bin/bash
# Decapod - Stop All Services

# Get the absolute path of the script's directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "========================================"
echo "Stopping Decapod Services... 🦀💤"
echo "========================================"

echo "1. Chat Interface (Open WebUI)..."
docker compose -f "$PROJECT_ROOT/openwebui/docker-compose.yml" down

echo "2. Automation Engine (n8n)..."
docker compose -f "$PROJECT_ROOT/n8n/docker-compose.yml" down

echo "3. Object Storage (MinIO)..."
docker compose -f "$PROJECT_ROOT/minio/docker-compose.yml" down

echo "4. Infrastructure (Postgres, Caddy)..."
docker compose -f "$PROJECT_ROOT/infrastructure/docker-compose.yml" down

echo ""
echo "All services stopped."
echo "========================================"
