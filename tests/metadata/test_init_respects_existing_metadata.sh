#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

lua_out=$(lua - <<'LUA'
callback = { register = function(...) end }
texio = { write_nl = function(_) end }
texconfig = {}
local f = assert(io.open('../../scripts/lua/la-lua-opts-init.lua','r'))
local code = f:read('*a'); f:close()
local chunk = assert(load(code))
chunk()

-- Feed the file per line to emulate lualatex
local fh = assert(io.open('with_metadata.tex','r'))
local out = {}
for line in fh:lines() do
  table.insert(out, assert(process_input_buffer(line .. "\n")))
end
fh:close()
io.write(table.concat(out))
LUA
)

# Should leave input unchanged (starts with \DocumentMetadata)
grep -F -q "\\DocumentMetadata{lang=en}" <<<"$lua_out" || exit 1

# If the input starts with a comment, it should remain unchanged and not insert metadata
lua_out2=$(lua - <<'LUA'
callback = { register = function(...) end }
texio = { write_nl = function(_) end }
texconfig = {}
local f = assert(io.open('../../scripts/lua/la-lua-opts-init.lua','r'))
local code = f:read('*a'); f:close()
local chunk = assert(load(code))
chunk()
local fh = assert(io.open('with_comment.tex','r'))
local out = {}
for line in fh:lines() do
  table.insert(out, assert(process_input_buffer(line .. "\n")))
end
fh:close()
io.write(table.concat(out))
LUA
)

# Should start with % (unchanged)
[[ "$lua_out2" == %* ]] 2>/dev/null || grep -F -q "^%" <<<"$lua_out2"
