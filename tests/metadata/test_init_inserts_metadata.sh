#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Use a temporary directory for any files we create
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Stub lualatex to run lua script's process_input_buffer by invoking lua with simple emulation
# Sanity check that the init script prepends metadata string when buffer starts with \documentclass
lua_out=$(lua - <<'LUA'
callback = { register = function(...) end }
texio = { write_nl = function(_) end }
texconfig = {}
local f = assert(io.open('../../scripts/lua/la-lua-opts-init.lua','r'))
local code = f:read('*a'); f:close()
local chunk = assert(load(code))
chunk()

-- Emulate lualatex calling process_input_buffer per line
local lines = {
  "\\documentclass{article}\n",
  "\\begin{document}\n",
  "Hi\n",
  "\\end{document}\n",
}
local out = {}
for _, line in ipairs(lines) do
  table.insert(out, assert(process_input_buffer(line)))
end
io.write(table.concat(out))
LUA
)

echo "$lua_out" > "$TMPDIR/out.tex"

# Assert empty DocumentMetadata inserted before \documentclass
grep -F -q "\\DocumentMetadata{}\\documentclass" "$TMPDIR/out.tex"

# Tagging flag path: simulate argv and ensure tagging=on is included
lua_out2=$(lua - <<'LUA'
callback = { register = function(...) end }
texio = { write_nl = function(_) end }
texconfig = {}
arg = {'--tagging'}
local f = assert(io.open('../../scripts/lua/la-lua-opts-init.lua','r'))
local code = f:read('*a'); f:close()
local chunk = assert(load(code))
chunk()

local lines = {
  "\\documentclass{article}\n",
  "\\begin{document}\n",
  "Hi\n",
  "\\end{document}\n",
}
local out = {}
for _, line in ipairs(lines) do
  table.insert(out, assert(process_input_buffer(line)))
end
io.write(table.concat(out))
LUA
)

echo "$lua_out2" > "$TMPDIR/out2.tex"
grep -F -q "tagging=on" "$TMPDIR/out2.tex"
