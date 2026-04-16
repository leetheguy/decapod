---
name: nocodb-read-many
description: Read multiple records from any NocoDB table. Supports filtering, sorting, and pagination.
---

# nocodb-read-many

## Purpose
Fetch a list of records from a NocoDB table. All parameters except `table_id` are optional — omit anything you don't need and the skill handles the rest.

## Parameters
- `table_id` (required): The NocoDB table ID. See life-os.md for the full schema and table IDs.
- `where` (optional): Filter condition string. Format: `(field,operator,value)`. Chain with `~and` / `~or`. Example: `(done,eq,false)~and(urgency,eq,high)`
- `sort` (optional): Array of sort objects. Example: `[{"field": "due date", "direction": "asc"}]`
- `fields` (optional): Array of field names to include in the response. Omit for all fields. Example: `["title", "status", "due date"]`
- `page` (optional): Page number for pagination. Defaults to 1.
- `pageSize` (optional): Number of records per page. Defaults to all.
- `viewId` (optional): Restrict results to a specific view. See life-os.md for view IDs.

## Where Operators
`eq`, `neq`, `lt`, `lte`, `gt`, `gte`, `like`, `nlike`, `empty`, `notempty`, `null`, `notnull`

## Usage Example
```json
{
  "table_id": "mcpb3l17inxez7t",
  "where": "(done,eq,false)~and(urgency,eq,high)",
  "sort": [{"field": "due date", "direction": "asc"}],
  "fields": ["title", "status", "due date", "urgency"],
  "pageSize": 25
}
```

## Expected Output
Returns a `records` array of matching records, plus pagination tokens `next` and `prev` if applicable.

## Edge Cases
- Returns an empty `records` array if no records match — not an error.
- Field names in `where` and `sort` are case-sensitive.
- Use `nocodb-read-one` if you already know the record ID.

specs:
\```json
{
  "table_id": {
    "description": "The NocoDB table ID to query",
    "type": "string",
    "required": true
  },
  "where": {
    "description": "Filter string in NocoDB format: (field,operator,value) chained with ~and / ~or",
    "type": "string",
    "required": false
  },
  "sort": {
    "description": "Array of sort objects with 'field' and 'direction' (asc/desc)",
    "type": "array",
    "required": false
  },
  "fields": {
    "description": "Array of field names to include in response. Omit for all fields.",
    "type": "array",
    "required": false
  },
  "page": {
    "description": "Page number for pagination, defaults to 1",
    "type": "integer",
    "required": false
  },
  "pageSize": {
    "description": "Number of records per page",
    "type": "integer",
    "required": false
  },
  "viewId": {
    "description": "Restrict results to a specific view ID. See life-os.md.",
    "type": "string",
    "required": false
  }
}
\```