-- simple-biscuits.lua
--
-- Drop-in replacement for code-biscuits, compatible with the treesitter rewrite
-- in Neovim 0.10+/0.11+.
--
-- Usage (lazy.nvim): place this file in your config dir and point lazy at it:
--
--   { dir = vim.fn.stdpath('config'), name = 'simple-biscuits', import = 'simple-biscuits' }
--
-- Or just require it directly from your init.lua:
--
--   require('simple-biscuits').setup({ min_block_lines = 4 })
--
-- All options and their defaults are documented in the `default_opts` table below.
--
-- Revised by claude 3/19 works as plugin or standalone

local M = {}

-- ── Namespace ────────────────────────────────────────────────────────────────
local ns = vim.api.nvim_create_namespace('simple_biscuits')

-- ── Defaults ─────────────────────────────────────────────────────────────────
local default_opts = {
  max_label = 36, -- truncate long labels to this many chars
  min_table_lines = 3, -- only annotate table constructors >= N lines
  min_block_lines = 5, -- only annotate blocks >= N lines …
  only_when_offscreen = true, -- … or when the opener has scrolled offscreen
  min_if_lines = 4, -- if-statements need at least this many lines
  highlight_group = 'Comment',
}

-- Merged opts (populated in setup())
local opts = {}

-- ── Query cache (per language) ────────────────────────────────────────────────
local query_cache = {}

-- ── Queries ───────────────────────────────────────────────────────────────────
local annotation_queries = {
  lua = [[
    (function_declaration name: (identifier) @name) @func
    (function_definition) @func
    (for_statement)        @loop
    (while_statement)      @loop
    (repeat_statement)     @loop
    (if_statement)         @conditional
    (table_constructor)    @table
  ]],
  bash = [[
    (function_definition name: (word) @name) @func
    (if_statement)   @conditional
    (while_statement) @loop
    (for_statement)   @loop
    (case_statement)  @case
  ]],
  sh = [[
    (function_definition name: (word) @name) @func
    (if_statement)   @conditional
    (while_statement) @loop
    (for_statement)   @loop
    (case_statement)  @case
  ]],
  python = [[
    (function_definition name: (identifier) @name) @func
    (class_definition   name: (identifier) @name) @class
    (for_statement)   @loop
    (while_statement) @loop
    (with_statement)  @with
    (if_statement)    @conditional
  ]],
  javascript = [[
    (function_declaration    name: (identifier) @name) @func
    (function_expression)    @func
    (arrow_function)         @func
    (class_declaration       name: (identifier) @name) @class
    (for_statement)          @loop
    (for_in_statement)       @loop
    (while_statement)        @loop
    (if_statement)           @conditional
  ]],
  typescript = [[
    (function_declaration    name: (identifier) @name) @func
    (function_expression)    @func
    (arrow_function)         @func
    (class_declaration       name: (identifier) @name) @class
    (for_statement)          @loop
    (for_in_statement)       @loop
    (while_statement)        @loop
    (if_statement)           @conditional
  ]],
}

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function get_node_text(node, bufnr)
  return vim.treesitter.get_node_text(node, bufnr)
end

local function clean_one_line(s)
  s = (s or ''):gsub('%s+', ' ')
  return s:match('^%s*(.-)%s*$') -- trim
end

local function shorten(s, max_len)
  s = clean_one_line(s)
  if max_len and #s > max_len then
    return s:sub(1, max_len - 1) .. '…'
  end
  return s
end

-- Returns true when the node spans at least `nlines` source lines.
-- node:range() returns (srow, scol, erow, ecol) with erow exclusive.
local function node_spans_at_least(node, nlines)
  local srow, _, erow = node:range()
  return (erow - srow) >= (nlines - 1)
end

-- Returns true when the opening line of `node` is not currently visible.
local function opener_offscreen(node)
  local srow = (node:range()) + 1 -- convert to 1-based
  local w0 = vim.fn.line('w0')
  local wend = vim.fn.line('w$')
  return srow < w0 or srow > wend
end

-- Core visibility test for generic blocks (loops, functions, …)
local function show_block(node)
  if node_spans_at_least(node, opts.min_block_lines) then
    return true
  end
  if opts.only_when_offscreen and opener_offscreen(node) then
    return true
  end
  return false
end

