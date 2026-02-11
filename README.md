# Decapod

Decapod was created as a saner, safer alternative to [Open Claw](https://www.clawd.bot/) (an AI assistant platform).

## Key Features

- **No root access** - Runs with minimal privileges
- **No sharing API keys** - Keep your credentials secure
- **Double sandboxed** - Enhanced security isolation
- **Battle tested toolbox** - Built on enterprise ready software
- **Mature front end UI** - Uses Open Web UI, or bring your own front end
- **Mature back end tools** - Everything is done in n8n, a visual low-code tool builder
- **More than 1000 safe, sanitized integrations** - Extensive n8n integration/node ecosystem

## Design Approach

Decapod is the Ikea furniture approach to running your own personal agent. All the pieces are in the box, but you have to assemble them yourself. That means a little more work, but also a lot more flexibility. This approach makes the entire system completely transparent. And n8n's visual interface means that you can modify your bot anyway you want with little or no code. 

---

Decapod - Hard Body, Soft Core
💖🦀🦞🦐💖

---

## Overview

**Purpose**: Centralized Docker-based service infrastructure  
**Network**: All services share the `web` Docker network for easy inter-service communication

---

## Quick Start



```bash
# Clone the repository
git clone https://github.com/leetheguy/decapod.git
cd decapod

# Create the shared Docker network
docker network create web

# Set up environment variables
# Copy .env.example files and configure them (see Configuration section)

# Start infrastructure first (Caddy + Postgres)
cd infrastructure
docker compose up -d

# Start other services
cd ../n8n
docker compose up -d

cd ../openwebui
docker compose up -d

# View logs
docker compose logs -f

# Stop a service
docker compose down
```

---

## Directory Structure

```
decapod_servers/
├── infrastructure/             # Caddy reverse proxy + Postgres database
│   ├── docker-compose.yml
│   ├── .env.example
│   └── caddy_config/
│       ├── Caddyfile.template  # Template with env variables (edit this)
│       └── Caddyfile           # To be copied from template (gitignored)
├── n8n/                        # Workflow automation
│   ├── docker-compose.yml
│   ├── .env.example
│   └── local_files/
├── openwebui/                  # AI frontend interface
│   ├── docker-compose.yml
│   └── .env.example
└── minio/                      # S3-compatible object storage (direct access)
    ├── docker-compose.yml
    └── .env.example
```

---

## Services Overview

| Service | Domain/Port | Network | Description |
|---------|-------------|---------|-------------|
| **Caddy** | 80, 443 | `web` | Reverse proxy with automatic HTTPS (Let's Encrypt) |
| **Postgres** | 5432 | `web` | Shared database server (accessible from host) |
| **n8n** | n8n.yourdomain.com | `web` | Workflow automation platform |
| **Open WebUI** | owui.yourdomain.com | `web` | AI chat interface (connected to Postgres) |
| **Minio** | 9000 (API), 9001 (Console) | `web` | S3-compatible storage (direct port access) |

---

## Docker Commands Reference

### General
```bash
# List all running containers
docker ps

# List all containers (including stopped)
docker ps -a

# View all Docker volumes
docker volume ls

# Check container logs
docker logs [container-name]

# Restart a container
docker restart [container-name]

# Execute command in container
docker exec -it [container-name] sh
```

### Compose
```bash
# Start service
docker compose up -d

# Stop service
docker compose down

# View logs
docker compose logs -f

# Update service
docker compose pull
docker compose up -d

# View status
docker compose ps

# Rebuild and restart
docker compose up -d --build

# Force recreate containers
docker compose up -d --force-recreate
```

### Network Management
```bash
# List all networks
docker network ls

# Inspect network (see connected containers)
docker network inspect web

# Create the shared web network (if needed)
docker network create web
```

### Backup
```bash
# Backup n8n data
docker run --rm -v n8n_data:/data -v $(pwd):/backup alpine tar czf /backup/n8n-backup-$(date +%Y%m%d).tar.gz -C /data .

# Backup Postgres
docker exec postgres pg_dumpall -U ${POSTGRES_USER} > backup-$(date +%Y%m%d).sql

# Backup Open WebUI data
docker run --rm -v openwebui_data:/data -v $(pwd):/backup alpine tar czf /backup/openwebui-backup-$(date +%Y%m%d).tar.gz -C /data .

# Backup Minio data
docker run --rm -v minio_data:/data -v $(pwd):/backup alpine tar czf /backup/minio-backup-$(date +%Y%m%d).tar.gz -C /data .
```

---

## Network & Security

### Firewall (UFW)
```bash
# Check status
sudo ufw status

# Allow HTTP/HTTPS (for Caddy/n8n)
sudo ufw allow 80
sudo ufw allow 443

# Allow SSH (if not already)
sudo ufw allow 22
```

### DNS
- **Domain**: Configure your domain name in `.env` files
- **Subdomains**: Configure A records pointing to server IP
- **Active Domains** (configure in Caddyfile):
  - `n8n.example.com` → n8n workflow automation
  - `owui.example.com` → Open WebUI interface

---

## Configuration

Before starting services, you need to configure environment variables and the Caddyfile:

1. **Copy `.env.example` files** to `.env` in each service directory
2. **Configure database credentials** for Postgres in `infrastructure/.env`
3. **Set API keys and licenses** as needed (n8n license, etc.)
4. **Configure Caddyfile**:
   - Copy `infrastructure/caddy_config/Caddyfile.template` to `infrastructure/caddy_config/Caddyfile`
   - Edit `Caddyfile` and replace the example domains with your actual domain names
   - Configure DNS A records pointing to your server IP for each subdomain

---

## Service Details

### Infrastructure (Caddy + Postgres)
- **Services**: Caddy reverse proxy, Postgres database
- **Network**: `web` (external, shared)
- **Caddy Configuration**: 
  - Copy `Caddyfile.template` to `Caddyfile` and edit with your domain names
  - The `Caddyfile` is gitignored (only the template is version controlled)
  - Ensure DNS A records are configured for your domains
- **Postgres Access**: 
  - From containers: `postgres:5432`
  - From host: `localhost:5432` (port exposed)
  - Credentials: Set in `.env` file

### n8n
- **Domain**: Configure in Caddyfile (e.g., `n8n.example.com`)
- **Network**: `web`
- **Features**: 
  - Internal API accessible via configured domain (extra_hosts mapping)
  - Local files mounted at `/files`
  - Trust proxy enabled for Caddy

### Open WebUI
- **Domain**: Configure in Caddyfile (e.g., `owui.example.com`)
- **Network**: `web`
- **Database**: Connected to Postgres via `DATABASE_URL`
- **Storage**: Currently using SQLite (S3/Minio disabled)

### Minio
- **Access**: Direct port access
  - API: `http://[server-ip]:9000`
  - Console: `http://[server-ip]:9001`
- **Network**: `web`
- **Credentials**: Set in `.env` file

---

## Best Practices

1. **Always check `docker-compose.yml` before starting**
   - Verify ports don't conflict
   - Check environment variables
   - Ensure volumes are properly configured
   - Verify network connectivity (all services use `web` network)

2. **Use environment files (.env)**
   - Never commit secrets
   - Use `.env.example` for templates
   - Document all variables
   - Use "safe" characters in passwords (letters, numbers) to avoid shell parsing issues

3. **Backup before major changes**
   - Test backup restoration
   - Keep multiple backup versions
   - Automate backups where possible

4. **One service, one compose file**
   - Easier to debug
   - Safer updates
   - Independent scaling
   - No cascade failures
   - Exception: Infrastructure (Caddy + Postgres) share a compose file as they're both essential to the network

5. **Name your volumes**
   - Easier to backup/restore
   - Data persists across container restarts
   - Avoid anonymous volumes
   - Use external volumes for shared data (e.g., `n8n_data`)

6. **Network Communication**
   - Services on `web` network can reach each other by container name
   - Example: `postgres:5432`, `n8n:5678`, `openwebui:8080`, `minio:9000`

---

## Troubleshooting

### Container won't start
```bash
docker compose logs
# Check for port conflicts, missing environment variables
# Verify .env file exists and has correct values
```

### Permission denied
```bash
# Fix volume permissions (adjust UID/GID as needed)
sudo chown -R 1000:1000 /path/to/volume

# For bind mounts, check host directory permissions
ls -la /path/to/mount
```

### Out of memory
```bash
# Check memory usage
free -h
docker stats

# Check specific container
docker stats [container-name]
```

### Network issues
```bash
# Check Docker networks
docker network ls
docker network inspect web

# Verify container is on correct network
docker inspect [container-name] | grep -A 10 Networks
```

### Caddy not routing correctly
```bash
# Reload Caddy configuration
docker exec caddy caddy reload --config /etc/caddy/Caddyfile

# Check Caddy logs
docker logs caddy

# Verify DNS resolution
nslookup [domain-name]
```

### Postgres connection issues
```bash
# Test connection from container
docker exec -it postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}

# Check if Postgres is accepting connections
docker exec postgres pg_isready -U ${POSTGRES_USER}

# Verify firewall allows port 5432
sudo ufw status
```

### Environment variable issues
```bash
# Check if variables are set correctly
docker exec [container-name] env | grep [VARIABLE_NAME]

# Verify .env file syntax (no unescaped $ signs)
cat .env
```

---

## Accessing Services

### Web Interfaces
After configuring your domain in Caddyfile:
- **n8n**: `https://n8n.yourdomain.com`
- **Open WebUI**: `https://owui.yourdomain.com`

### Direct Port Access
- **Minio API**: `http://[server-ip]:9000`
- **Minio Console**: `http://[server-ip]:9001`
- **Postgres**: `localhost:5432` (from host) or `postgres:5432` (from containers)

### Internal Service Communication
All services on the `web` network can communicate using container names:
- Postgres: `postgres:5432`
- n8n: `n8n:5678`
- Open WebUI: `openwebui:8080`
- Minio: `minio:9000` (API), `minio:9001` (Console)

## Future Enhancements

- [ ] **Enable S3 storage in Open WebUI**: Re-enable Minio integration
- [ ] **Automated Backups**: Scheduled backups to external storage
- [ ] **Monitoring**: Resource usage and uptime monitoring (Prometheus/Grafana)
- [ ] **Health Checks**: Add healthcheck endpoints to all services
- [ ] **CI/CD**: Automated deployment pipelines

---

## Documentation

- **This File**: `README.md` (overview and quick reference)
- **Service Docs**: Check individual service folders for specific documentation
- **Docker Cheatsheet**: `docker-cheatsheet.md`

---

## Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting a Pull Request. By contributing, you agree to the Contributor License Agreement outlined in that document.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.