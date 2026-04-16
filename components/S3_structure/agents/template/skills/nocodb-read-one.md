---
name: nocodb-read-one
description: Read a single record from any NocoDB table by its ID.
---

# nocodb-read-one

## Purpose
Fetch a single record from a NocoDB table using its primary key. Use this when you know the exact record ID and need its full data.

## Parameters
- `table_id` (required): The NocoDB table ID. See life-os.md for the full schema and table IDs.
- `row_id` (required): The integer ID of the record to fetch.

## Usage Example
```json
{
  "table_id": "m9q1eb46ozg6ogm",
  "row_id": 1
}
```

## Expected Output
Returns the full record object including all fields, `Id`, `CreatedAt`, and `UpdatedAt`.

## Edge Cases
- Returns a 404 error if the record doesn't exist.
- Use `nocodb-read-many` if you don't know the ID and need to search by field values.
- See life-os.md for table IDs, field names, and schema details.

specs:
\```json
{
  "table_id": {
    "description": "The NocoDB table ID to read from. See life-os.md.",
    "type": "string",
    "required": true
  },
  "row_id": {
    "description": "The integer primary key of the record to fetch",
    "type": "integer",
    "required": true
  }
}
\```