-- if-statements have their own (stricter) minimum line count.
local function show_if(node)
  if not node_spans_at_least(node, opts.min_if_lines) then
    return false
  end
  return show_block(node)
end

-- Safe is_ancestor that works across Neovim versions.
-- In 0.10+ the module-level vim.treesitter.is_ancestor was deprecated in
-- favour of the method form node:is_ancestor(other).
local function is_ancestor(ancestor, node)
  if type(ancestor.is_ancestor) == 'function' then
    return ancestor:is_ancestor(node)
  end
  -- fallback for older API
  local ok, result = pcall(vim.treesitter.is_ancestor, ancestor, node)
  return ok and result
end

-- Safely index a node field (always returns the first child or nil).
local function field1(node, fname)
  local f = node:field(fname)
  return f and f[1]
end

-- ── Lua-specific label helpers ────────────────────────────────────────────────

local function lua_if_condition_text(if_node, bufnr)
  local cond = field1(if_node, 'condition')
  if cond then
    return clean_one_line(get_node_text(cond, bufnr))
  end
  -- Fallback: first named child that isn't a block or clause
  for i = 0, if_node:named_child_count() - 1 do
    local ch = if_node:named_child(i)
    if ch then
      local t = ch:type()
      if t ~= 'block' and t ~= 'elseif_clause' and t ~= 'else_clause' then
        local txt = clean_one_line(get_node_text(ch, bufnr))
        if txt ~= '' then
          return txt
        end
      end
    end
  end
  return ''
end

-- 1) signs = { ... }  (nested field inside a table) → "signs"
local function label_from_field(table_node, bufnr)
  local p = table_node:parent()
  if not p then
    return ''
  end
  local pt = p:type()
  if pt ~= 'field' and pt ~= 'field_assignment' and pt ~= 'pair' then
    return ''
  end

  local nf = field1(p, 'name')
  if nf then
    return shorten(get_node_text(nf, bufnr), opts.max_label)
  end

  for i = 0, p:named_child_count() - 1 do
    local ch = p:named_child(i)
    if ch then
      local t = ch:type()
      if t == 'identifier' or t == 'string' then
        return shorten(get_node_text(ch, bufnr), opts.max_label)
      end
    end
  end
  return ''
end

-- 2) x = { ... }  /  local x = { ... }  → "x" / "M.x"
local function label_from_assignment(table_node, bufnr)
  local cur = table_node
  local parent = cur:parent()
  local stmt = nil

  while parent do
    local t = parent:type()
    if t == 'local_variable_declaration' or t == 'assignment_statement' then
      stmt = parent
      break
    end
    cur = parent
    parent = parent:parent()
  end
  if not stmt then
    return ''
  end

  -- Try several field names used by different grammar versions
  local function first_field(node, ...)
    for _, fname in ipairs({ ... }) do
      local v = node:field(fname)
      if v and v[1] then
        return v[1]
      end
    end
    return nil
  end

  local var_list = first_field(stmt, 'variables', 'names', 'left', 'variable_list')
    or stmt:named_child(0)
  local val_list = first_field(stmt, 'values', 'right', 'expressions', 'value')
    or stmt:named_child(1)
  if not (var_list and val_list) then
    return ''
  end

  -- Find which RHS position our table_node occupies
  local rhs_index = 0
  for i = 0, val_list:named_child_count() - 1 do
    local rhs = val_list:named_child(i)
    if rhs and (rhs == table_node or is_ancestor(rhs, table_node)) then
      rhs_index = i
      break
    end
  end

  local lhs = var_list:named_child(rhs_index) or var_list:named_child(0)
  if not lhs then
    return ''
  end
  return shorten(get_node_text(lhs, bufnr), opts.max_label)
end

-- 3) fn({ ... })  → "fn"
local function label_from_call(table_node, bufnr)
  local parent = table_node:parent()
  while parent do
    local t = parent:type()
    if t == 'function_call' or t == 'call_expression' then
      local callee = field1(parent, 'name')
        or field1(parent, 'function')
        or field1(parent, 'prefix')
        or parent:named_child(0)
      if callee then
        return shorten(get_node_text(callee, bufnr), opts.max_label)
      end
      return ''
    end
    parent = parent:parent()
  end
  return ''
end

