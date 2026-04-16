---
name: nocodb-create
description: Create a new record in any NocoDB table. Provide the table ID and the fields you want to populate.
---

# nocodb-create

## Purpose
Insert a new record into a NocoDB table. The fields object should match the table's column names exactly. Any fields not provided will use their default values.

## Parameters
- `table_id` (required): The NocoDB table ID. See life-os.md for the full schema and table IDs.
- `fields` (required): An object containing the field names and values to populate.

## Usage Example
```json
{
  "table_id": "m9q1eb46ozg6ogm",
  "fields": {
    "title": "Review pull requests",
    "notes": "Check the Decapod repo for open PRs",
    "processed": false
  }
}
```

## Expected Output
Returns the created record with its assigned `Id` and all populated fields.

## Edge Cases
- Do NOT include `Id`, `CreatedAt`, or `UpdatedAt` — these are auto-populated.
- Field names are case-sensitive and must match the schema in life-os.md exactly.
- For linked fields, use the appropriate link skill instead.

specs:
\```json
{
  "table_id": {
    "description": "The NocoDB table ID to insert into. See life-os.md.",
    "type": "string",
    "required": true
  },
  "fields": {
    "description": "Object of field names and values to populate in the new record",
    "type": "object",
    "required": true
  }
}
\```