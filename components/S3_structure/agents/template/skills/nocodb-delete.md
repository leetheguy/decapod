---
name: nocodb-delete
description: Delete a record from any NocoDB table by its ID.
---

# nocodb-delete

## Purpose
Permanently delete a single record from a NocoDB table. This action cannot be undone — use with care!

## Parameters
- `table_id` (required): The NocoDB table ID. See life-os.md for the full schema and table IDs.
- `row_id` (required): The integer ID of the record to delete.

## Usage Example
```json
{
  "table_id": "m9q1eb46ozg6ogm",
  "row_id": 1
}
```

## Expected Output
Returns the ID of the deleted record as confirmation.

## Edge Cases
- This is permanent. When in doubt, use `nocodb-update` to mark a record inactive instead.
- Returns a 404 error if the record doesn't exist.
- See life-os.md for table IDs and schema details.

specs:
\```json
{
  "table_id": {
    "description": "The NocoDB table ID to delete from. See life-os.md.",
    "type": "string",
    "required": true
  },
  "row_id": {
    "description": "The integer primary key of the record to delete",
    "type": "integer",
    "required": true
  }
}
\```