-- 4) return { ... }  → "return"
local function label_from_return(table_node)
  local parent = table_node:parent()
  while parent do
    if parent:type() == 'return_statement' then
      return 'return'
    end
    parent = parent:parent()
  end
  return ''
end

local function lua_table_label(table_node, bufnr)
  if not node_spans_at_least(table_node, opts.min_table_lines) then
    return ''
  end

  local s = label_from_field(table_node, bufnr)
  if s ~= '' then
    return s
  end

  s = label_from_assignment(table_node, bufnr)
  if s ~= '' then
    return s
  end

  s = label_from_call(table_node, bufnr)
  if s ~= '' then
    return s
  end

  s = label_from_return(table_node)
  if s ~= '' then
    return s
  end

  return '{}'
end

-- ── Per-language annotation text ──────────────────────────────────────────────

local function annotation_for_node(node, bufnr, lang)
  local node_type = node:type() -- avoid shadowing the built-in `type()`

  -- ── Lua ──────────────────────────────────────────────────────────────────
  if lang == 'lua' then
    if node_type:match('function') then
      if not show_block(node) then
        return ''
      end
      local name_node = field1(node, 'name')
      if name_node then
        return '// function: ' .. clean_one_line(get_node_text(name_node, bufnr))
      end
      return '// end function'
    elseif node_type:match('for') then
      if not show_block(node) then
        return ''
      end
      return '// for'
    elseif node_type:match('while') then
      if not show_block(node) then
        return ''
      end
      return '// while'
    elseif node_type:match('repeat') then
      if not show_block(node) then
        return ''
      end
      return '// until -- repeat'
    elseif node_type == 'if_statement' then
      if not show_if(node) then
        return ''
      end
      local cond = lua_if_condition_text(node, bufnr)
      return (cond ~= '') and ('// if ' .. cond) or '// if'
    elseif node_type == 'table_constructor' then
      local label = lua_table_label(node, bufnr)
      if label == '' then
        return ''
      end
      return '// ' .. label
    end

  -- ── Bash / sh ─────────────────────────────────────────────────────────────
  elseif lang == 'bash' or lang == 'sh' then
    if node_type:match('function') then
      local name_node = field1(node, 'name')
      return name_node and ('} # ' .. get_node_text(name_node, bufnr)) or '} # function'
    elseif node_type:match('if') then
      return 'fi # if'
    elseif node_type:match('while') then
      return 'done # while'
    elseif node_type:match('for') then
      return 'done # for'
    elseif node_type:match('case') then
      return 'esac # case'
    end

  -- ── Python ────────────────────────────────────────────────────────────────
  elseif lang == 'python' then
    if not show_block(node) then
      return ''
    end

    if node_type == 'function_definition' then
      local name_node = field1(node, 'name')
      return name_node and ('# def ' .. get_node_text(name_node, bufnr)) or '# end def'
    elseif node_type == 'class_definition' then
      local name_node = field1(node, 'name')
      return name_node and ('# class ' .. get_node_text(name_node, bufnr)) or '# end class'
    elseif node_type == 'for_statement' then
      return '# end for'
    elseif node_type == 'while_statement' then
      return '# end while'
    elseif node_type == 'with_statement' then
      return '# end with'
    elseif node_type == 'if_statement' then
      if not show_if(node) then
        return ''
      end
      return '# end if'
    end

  -- ── JavaScript / TypeScript ───────────────────────────────────────────────
  elseif lang == 'javascript' or lang == 'typescript' then
    if not show_block(node) then
      return ''
    end

    if node_type == 'function_declaration' then
      local name_node = field1(node, 'name')
      return name_node and ('// function: ' .. get_node_text(name_node, bufnr)) or '// end function'
    elseif node_type == 'function_expression' then
      return '// end function'
    elseif node_type == 'arrow_function' then
      return '// =>'
    elseif node_type == 'class_declaration' then
      local name_node = field1(node, 'name')
      return name_node and ('// class: ' .. get_node_text(name_node, bufnr)) or '// end class'
    elseif node_type == 'for_statement' then
      return '// end for'
    elseif node_type == 'for_in_statement' then
      return '// end for…in'
    elseif node_type == 'while_statement' then
      return '// end while'
    elseif node_type == 'if_statement' then
      if not show_if(node) then
        return ''
      end
      return '// end if'
    end
  end

  return ''
