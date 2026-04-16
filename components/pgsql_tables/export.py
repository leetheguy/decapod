#!/usr/bin/env python3
import json, os, urllib.request

OUT = '/home/agent/claude_browser/works/decapod_schema'
WB = 'https://n8n.leenathan.com/webhook/decapod-workbench'

def query(sql):
    data = json.dumps({'name': 'db-query', 'parameters': {'sql': sql}}).encode()
    req = urllib.request.Request(WB, data=data, headers={'Content-Type': 'application/json'}, method='POST')
    # workbench is async over HTTP - use db directly via readonly
    import psycopg2
    conn = psycopg2.connect('postgresql://decapod_readonly:0Lygb6hLAWJebA@172.19.0.3:5432/decapod')
    cur = conn.cursor()
    cur.execute(sql)
    rows = cur.fetchall()
    cols = [d[0] for d in cur.description]
    result = [dict(zip(cols, row)) for row in rows]
    cur.close()
    conn.close()
    return result

def export(filename, sql):
    data = query(sql)
    with open(os.path.join(OUT, filename), 'w') as f:
        json.dump(data, f, default=str)
    print(f'{filename}: {len(data)} rows')

export('agents.json', 'SELECT * FROM agents ORDER BY id')
export('tools.json', 'SELECT * FROM tools ORDER BY id')
export('agent_instructions.json', 'SELECT * FROM agent_instructions ORDER BY agent_id, instruction_id')
export('instructions_skills.json', 'SELECT * FROM instructions WHERE is_skill = true ORDER BY id')
export('instructions_non_skills.json', 'SELECT * FROM instructions WHERE is_skill = false ORDER BY id')
print('done')
