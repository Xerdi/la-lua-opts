-- Public domain.
-- Originally written by Erik Nijenhuis, 2025.

texconfig = texconfig or require('texconfig')
texio = texio or require('texio')

modules = modules or {}
modules['la-lua-opts-init'] = {
  name = 'la-lua-opts-init', version = '0.0.1', date = '2025-09-02',
  description = 'La Lua Opts — Extended options for LuaLaTeX',
  author = 'Erik Nijenhuis', license = 'Copyright 2025 Xerdi'
}

local written = false

local function parse_argv()
  local ok, st = pcall(function()
    return status
  end)
  local argv = {}
  if ok and type(st) == 'table' and type(st.argv) == 'table' then
    argv = st.argv
  elseif type(arg) == 'table' then
    argv = arg
  end
  local opts = {}
  for _, v in ipairs(argv) do
    local x = v:match('^%-%-lang=(.+)')
    if x then
      opts.lang = x
    end
    x = v:match('^%-%-pdfversion=(.+)')
    if x then
      opts.pdfversion = x
    end
    x = v:match('^%-%-pdfstandard=(.+)')
    if x then
      opts.pdfstandards = opts.pdfstandards or {}
      table.insert(opts.pdfstandards, x)
    end
    if v == '--uncompress' then
      opts.uncompress = true
    end
    if v == '--no-uncompress' then
      opts.uncompress = false
    end
    if v == '--tagging' or v == '--tagging=on' then
      opts.tagging = true
    end
    if v == '--tagging=off' then
      opts.tagging = false
    end
  end
  return opts
end

function process_input_buffer(buffer)
  if written or type(buffer) ~= 'string' or #buffer == 0 or buffer:sub(1,1) == '%' then
    return buffer
  end
  local first_line = buffer:match('([^\n]*)') or buffer
  if first_line:sub(1, #"\\DocumentMetadata") == "\\DocumentMetadata" then
    written = true
    return buffer
  end
  if buffer:sub(1, #"\\documentclass") == "\\documentclass" then
    local o = parse_argv()
    local t = {}
    if o.lang then
      table.insert(t, 'lang='..o.lang)
    end
    if o.pdfversion then
      table.insert(t, 'pdfversion='..o.pdfversion)
    end
    if o.pdfstandards then
      for _, s in ipairs(o.pdfstandards) do
        table.insert(t, 'pdfstandard='..s)
      end
    end
    if o.uncompress then
      table.insert(t, 'uncompress')
    end
    if o.tagging then
      table.insert(t, 'tagging=on')
      texio.write_nl('(la-lua-opts-init) PDF tagging enabled via flag: adding tagging=on to DocumentMetadata.')
    end
    local meta = '\\DocumentMetadata{'..table.concat(t, ',')..'}'
    texio.write_nl('(la-lua-opts-init) Prepending document metadata before \\documentclass: '..meta)
    written = true
    return meta .. buffer
  end
  written = true
  texio.write_nl('(la-lua-opts-init) Document metadata isn\'t prepended (buffer doesn\'t start with \\documentclass, but '..buffer..').')
  return buffer
end

callback.register('process_input_buffer', process_input_buffer)

texconfig.kpse_init = true
texconfig.halt_on_error = true
texconfig.shell_escape = false
texconfig.shell_restricted = true