end

-- ── Core update ───────────────────────────────────────────────────────────────

-- Debounce timers, keyed by bufnr
local debounce_timers = {}

local function update_biscuits(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local lang = vim.bo[bufnr].filetype
  if not annotation_queries[lang] then
    return
  end

  local parser = vim.treesitter.get_parser(bufnr, lang)
  if not parser then
    return
  end

  local tree = parser:parse()[1]
  if not tree then
    return
  end

  -- Use cached parsed query
  if not query_cache[lang] then
    local ok, q = pcall(vim.treesitter.query.parse, lang, annotation_queries[lang])
    if not ok or not q then
      return
    end
    query_cache[lang] = q
  end
  local query = query_cache[lang]

  local root = tree:root()

  -- Determine which languages place biscuits inline vs. EOL
  local inline = (lang == 'lua' or lang == 'javascript' or lang == 'typescript')

  for id, node in query:iter_captures(root, bufnr, 0, -1) do
    local capture_name = query.captures[id]
    if capture_name ~= 'name' then
      local annotation = annotation_for_node(node, bufnr, lang)
      if annotation ~= '' then
        local end_row, end_col = node:end_()

        if inline then
          vim.api.nvim_buf_set_extmark(bufnr, ns, end_row, end_col, {
            virt_text = { { ' ' .. annotation, opts.highlight_group } },
            virt_text_pos = 'inline',
          })
        else
          vim.api.nvim_buf_set_extmark(bufnr, ns, end_row, 0, {
            virt_text = { { annotation, opts.highlight_group } },
            virt_text_pos = 'eol',
          })
        end
      end
    end
  end
end

-- Schedule an update with debounce (avoids hammering the parser on every keystroke)
local DEBOUNCE_MS = 150

local function schedule_update(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local t = debounce_timers[bufnr]
  if t then
    t:stop()
    debounce_timers[bufnr] = nil
  end
  debounce_timers[bufnr] = vim.defer_fn(function()
    debounce_timers[bufnr] = nil
    update_biscuits(bufnr)
  end, DEBOUNCE_MS)
end

-- ── Public API ────────────────────────────────────────────────────────────────

-- Manually refresh biscuits for the current (or given) buffer.
-- Useful to bind to a key: vim.keymap.set('n', '<Leader>br', M.refresh)
function M.refresh(bufnr)
  update_biscuits(bufnr or vim.api.nvim_get_current_buf())
end

function M.setup(user_opts)
  opts = vim.tbl_deep_extend('force', default_opts, user_opts or {})

  -- Build the filetype pattern list from whichever languages have queries
  local ft_patterns = {}
  for lang, _ in pairs(annotation_queries) do
    -- map lang → glob pattern (covers most common extensions)
    local patterns = {
      lua = '*.lua',
      bash = '*.bash',
      sh = '*.sh',
      python = '*.py',
      javascript = '*.js',
      typescript = { '*.ts', '*.tsx' },
    }
    local p = patterns[lang]
    if p then
      if type(p) == 'table' then
        for _, v in ipairs(p) do
          ft_patterns[#ft_patterns + 1] = v
        end
      else
        ft_patterns[#ft_patterns + 1] = p
      end
    end
  end

  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'BufEnter', 'WinScrolled' }, {
    pattern = ft_patterns,
    callback = function(args)
      schedule_update(args.buf)
    end,
  })

  -- Clean up debounce timers when a buffer is deleted
  vim.api.nvim_create_autocmd('BufDelete', {
    callback = function(args)
      local t = debounce_timers[args.buf]
      if t then
        t:stop()
        debounce_timers[args.buf] = nil
      end
    end,
  })

  update_biscuits()
end

-- ── lazy.nvim plugin spec ─────────────────────────────────────────────────────
-- When this file is used directly as a lazy spec (rather than require'd),
-- the table below is returned.  The `config` key calls M.setup() so you can
-- still pass options via the `opts` key in lazy.

return {
  dir = vim.fn.stdpath('config'),
  name = 'simple-biscuits',
  event = 'BufReadPost',
  config = function(_, plugin_opts)
    M.setup(plugin_opts)
  end,
  -- expose M so callers can do require('simple-biscuits').refresh()
  _module = M,
}
