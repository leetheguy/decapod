---
name: access-sandbox
description: Execute commands in the agent's sandboxed Ubuntu environment. Use this for file operations, running scripts, installing packages, or anything requiring a real shell.
---

# access-sandbox

## Purpose
Run shell commands inside the agent's private, isolated Ubuntu container. The agent has full root access to this sandbox. Nothing executed here can affect the host system.

## Parameters
- `command` (required): The shell command to execute. Can be any valid bash command.
- `working_directory` (optional): Directory to run the command from. Defaults to `/home/agent`.
- `timeout` (optional): Max seconds to wait for the command to complete. Defaults to 30.

## Usage
Use this skill for anything requiring a real filesystem or shell:
- List files: `ls -la /home/agent/files/`
- Read a file: `cat /home/agent/files/persona.md`
- Write a file: `echo "content" > /home/agent/files/output.md`
- Run a script: `node /home/agent/scripts/process.js`
- Install a package: `uv pip install requests`

## Expected Output
stdout and stderr from the command, plus the exit code.

## Edge Cases
- Non-zero exit code means the command failed. Read stderr for details.
- Long running commands may timeout. Use `timeout` parameter to extend.
- Files persist between calls within a session but the container may be reset between sessions.

## Notes
- Python packages: use `uv pip install`
- Node packages: use `npm install`
- Node versions: use `nvm use <version>`

specs:
```json
{
  "command": {
    "description": "The bash command to execute",
    "type": "string",
    "required": true
  },
  "working_directory": {
    "description": "Directory to execute the command from",
    "type": "string",
    "required": false
  }
}
```