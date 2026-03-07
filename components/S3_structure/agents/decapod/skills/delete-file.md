---
name: delete-file
description: Delete a file from storage. Use this when you need to remove a file permanently.
---

# delete_file

## Purpose
Remove a file permanently from the Decapod file system.

## Parameters
- `name` (required): The filename including extension. Example: `old-notes.txt`
- `path` (required): The folder location. Example: `/documents/`

## Usage
Use this skill when you need to delete a file that is no longer needed. Ensure you have the correct path before deleting. Once deleted, the file cannot be easily recovered. It is often wise to use the `list-files` skill first to verify.

## Expected Output
A success message confirming the file has been deleted.

## Edge Cases
- If the file does not exist, an error will be returned. Double check the `path` before retrying.
- The path must point to a file, not a directory.

specs:
```json
{
  "name": {
    "description": "the name of the file including extension",
    "type": "string",
    "required": true
  },
  "path": {
    "description": "the folder location",
    "type": "string",
    "required": true
  }
}
```
