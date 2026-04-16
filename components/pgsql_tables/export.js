const { Pool } = require('/home/agent/claude_browser/works/servers/node_modules/pg');
const fs = require('fs');
const path = require('path');

const pool = new Pool({ connectionString: 'postgresql://decapod_readonly:0Lygb6hLAWJebA@172.19.0.3:5432/decapod' });
const OUT = '/home/agent/claude_browser/works/decapod_schema';

function escape(val) {
  if (val === null || val === undefined) return 'NULL';
  if (typeof val === 'boolean') return val ? 'TRUE' : 'FALSE';
  if (typeof val === 'number') return val.toString();
  if (Array.isArray(val)) return `ARRAY[${val.map(v => `'${String(v).replace(/'/g, "''")}'`).join(',')}]`;
  if (typeof val === 'object') return `'${JSON.stringify(val).replace(/'/g, "''")}' ::jsonb`;
  return `'${String(val).replace(/'/g, "''")}' `;
}

async function exportTable(filename, sql, table) {
  const res = await pool.query(sql);
  const cols = res.fields.map(f => f.name);
  const lines = [`-- ${table}`, `TRUNCATE ${table} RESTART IDENTITY CASCADE;`];
  for (const row of res.rows) {
    const vals = cols.map(c => escape(row[c]));
    lines.push(`INSERT INTO ${table} (${cols.join(', ')}) VALUES (${vals.join(', ')});`);
  }
  fs.writeFileSync(path.join(OUT, filename), lines.join('\n') + '\n');
  console.log(`${filename}: ${res.rows.length} rows`);
}

async function main() {
  await exportTable('seed_agents.sql', 'SELECT * FROM agents ORDER BY id', 'agents');
  await exportTable('seed_tools.sql', 'SELECT * FROM tools ORDER BY id', 'tools');
  await exportTable('seed_agent_instructions.sql', 'SELECT * FROM agent_instructions ORDER BY agent_id, instruction_id', 'agent_instructions');
  await exportTable('seed_instructions_skills.sql', 'SELECT * FROM instructions WHERE is_skill = true ORDER BY id', 'instructions');
  await exportTable('seed_instructions_non_skills.sql', 'SELECT * FROM instructions WHERE is_skill = false ORDER BY id', 'instructions');
  await pool.end();
  console.log('done');
}

main().catch(e => { console.error(e.message); process.exit(1); });
