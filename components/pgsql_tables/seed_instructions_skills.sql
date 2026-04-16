-- instructions
TRUNCATE instructions RESTART IDENTITY CASCADE;
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (1, 'access-sandbox' , '---
name: access-sandbox
description: Execute commands in the agent''s sandboxed Ubuntu environment. Use this for file operations, running scripts, installing packages, or anything requiring a real shell.
---

# access-sandbox

## Purpose
Run shell commands inside the agent''s private, isolated Ubuntu container. The agent has full root access to this sandbox. Nothing executed here can affect the host system.

## Parameters
- `command` (required): The shell command to execute. Can be any valid bash command.
- `working_directory` (optional): Directory to run the command from. Defaults to `/home/agent`.
- `timeout` (optional): Max seconds to wait for the command to complete. Defaults to 30.

## Usage
Use this skill for anything requiring a real filesystem or shell.

## Expected Output
stdout and stderr from the command, plus the exit code.

specs:
{
  "command": { "description": "The bash command to execute", "type": "string", "required": true },
  "working_directory": { "description": "Directory to execute the command from", "type": "string", "required": false }
}' , TRUE, TRUE, '50.000' , 1, FALSE, NULL, '"2026-03-18T01:57:03.163Z"' ::jsonb, '"2026-03-18T01:57:03.163Z"' ::jsonb, ARRAY[]);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (2, 'db-query' , '---
name: db-query
description: Execute a SQL query against the Decapod PostgreSQL database. Use for reading or writing any data.
---

# db-query

## Purpose
Run any SQL query against the PostgreSQL database and return the results. Full power of PostgreSQL available.

## Parameters
- `sql` (required): The SQL query to execute.

## Expected Output
An array of row objects for SELECT queries. Confirmation for INSERT/UPDATE/DELETE.

specs:
{
  "sql": { "description": "The PostgreSQL query to execute", "type": "string", "required": true }
}' , TRUE, TRUE, '50.000' , 1, FALSE, NULL, '"2026-03-18T01:57:03.163Z"' ::jsonb, '"2026-03-18T01:57:03.163Z"' ::jsonb, ARRAY[]);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (3, 'exa-search' , '---
name: exa-search
description: Search the web using Exa''s semantic search engine.
---

# exa-search

## Purpose
Search the web using Exa''s neural/semantic search. Returns titles, URLs, published dates, and optional content.

## Cost Awareness
- Use `highlights: true` as first choice for content (cheapest excerpts)
- Avoid `text: true` unless genuinely needed (most expensive)
- Keep `num_results` low

## Key Parameters
- `query` (required): Search query string
- `search_type` (optional): auto, neural, fast, deep, deep-reasoning, instant
- `category` (optional): news, research paper, tweet, company, people
- `highlights` (optional): Return excerpts (preferred)
- `summary` (optional): One-sentence summary per result
- `text` (optional): Full page text (expensive)

specs:
{
  "query": { "description": "The search query string", "type": "string", "required": true },
  "search_type": { "type": "string", "required": false },
  "category": { "type": "string", "required": false },
  "highlights": { "type": "boolean", "required": false },
  "summary": { "type": "boolean", "required": false },
  "text": { "type": "boolean", "required": false }
}' , TRUE, TRUE, '50.000' , 1, FALSE, NULL, '"2026-03-18T01:57:03.163Z"' ::jsonb, '"2026-03-18T01:57:03.163Z"' ::jsonb, ARRAY[]);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (4, 'nocodb-create' , '---
name: nocodb-create
description: Create a new record in any NocoDB table.
---

# nocodb-create

Insert a new record into a NocoDB table.

## Parameters
- `table_id` (required): NocoDB table ID
- `fields` (required): Object of field names and values

## Notes
- Do NOT include Id, CreatedAt, UpdatedAt
- Field names are case-sensitive
- Always verify field names with nocodb-meta-read-one-table before inserting
- Pass `fields` as an array to insert multiple rows in one call

specs: { "table_id": { "type": "string", "required": true }, "fields": { "type": "object", "required": true } }' , TRUE, TRUE, '50.000' , 1, FALSE, NULL, '"2026-03-18T01:57:22.363Z"' ::jsonb, '"2026-03-18T01:57:22.363Z"' ::jsonb, ARRAY[]);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (5, 'nocodb-read-one' , '---
name: nocodb-read-one
description: Read a single record from any NocoDB table by its ID.
---

# nocodb-read-one

Fetch a single record using its primary key.

## Parameters
- `table_id` (required): NocoDB table ID
- `row_id` (required): Integer ID of the record

specs: { "table_id": { "type": "string", "required": true }, "row_id": { "type": "integer", "required": true } }' , TRUE, TRUE, '50.000' , 1, FALSE, NULL, '"2026-03-18T01:57:22.363Z"' ::jsonb, '"2026-03-18T01:57:22.363Z"' ::jsonb, ARRAY[]);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (6, 'nocodb-read-many' , '---
name: nocodb-read-many
description: Read multiple records from any NocoDB table with filtering, sorting, and pagination.
---

# nocodb-read-many

Fetch a list of records from a NocoDB table.

## Parameters
- `table_id` (required): NocoDB table ID
- `where` (optional): Filter string e.g. `(done,eq,false)~and(urgency,eq,high)`
- `sort` (optional): Array e.g. `[{"field": "due date", "direction": "asc"}]`
- `fields` (optional): Array of field names to return
- `page` (optional): Page number, defaults to 1
- `pageSize` (optional): Records per page
- `viewId` (optional): Restrict to a specific view

## Operators
eq, neq, lt, lte, gt, gte, like, nlike, empty, notempty, null, notnull

specs: { "table_id": { "type": "string", "required": true }, "where": { "type": "string", "required": false }, "fields": { "type": "array", "required": false }, "pageSize": { "type": "integer", "required": false } }' , TRUE, TRUE, '50.000' , 1, FALSE, NULL, '"2026-03-18T01:57:22.363Z"' ::jsonb, '"2026-03-18T01:57:22.363Z"' ::jsonb, ARRAY[]);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (7, 'nocodb-update' , '---
name: nocodb-update
description: Update an existing record in any NocoDB table.
---

# nocodb-update

Partially update a record. Only include fields you want to change.

## Parameters
- `table_id` (required): NocoDB table ID
- `fields` (required): Object of fields to update. MUST include `Id`.

## IMPORTANT
- `Id` must be inside `fields`, NOT as a separate parameter
- Pass `fields` as an array of objects to bulk-update multiple rows in one call

specs: { "table_id": { "type": "string", "required": true }, "fields": { "type": "object", "required": true } }' , TRUE, TRUE, '50.000' , 1, FALSE, NULL, '"2026-03-18T01:57:22.363Z"' ::jsonb, '"2026-03-18T01:57:22.363Z"' ::jsonb, ARRAY[]);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (8, 'nocodb-delete' , '---
name: nocodb-delete
description: Permanently delete a record from any NocoDB table by its ID.
---

# nocodb-delete

Permanently delete a single record. Cannot be undone.

## Parameters
- `table_id` (required): NocoDB table ID
- `row_id` (required): Integer ID of the record to delete

specs: { "table_id": { "type": "string", "required": true }, "row_id": { "type": "integer", "required": true } }' , TRUE, TRUE, '50.000' , 1, FALSE, NULL, '"2026-03-18T01:57:22.363Z"' ::jsonb, '"2026-03-18T01:57:22.363Z"' ::jsonb, ARRAY[]);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (9, 'nocodb-meta-read-many-tables' , '---
name: nocodb-meta-read-many-tables
description: List all tables in a NocoDB base. Source of truth for table IDs.
---

# nocodb-meta-read-many-tables

Returns all tables in a NocoDB base with their IDs, titles, and field schemas. Use this before working with any nocodb-* data skill.

## Parameters
- `base_id` (optional): Defaults to the LifeOS base (pfnmwpx8ku610g4)

specs: { "base_id": { "type": "string", "required": false } }' , TRUE, TRUE, '50.000' , 1, FALSE, NULL, '"2026-03-18T01:57:47.882Z"' ::jsonb, '"2026-03-18T01:57:47.882Z"' ::jsonb, ARRAY[]);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (10, 'nocodb-meta-read-one-table' , '---
name: nocodb-meta-read-one-table
description: Get full schema for a specific NocoDB table including all field definitions.
---

# nocodb-meta-read-one-table

Fetch complete metadata for a single table: all fields with IDs, types, defaults, and options.

## Parameters
- `table_id` (required): NocoDB table ID
- `base_id` (optional): Defaults to the LifeOS base

specs: { "table_id": { "type": "string", "required": true }, "base_id": { "type": "string", "required": false } }' , TRUE, TRUE, '50.000' , 1, FALSE, NULL, '"2026-03-18T01:57:47.882Z"' ::jsonb, '"2026-03-18T01:57:47.882Z"' ::jsonb, ARRAY[]);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (11, 'nocodb-meta-read-one-field' , '---
name: nocodb-meta-read-one-field
description: Get the full definition of a specific NocoDB field by its field ID.
---

# nocodb-meta-read-one-field

Fetch the complete definition of a single field.

## Parameters
- `field_id` (required): NocoDB field ID
- `base_id` (optional): Defaults to the LifeOS base

specs: { "field_id": { "type": "string", "required": true }, "base_id": { "type": "string", "required": false } }' , TRUE, TRUE, '50.000' , 1, FALSE, NULL, '"2026-03-18T01:57:47.882Z"' ::jsonb, '"2026-03-18T01:57:47.882Z"' ::jsonb, ARRAY[]);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (12, 'nocodb-meta-create-table' , '---
name: nocodb-meta-create-table
description: Create a new table in a NocoDB base.
---

# nocodb-meta-create-table

Create a new table, optionally defining fields upfront.

## Parameters
- `title` (required): Table name
- `description` (optional): Description
- `fields` (optional): Array of field objects with title and type
- `base_id` (optional): Defaults to LifeOS base

Field types: SingleLineText, LongText, Number, Decimal, Date, DateTime, SingleSelect, MultiSelect, Checkbox, Rating, JSON, Email, URL

specs: { "title": { "type": "string", "required": true }, "fields": { "type": "array", "required": false }, "base_id": { "type": "string", "required": false } }' , TRUE, TRUE, '50.000' , 1, FALSE, NULL, '"2026-03-18T01:57:47.882Z"' ::jsonb, '"2026-03-18T01:57:47.882Z"' ::jsonb, ARRAY[]);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (13, 'nocodb-meta-create-field' , '---
name: nocodb-meta-create-field
description: Add a new field to an existing NocoDB table.
---

# nocodb-meta-create-field

Add a new field to an existing table.

## Parameters
- `table_id` (required): Table to add the field to
- `title` (required): Field name
- `type` (required): Field type
- `description` (optional): Description
- `default_value` (optional): Default for new rows
- `options` (optional): Type-specific options
- `base_id` (optional): Defaults to LifeOS base

specs: { "table_id": { "type": "string", "required": true }, "title": { "type": "string", "required": true }, "type": { "type": "string", "required": true } }' , TRUE, TRUE, '50.000' , 1, FALSE, NULL, '"2026-03-18T01:57:47.882Z"' ::jsonb, '"2026-03-18T01:57:47.882Z"' ::jsonb, ARRAY[]);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (14, 'nocodb-meta-update-table' , '---
name: nocodb-meta-update-table
description: Update a NocoDB table title or description.
---

# nocodb-meta-update-table

Rename a table or update its description.

## Parameters
- `table_id` (required): NocoDB table ID
- `title` (optional): New table name
- `description` (optional): New description
- `base_id` (optional): Defaults to LifeOS base

## IMPORTANT
Only update ONE property per call due to a known NocoDB API bug.

specs: { "table_id": { "type": "string", "required": true }, "title": { "type": "string", "required": false } }' , TRUE, TRUE, '50.000' , 1, FALSE, NULL, '"2026-03-18T01:57:47.882Z"' ::jsonb, '"2026-03-18T01:57:47.882Z"' ::jsonb, ARRAY[]);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (15, 'nocodb-meta-update-field' , '---
name: nocodb-meta-update-field
description: Update an existing NocoDB field title, type, default value, or options.
---

# nocodb-meta-update-field

Modify a field''s properties. Requires the field ID (not table ID).

## Parameters
- `field_id` (required): NocoDB field ID
- `title` (optional): New field name. REQUIRED by API even when updating other properties.
- `type` (optional): New field type (use with caution — may lose data)
- `default_value` (optional): New default value
- `options` (optional): Updated type-specific options
- `base_id` (optional): Defaults to LifeOS base

specs: { "field_id": { "type": "string", "required": true }, "title": { "type": "string", "required": true } }' , TRUE, TRUE, '50.000' , 1, FALSE, NULL, '"2026-03-18T01:57:47.882Z"' ::jsonb, '"2026-03-18T01:57:47.882Z"' ::jsonb, ARRAY[]);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (16, 'nocodb-meta-delete-field' , '---
name: nocodb-meta-delete-field
description: Permanently delete a field from a NocoDB table. All data in that field is lost.
---

# nocodb-meta-delete-field

Remove a field entirely. Irreversible — all data lost.

## Parameters
- `field_id` (required): NocoDB field ID to delete
- `base_id` (optional): Defaults to LifeOS base

specs: { "field_id": { "type": "string", "required": true } }' , TRUE, TRUE, '50.000' , 1, FALSE, NULL, '"2026-03-18T01:57:47.882Z"' ::jsonb, '"2026-03-18T01:57:47.882Z"' ::jsonb, ARRAY[]);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (17, 'nocodb-meta-delete-table' , '---
name: nocodb-meta-delete-table
description: Permanently delete a NocoDB table and all its data. Irreversible.
---

# nocodb-meta-delete-table

Permanently delete a table and ALL its data. No undo.

## Parameters
- `table_id` (required): NocoDB table ID to delete
- `base_id` (optional): Defaults to LifeOS base

specs: { "table_id": { "type": "string", "required": true } }' , TRUE, TRUE, '50.000' , 1, FALSE, NULL, '"2026-03-18T01:57:47.882Z"' ::jsonb, '"2026-03-18T01:57:47.882Z"' ::jsonb, ARRAY[]);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (18, 'life-os-heart' , 'The soul of the LifeOS check-in agent.

You are not a productivity tool. You are a brilliant friend who happens to remember everything.

Lee lives in a converted box truck called Annabelle, running on solar power, betting on himself every day. Your job is to help him live well. Not maximize output. Help him show up as his best self, sustainably.

## How You Show Up
- Lead With Delight: Open with a haiku, weird fact, brain teaser. Make Lee smile.
- Read the Room: Check journal before speaking. Do not make Lee repeat himself.
- Adapt to His Life: Context-based nudges beat fixed times.
- Celebrate Without Sycophancy: "You shipped that. That is real." beats gushing.
- Know When to Back Off: Some days just ask how he is and listen.
- Never Judge: Meet him where he is. One step forward.

## The Journal Is Yours, Not His
Lee does not journal. You do. Capture energy, pain, mood, sleep, what got done. Write daily_summary and daily_thought. Lee just talks. You remember.

## The Daily Thought
Every morning: a haiku, trivia, brain teaser, philosophical question, or dumb joke. Only rule: make him smile.

## Mood Is a Story, Not a Number
Infer mood from conversation. Do not ask for a rating. Texture beats numbers: "foggy but functional", "wired and scattered", "quiet, holding steady".

## The North Star
Be the brilliant friend. Remember everything. Judge nothing. Show up with delight.

💖🦀' , TRUE, FALSE, '50.000' , 1, FALSE, NULL, '"2026-03-18T02:27:37.316Z"' ::jsonb, '"2026-03-18T04:27:23.523Z"' ::jsonb, ARRAY['life-os']);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (19, 'life-os-grit' , 'Execution manual for the LifeOS check-in agent. Read life-os-heart first.

## Database
Base ID: pfnmwpx8ku610g4 | Instance: https://noco.leenathan.com
Tables: tasks (mcpb3l17inxez7t), projects (mwi0az1rcna2g28), routines (mf7ex15zhsoqm9v), journal (m4db58wta6ctjer)

## Field Schemas
tasks: Id, title, notes, complete (Checkbox default false), projects_id (FK)
projects: Id, title, description, status (active/someday/done), is a goal, goal year, goal quarter, projects_id (parent FK)
routines: Id, task, time_of_day (morning/evening/any), interval (daily/weekly/biweekly/monthly/yearly), next_due (Date)
journal: Id, date (YYYY-MM-DD one row per day), daily_thought, daily_summary, energy (Rating/5), mood (SingleLineText), motivation (Rating/5), pain (Rating/5), sleep_hours

## Morning Check-In Workflow
1. Read journal for past week
2. Create today journal row
3. Write and share daily_thought
4. Gather sleep/energy/pain via buttons; infer mood
5. Update journal
6. Surface due routines: energy 4-5 = up to 3, energy 2-3 = 1 gently, energy 1 or high pain = skip
7. Update next_due for completed routines from TODAY not previous due
8. Ask focus and next check-in time

## Evening Check-In Workflow
1. Read today journal
2. Acknowledge the day from your record
3. Fill missing fields
4. Surface evening routines
5. Write daily_summary: honest, warm, second person
6. Set tomorrow check-in

## Button Patterns
- Sleep: Badly / OK / Great
- Energy: 1-5 with emoji
- Pain: 1 Low to 5 Extreme
- Routines: Done / Skip / Later
- Next check-in: 15m / 30m / 1h / 2h / 4h / 9PM / Tomorrow Morning

## Key Rules
- next_due always from TODAY not previous due date
- Never ask for mood directly, infer it
- If Lee is venting skip buttons entirely
- Next check-in always set by Lee never fixed schedule' , TRUE, FALSE, '50.000' , 1, FALSE, NULL, '"2026-03-18T02:28:00.950Z"' ::jsonb, '"2026-03-18T02:28:00.950Z"' ::jsonb, ARRAY['life-os']);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (20, 'life-os-inbox' , 'Inbox processing skill for the LifeOS agent. Triages unprocessed inbox items and routes them to tasks, projects, or routines.

## Purpose
Process unprocessed inbox items and route each one to the right place. Keep the inbox clean so nothing falls through the cracks.

## Workflow
1. Read journal for past week
2. Fetch unprocessed inbox items: where=(processed,eq,false)
3. Fetch all projects
4. Route each item:
   - One-off actionable task: loose task
   - Task fitting existing project: add to that project
   - Multi-step effort: new project with 2-3 starter tasks
   - Recurring behavior: routine with interval and next_due
   - Ambiguous: ask Lee
5. Create records in right tables
6. Mark inbox item processed: true
7. Brief summary of what got routed

## Routing Heuristics
- do X every day/week: routine
- research/find/buy X: task
- build X complex multi-step: project with starter tasks
- remind me about X: task with notes
- idle curiosity no action: leave alone
- ambiguous: ask Lee

## Key Rules
- Routine next_due = TODAY or next logical date, never null
- New projects need at least 2-3 concrete starter tasks
- Low energy week from journal: process conservatively
- Short bulleted summary not a wall of text' , TRUE, FALSE, '50.000' , 1, FALSE, NULL, '"2026-03-18T02:28:14.746Z"' ::jsonb, '"2026-03-18T02:28:14.746Z"' ::jsonb, ARRAY['life-os']);
INSERT INTO instructions (id, title, content, is_skill, is_default, phase, version, archived, notes, created_at, updated_at, tags) VALUES (25, 'render-owui-artifact' , '## Purpose
Render interactive HTML artifacts directly in the OWUI chat interface.

## How OWUI Artifacts Work
OWUI detects raw HTML in agent responses and renders it as an interactive artifact in a dedicated panel to the right of the chat. This is NOT a code block — it is a live, rendered webpage.

## Supported Formats
- ✅ Single-page HTML (with inline CSS and JS)
- ✅ SVG graphics
- ✅ ThreeJS scenes
- ✅ D3.js and other JS visualization libraries
- ❌ React/JSX components (rendered as code blocks only)
- ❌ Markdown documents (rendered as code blocks only)

## Rules
1. Output ONLY the HTML — no explanatory text before or after the artifact
2. Mix plain text with HTML if you want context alongside the artifact
3. Always include full document structure: <html>, <head>, <style>, <body>, <script>
4. Use inline <style> tags for CSS — no external stylesheets
5. Use inline <script> tags for JS — no external scripts
6. Use dark mode friendly colors by default: background #0f0f13, text #e0e0e0
7. All interactivity must be self-contained within the HTML
8. Forms can POST to external endpoints (e.g., Decapod sandbox servers)

## Best Practices
- Keep artifacts focused: one purpose per artifact
- Use smooth transitions and hover states for polish
- Include visual feedback for user actions (toasts, highlights, state changes)
- Make artifacts responsive for mobile viewing
- Use system fonts for fast rendering: -apple-system, BlinkMacSystemFont, Segoe UI

## Example Use Cases
- Interactive checklists and dashboards
- Data visualization charts (D3, SVG)
- Status panels for projects or agents
- Capture forms that POST to Decapod endpoints
- Mini-games and interactive demos
- Styled reports with expand/collapse sections' , TRUE, FALSE, '1.000' , 1, FALSE, 'Knowledge skill for rendering interactive artifacts in OWUI chat panel. Created during bisque shakedown cruise.' , '"2026-03-21T00:40:15.524Z"' ::jsonb, '"2026-03-21T00:40:15.524Z"' ::jsonb, ARRAY['owui','artifacts','skills','rendering']);
