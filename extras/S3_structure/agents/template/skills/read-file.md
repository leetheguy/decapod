---
name: read-file
description: Read the contents of a file from storage. Use this when you need to load a file by path.
---

# read_file

## Purpose
Read and return the full contents of a file from the Decapod file system.

## Parameters
- `name` (required): The filename including extension. Example: `persona.md`
- `path` (required): The folder location. Example: `/definitions/`

## Usage
Call this skill when you need to load a file to read its contents. Always use `list-files` first if you are unsure whether a file exists. Do not guess filenames.

## Expected Output
The raw contents of the file as a string.

## Edge Cases
- If the file does not exist, you will receive an error. Do not retry unless both `name` and `path` are corrected.
- Do not assume file contents — always read before acting on a file.

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