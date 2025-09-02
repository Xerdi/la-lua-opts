
modules = modules or {}
modules.xdp = {
  name = 'la-lua-opts', version = '0.0.1', date = '2025-09-02',
  description = 'La Lua Opts — Extended options for LuaLaTeX',
  author = 'Erik Nijenhuis', license = 'Copyright 2025 Xerdi'
}

local api = {
  placeholders = require('lua-placeholders'),
  git = require('gitinfo-lua'),
}

for _, a in ipairs(arg or {}) do
  local v = a:match('^%-+recipe=(.+)')
  if v then
    local ns, file = v:match('^(.-):(.*)$')
    if ns and ns ~= '' then
      api.placeholders.recipe(file, ns)
      texio.write_nl("Info: loading recipe '"..file.."' for namespace '"..ns.."'.\n")
    else
      api.placeholders.recipe(v)
      texio.write_nl("Info: loading recipe '"..v.."'.\n")
    end
  end
  v = a:match('^%-+payload=(.+)')
  if v then
    local ns, file = v:match('^(.-):(.*)$')
    if ns and ns ~= '' then
      api.placeholders.payload(file, ns)
      texio.write_nl("Info: loading payload '"..file.."' for namespace '"..ns.."'.\n")
    else
      api.placeholders.payload(v)
      texio.write_nl("Info: loading payload '"..v.."'.\n")
    end
  end
  if a:find('%-+final') then
    api.placeholders.set_strict()
  end
  v = a:match('^%-+gitdir=(.+)')
  if v then
    api.git:dir(v)
    texio.write_nl('Info: using git directory "'..v..'"\n')
  end
end

return setmetatable({}, { __index = api, __newindex = nil })
