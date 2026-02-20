---
name: write-file
description: Write or overwrite a file in storage. Use this when you need to save new content to a file.
---

# write_file

## Purpose
Write content to a file in the Decapod file system. If the file already exists, it will be overwritten in full.

## Parameters
- `name` (required): The filename including extension. Example: `persona.md`
- `path` (required): The folder location. Example: `/definitions/`
- `content` (required): The full content to write to the file as a string. Always write the complete file — partial writes are not supported.

## Usage
Always `read-file` before writing to a file that may already exist. Write the complete intended content every time — do not assume the existing content will be preserved.

## Expected Output
A confirmation that the file was written successfully.

## Edge Cases
- Do not write partial content. The entire file will be replaced.
- If you are updating a file, read it first, apply your changes mentally, then write the full updated version.
- Do not write to a file you have not been given permission to modify.

specs:
```json
{
  "name": {
    "description": "the name of the file including extension",
    "type": "string"
  },
  "path": {
    "description": "the folder location",
    "type": "string"
  },
  "content": {
    "description": "the full content to write to the file",
    "type": "string"
  }
}
```