---
name: list-files
description: List all files in a folder. Use this when you need to know what files are available before reading or writing.
---

# list_files

## Purpose
Return a list of all files in a given folder in the Decapod file system.

## Parameters
- `path` (required): The folder location to list. Example: `/definitions/`

## Usage
Use this skill before `read-file` when you are unsure whether a file exists or what files are available. Do not guess filenames.

## Expected Output
A list of filenames in the specified folder.

## Edge Cases
- If the folder is empty, you will receive an empty list. Do not treat this as an error.
- If the folder does not exist, you will receive an error. Double check the `path` before retrying.

specs:
```json
{
  "path": {
    "description": "the folder location to list",
    "type": "string"
  }
}
```