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

echo "2. Object Storage (MinIO)..."
docker compose -f "$PROJECT_ROOT/minio/docker-compose.yml" up -d

echo "3. Automation Engine (n8n)..."
docker compose -f "$PROJECT_ROOT/n8n/docker-compose.yml" up -d

echo "4. Chat Interface (Open WebUI)..."
docker compose -f "$PROJECT_ROOT/openwebui/docker-compose.yml" up -d

echo ""
echo "All services are up! Check your domains for availability."
echo "========================================"
