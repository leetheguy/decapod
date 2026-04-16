---
name: db-query
description: Execute a SQL query against the Decapod PostgreSQL database. Use for reading or writing any data.
---

# db-query

## Purpose
Run any SQL query against the PostgreSQL database and return the results. You have access to the full power of PostgreSQL — window functions, CTEs, JSON operators, full text search, aggregations, and more.

## Parameters
- `sql` (required): The SQL query to execute.

## Usage
Use this skill whenever you need to read or write data to the database. You write the SQL, Decapod executes it.

## Expected Output
An array of row objects for SELECT queries. Confirmation for INSERT/UPDATE/DELETE.

## Edge Cases
- Invalid SQL will return an error. Double check syntax before retrying.
- Destructive queries (DROP, TRUNCATE) are your responsibility. Be careful.

specs:
```json
{
  "sql": {
    "description": "The PostgreSQL query to execute",
    "type": "string",
    "required": true
  }
}
```