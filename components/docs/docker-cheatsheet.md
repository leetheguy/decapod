# Docker Cheatsheet

## Everyday Commands
```bash
# See what's running
docker ps

# See everything (including stopped)
docker ps -a

# Logs (live tail)
docker logs -f container_name

# Stop/start/restart
docker stop container_name
docker start container_name
docker restart container_name

# Remove container
docker rm container_name
docker rm -f container_name  # Force kill + remove
```

## Docker Compose
```bash
# Start everything (detached)
docker compose up -d

# Stop everything
docker compose down

# Rebuild and restart
docker compose up -d --build

# Update
docker compose pull

# View logs
docker compose logs -f
docker compose logs -f service_name

# Restart one service
docker compose restart service_name

# Stop but keep data
docker compose stop

# Nuclear option (removes volumes too)
docker compose down -v
```

## Networks
```bash
# Create shared network
docker network create web

# List networks
docker network ls

# See what's on a network
docker network inspect web
```

## Cleanup (When disk fills up)
```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune

# Nuclear cleanup (everything unused)
docker system prune -a --volumes
```

## Quick Checks
```bash
# Is container running?
docker ps | grep n8n

# What ports?
docker ps --format "table {{.Names}}\t{{.Ports}}"

# Jump into running container
docker exec -it container_name /bin/bash
# (or /bin/sh if bash doesn't exist)

# Check container resource usage
docker stats
```

## Oh Shit Moments
```bash
# Container won't stop
docker kill container_name

# Can't remove container
docker rm -f container_name

# Out of disk space
docker system prune -a --volumes

# Compose file changed, not picking it up
docker compose down && docker compose up -d --build
```
