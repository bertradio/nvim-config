-- simple-biscuits.lua
--
-- To replace code-biscuits which does not work with treesitter re-write
-- code from Claude and then ChatGPT

return {
  dir = vim.fn.stdpath('config'),
  name = 'simple-biscuits',
  event = 'BufReadPost',
  config = function()
    local M = {}
    local ns = vim.api.nvim_create_namespace('simple_biscuits')

    -- Tunables
    local MAX_LABEL = 36 -- shorten long labels like code-biscuits
    local MIN_TABLE_LINES = 3 -- only annotate table constructors spanning >= 3 lines

    -- Code-biscuits-like filtering for blocks:
    local MIN_BLOCK_LINES = 5 -- only show if block spans >= this many lines
    local ONLY_WHEN_OPENER_OFFSCREEN = true -- show when opener is not visible in window

    -- NEW: Do not annotate short if-statements
    local MIN_IF_LINES = 4 -- only show if biscuit when the if spans >= 4 lines

    -- Node types we want to annotate
    local function get_annotation_queries()
      return {
        lua = [[
          (function_declaration name: (identifier) @name) @func
          (function_definition) @func
          (for_statement) @loop
          (while_statement) @loop
          (repeat_statement) @loop
          (if_statement) @conditional
          (table_constructor) @table
        ]],
        bash = [[
          (function_definition name: (word) @name) @func
          (if_statement) @conditional
          (while_statement) @loop
          (for_statement) @loop
          (case_statement) @case
        ]],
      }
    end

    local function get_node_text(node, bufnr)
      return vim.treesitter.get_node_text(node, bufnr)
    end

    local function clean_one_line(s)
      s = (s or ''):gsub('%s+', ' ')
      s = s:gsub('^%s+', ''):gsub('%s+$', '')
      return s
    end

    local function shorten(s, max_len)
      s = clean_one_line(s)
      if max_len and #s > max_len then
        return s:sub(1, max_len - 1) .. '…'
      end
      return s
    end

    -- "more than 2 lines" => at least 3 lines
    local function node_spans_at_least_n_lines(node, nlines)
      local srow, _, erow, _ = node:range() -- erow is exclusive
      local lines = erow - srow
      return lines >= (nlines - 1)
    end

    -- Is the block opener line currently visible in the active window?
    local function opener_is_offscreen(node)
      local srow = select(1, node:range()) + 1 -- 1-based
      local w0 = vim.fn.line('w0')
      local w_last = vim.fn.line('w$')
      return srow < w0 or srow > w_last
    end

    local function should_show_block_biscuit(node)
      if node_spans_at_least_n_lines(node, MIN_BLOCK_LINES) then
        return true
      end
      if ONLY_WHEN_OPENER_OFFSCREEN and opener_is_offscreen(node) then
        return true
      end
      return false
    end

    -- NEW: if statements must be >= MIN_IF_LINES AND pass normal block filter
    local function should_show_if_biscuit(node)
      if not node_spans_at_least_n_lines(node, MIN_IF_LINES) then
        return false
      end
      return should_show_block_biscuit(node)
    end

    -- Extract condition text from a Lua if_statement (best-effort across grammar versions)
    local function lua_if_condition_text(if_node, bufnr)
      local cond = if_node:field('condition')
      if cond and cond[1] then
        return clean_one_line(get_node_text(cond[1], bufnr))
      end

      -- fallback: pick first named child that isn't a block/clause
      local n = if_node:named_child_count()
      for i = 0, n - 1 do
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

    -- 1) Field context: signs = { ... } inside a table => label "signs"
    local function table_label_from_field_context(table_node, bufnr)
      local p = table_node:parent()
      if not p then
        return ''
      end

      -- Different lua grammars: "field", "field_assignment", etc.
      local pt = p:type()
      if pt ~= 'field' and pt ~= 'field_assignment' and pt ~= 'pair' then
        return ''
      end

      -- Prefer explicit field("name") if present
      local name_field = p:field('name')
      if name_field and name_field[1] then
        return shorten(get_node_text(name_field[1], bufnr), MAX_LABEL)
      end

      -- Fallback: look for an identifier/string key among named children
      local n = p:named_child_count()
      for i = 0, n - 1 do
        local ch = p:named_child(i)
        if ch then
          local t = ch:type()
          if t == 'identifier' or t == 'string' then
            return shorten(get_node_text(ch, bufnr), MAX_LABEL)
          end
        end
      end

      return ''
    end

    -- 2) Assignment/local context: x = { ... } => label full lhs expression "x" / "M.x" / "x[i]"
    -- Supports multi-assign best-effort by matching RHS index.
    local function table_label_from_assignment_context(table_node, bufnr)
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

      local vars = stmt:field('variables')
      if not (vars and vars[1]) then
        vars = stmt:field('names')
      end
      if not (vars and vars[1]) then
        vars = stmt:field('left')
      end
      if not (vars and vars[1]) then
        vars = stmt:field('variable_list')
      end

      local vals = stmt:field('values')
      if not (vals and vals[1]) then
        vals = stmt:field('right')
      end
      if not (vals and vals[1]) then
        vals = stmt:field('expressions')
      end
      if not (vals and vals[1]) then
        vals = stmt:field('value')
      end

      local var_list = vars and vars[1] or nil
      local val_list = vals and vals[1] or nil

      if not var_list then
        var_list = stmt:named_child(0)
      end
      if not val_list then
        val_list = stmt:named_child(1)
      end
      if not (var_list and val_list) then
        return ''
      end

      local rhs_index = nil
      local rhs_n = val_list:named_child_count()
      for i = 0, rhs_n - 1 do
        local rhs = val_list:named_child(i)
        if rhs and (rhs == table_node or vim.treesitter.is_ancestor(rhs, table_node)) then
          rhs_index = i
          break
        end
      end
      if rhs_index == nil then
        rhs_index = 0
      end

      local lhs = var_list:named_child(rhs_index) or var_list:named_child(0)
      if not lhs then
        return ''
      end

      return shorten(get_node_text(lhs, bufnr), MAX_LABEL)
    end

    -- 3) Function-call arg context: fn({ ... }) => label "fn"
    local function table_label_from_call_context(table_node, bufnr)
      local parent = table_node:parent()
      while parent do
        local t = parent:type()
        -- Different grammars call these differently; include common ones.
        if t == 'function_call' or t == 'call_expression' then
          -- Heuristic: the callee is usually the first named child OR field("name"/"function"/"prefix")
          local callee = (parent:field('name') and parent:field('name')[1])
            or (parent:field('function') and parent:field('function')[1])
            or (parent:field('prefix') and parent:field('prefix')[1])
            or parent:named_child(0)

          if callee then
            return shorten(get_node_text(callee, bufnr), MAX_LABEL)
          end
          return ''
        end
        parent = parent:parent()
      end
      return ''
    end

    -- 4) Return context: return { ... } => label "return"
    local function table_label_from_return_context(table_node)
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
      -- Only annotate multi-line tables (3+ lines)
      if not node_spans_at_least_n_lines(table_node, MIN_TABLE_LINES) then
        return ''
      end

      -- Priority like code-biscuits: field key > assignment lhs > call callee > return
      local s = table_label_from_field_context(table_node, bufnr)
      if s ~= '' then
        return s
      end

      s = table_label_from_assignment_context(table_node, bufnr)
      if s ~= '' then
        return s
      end

      s = table_label_from_call_context(table_node, bufnr)
      if s ~= '' then
        return s
      end

      s = table_label_from_return_context(table_node)
      if s ~= '' then
        return s
      end

      return '{}'
    end

    local function get_annotation_text(node, bufnr, lang)
      local type = node:type()
      local text = ''

      if lang == 'lua' then
        if type:match('function') then
          if not should_show_block_biscuit(node) then
            return ''
          end
          local name_node = node:field('name')[1]
          if name_node then
            text = '// function: ' .. clean_one_line(get_node_text(name_node, bufnr))
          else
            text = '// end function'
          end
        elseif type:match('for') then
          if not should_show_block_biscuit(node) then
            return ''
          end
          text = '// for'
        elseif type:match('while') then
          if not should_show_block_biscuit(node) then
            return ''
          end
          text = '// while'
        elseif type:match('repeat') then
          if not should_show_block_biscuit(node) then
            return ''
          end
          text = '// until -- repeat'
        elseif type == 'if_statement' then
          -- NEW: only show if >= 4 lines, then apply normal code-biscuits-like filter
          if not should_show_if_biscuit(node) then
            return ''
          end
          local cond_txt = lua_if_condition_text(node, bufnr)
          text = (cond_txt ~= '') and ('// if ' .. cond_txt) or '// if'
        elseif type == 'table_constructor' then
          local label = lua_table_label(node, bufnr)
          if label == '' then
            return ''
          end
          text = '// ' .. label
        end
      elseif lang == 'bash' or lang == 'sh' then
        if type:match('function') then
          local name_node = node:field('name')[1]
          if name_node then
            text = '} # ' .. get_node_text(name_node, bufnr)
          else
            text = '} # function'
          end
        elseif type:match('if') then
          text = 'fi # if'
        elseif type:match('while') then
          text = 'done # while'
        elseif type:match('for') then
          text = 'done # for'
        elseif type:match('case') then
          text = 'esac # case'
        end
      end

      return text
    end

    local function update_biscuits(bufnr)
      bufnr = bufnr or vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

      local lang = vim.bo[bufnr].filetype
      local queries = get_annotation_queries()
      if not queries[lang] then
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

      local query = vim.treesitter.query.parse(lang, queries[lang])
      local root = tree:root()

      for id, node in query:iter_captures(root, bufnr, 0, -1) do
        local capture_name = query.captures[id]
        if capture_name ~= 'name' then
          local annotation = get_annotation_text(node, bufnr, lang)
          if annotation ~= '' then
            local end_row, end_col = node:end_()

            if lang == 'lua' then
              -- Inline after the closing token (`end`, `}`, `until`, etc.)
              vim.api.nvim_buf_set_extmark(bufnr, ns, end_row, end_col, {
                virt_text = { { ' ' .. annotation, 'Comment' } },
                virt_text_pos = 'inline',
              })
            else
              -- Bash: EOL behavior
              vim.api.nvim_buf_set_extmark(bufnr, ns, end_row, 0, {
                virt_text = { { annotation, 'Comment' } },
                virt_text_pos = 'eol',
              })
            end
          end
        end
      end
    end

    function M.setup()
      vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'BufEnter', 'WinScrolled' }, {
        pattern = { '*.lua', '*.sh', '*.bash' },
        callback = function(args)
          update_biscuits(args.buf)
        end,
      })

      update_biscuits()
    end

    M.setup()
  end,
}
