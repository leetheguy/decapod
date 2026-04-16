---
name: nocodb-update
description: Update an existing record in any NocoDB table. Provide the table ID and a fields object that includes the record ID.
---

# nocodb-update

## Purpose
Partially update an existing record in a NocoDB table. Only include the fields you want to change — everything else stays untouched.

## Parameters
- `table_id` (required): The NocoDB table ID. See life-os.md for the full schema and table IDs.
- `fields` (required): An object containing the fields to update. Must include `Id` to identify the record.

## Usage Example
```json
{
  "table_id": "m9q1eb46ozg6ogm",
  "fields": {
    "Id": 1,
    "processed": true,
    "processed at": "2026-03-09"
  }
}
```

## Expected Output
Returns the updated record with all modified fields confirmed.

## Edge Cases
- `Id` is REQUIRED inside `fields` — without it the skill won't know which record to update.
- Only include fields you want to change. Omitted fields are left as-is.
- Field names are case-sensitive and must match the schema in life-os.md exactly.
- Returns a 404 error if the record ID doesn't exist.

specs:
\```json
{
  "table_id": {
    "description": "The NocoDB table ID to update. See life-os.md.",
    "type": "string",
    "required": true
  },
  "fields": {
    "description": "Object of fields to update. Must include 'Id' to identify the target record.",
    "type": "object",
    "required": true
  }
}
\```