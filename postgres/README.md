# Postgres

PostgreSQL 18 with [Apache AGE](https://age.apache.org/) (graph extension) and [pgvector](https://github.com/pgvector/pgvector) (vector embeddings extension).

## Setup

Copy `.env.example` to `.env` and fill in your credentials:

```bash
cp .env.example .env
```

## Starting

```bash
docker compose up -d --build
```

## Extensions

AGE and pgvector are installed in the image but must be enabled per-database:

```sql
CREATE EXTENSION IF NOT EXISTS age;
CREATE EXTENSION IF NOT EXISTS vector;
```

These are already enabled in the default `postgres` database. Run the above in any additional databases where you need them.

## Volume

Data is stored in the `infrastructure_postgres_data` Docker volume (created by the `infrastructure` compose project). This volume is referenced as external here so it persists independently of this compose file.
