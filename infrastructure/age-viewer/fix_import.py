import re, pathlib

f = pathlib.Path('/app/frontend/src/components/cypherresult/presentations/CypherResultTable.jsx')
src = f.read_text()

# Remove the broken cytoscape import
src = re.sub(r"import \{ uuid \} from 'cytoscape/src/util';\n", '', src)

# Insert uuid declaration after the last import line
src = re.sub(
    r"((?:import [^\n]+\n)+)",
    r"\1\nconst uuid = () => crypto.randomUUID();\n",
    src,
    count=1
)

f.write_text(src)
print("Patched CypherResultTable.jsx successfully")
