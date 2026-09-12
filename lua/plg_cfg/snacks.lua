--    ╭────────────────────────────╮
--    │         snacks.lua         │
--    ╰────────────────────────────╯

-- Explorer: Removed custom copy and move actions since they did not seem stable
-- Just using noice
-- 05/01/26 - set up dashboard to be default on start
-- 05/02/26 - added code per ChatGPT to ensure snacks.recent is kept up to date
--            but may be related to nvim 13. Not a problem with 12.2
-- 05/31/26 - moved notifications to bottom
-- 06/01/26 - set up dashboard to replace mini.starter
-- 06/05/26 - Tweaks as per claude
-- 07/14/26 - added notifier to replace noice in part
-- 07/19/26 - removed notifier decided to go back to system notifications - all in one place
-- 09/09/26 - Revised by codex for new file_exclude - changed shortcuts to start with f (s used for surround)

-- vim.pack.add({ Gh('nvim-tree/nvim-web-devicons') })
vim.pack.add({ Gh('folke/snacks.nvim') })

local snacks = require('snacks')

-- setup for excluding files from pickers
local file_exclude = require('file_exclude')
local excluded = {}

for extension in pairs(file_exclude.extensions) do
  excluded[#excluded + 1] = '*.' .. extension
end

table.sort(excluded)

local function exclude_file_item(item)
  return item.dir or not file_exclude.is_excluded(item.file or item.text)
end

local preview_namespace = vim.api.nvim_create_namespace('snacks.picker.preview')
local picker_preview = require('snacks.picker.preview')

-- Directory previews bypass the picker source's exclude and transform options.
-- Keep their contents consistent with the filtered files and explorer lists.
function picker_preview.directory(ctx)
  ctx.preview:reset()
  ctx.preview:minimal()

  local path = snacks.picker.util.path(ctx.item)
  if not path then
    ctx.preview:notify('Item has no `file`', 'error')
    return
  end

  local name = vim.fn.fnamemodify(path, ':t')
  ctx.preview:set_title(ctx.item.title or name)

  local entries = {}
  for file, file_type in vim.fs.dir(path) do
    file_type = file_type or snacks.util.path_type(path .. '/' .. file)
    if file_type == 'directory' or not file_exclude.is_excluded(file) then
      entries[#entries + 1] = { file = file, type = file_type }
    end
  end

  ctx.preview:set_lines(vim.split(string.rep('\n', #entries), '\n'))
  table.sort(entries, function(a, b)
    if a.type ~= b.type then
      return a.type == 'directory'
    end
    return a.file < b.file
  end)

  for index, item in ipairs(entries) do
    local is_dir = item.type == 'directory'
    local category = is_dir and 'directory' or 'file'
    local highlight = is_dir and 'Directory' or nil
    local icon, icon_highlight = snacks.util.icon(item.file, category, {
      fallback = ctx.picker.opts.icons.files,
    })

    vim.api.nvim_buf_set_extmark(ctx.buf, preview_namespace, index - 1, 0, {
      virt_text = { { icon .. ' ', icon_highlight }, { item.file, highlight } },
    })
  end
end

local function casefold(value)
  return (value or ''):lower()
end

local function case_insensitive_file_sort(a, b)
  local a_score = a.score or 0
  local b_score = b.score or 0

  if a_score ~= b_score then
    return a_score > b_score
  end

  local a_name = casefold(a.file or a.text)
  local b_name = casefold(b.file or b.text)

  if a_name ~= b_name then
    return a_name < b_name
  end

  return (a.idx or math.huge) < (b.idx or math.huge)
end

local explorer_tree = require('snacks.explorer.tree')

-- Snacks hard-codes a case-sensitive comparison in Tree:walk().
-- Override the traversal so tree order and branch markers stay in sync.
function explorer_tree:walk(node, fn, opts)
  local abort = fn(node)
  if abort ~= nil then
    return abort
  end

  local children = vim.tbl_values(node.children)
  table.sort(children, function(a, b)
    if a.dir ~= b.dir then
      return a.dir
    end

    local a_name = casefold(a.name)
    local b_name = casefold(b.name)
    if a_name ~= b_name then
      return a_name < b_name
    end

    return a.name < b.name
  end)

  for index, child in ipairs(children) do
    child.last = index == #children
    abort = false
    if child.dir and (child.open or (opts and opts.all)) then
      abort = self:walk(child, fn, opts)
    else
      abort = fn(child)
    end
    if abort then
      return true
    end
  end

  return false
end

local function case_insensitive_explorer_sort(a, b)
  local a_name = casefold(a.sort)
  local b_name = casefold(b.sort)

  if a_name ~= b_name then
    return a_name < b_name
  end

  return (a.idx or math.huge) < (b.idx or math.huge)
end

vim.ui.select = snacks.picker.select
vim.ui.input = snacks.input.input

-- stylua: ignore
snacks.setup({

  --  ────── enable/disable modules ──────
  -- only include those not defined elsewhere

  bigfile      = { enabled = true },
  explorer     = { enabled = true },
  indent       = { enabled = true },
  input        = { enabled = true, border = 'double' },
  notifier     = { enabled = true },
  quickfile    = { enabled = true },
  rename       = { enabled = true },
  scope        = { enabled = true },
  scroll       = { enabled = true },
  terminal     = { enabled = true },

  image        = { enabled = false },
  lazygit      = { enabled = false },
  -- scope        = { enabled = false },
  words        = { enabled = false },

  --  ──────── dashboard config ────────

  dashboard    = {
    enabled  = false,
    autokeys = "123456789abcdefghijklmnopqrstuvwxyz",
    width    = 50,
    row      = 4,

    sections = {
      -- {
      --   header  = "If it ain't broke, don't fix it!\n",
      --   section = "header",
      -- },
      {
        section = "recent_files",
        cwd = false,
        padding = 0,
        indent  = 2,
        limit   = 10, -- max number of recent files to display
      },
      -- Empty text row instead of dynamic section padding
      -- inserts line between recent and keys
      { text = "" },
      {
        section = "keys",
        padding = 0,
        indent  = 2
      },
    },

    preset = {
      -- header = "If it ain't broke, don't fix it!\n",
      header = "",

      keys = {
        { key = "e", desc = "Explorer", action = "<Leader>x"},
        { key = "f", desc = "Find Files",
          action = function()
            snacks.picker.files({ title = Myfn.short_cwd() })
          end },
        { key = "g", desc = "Grep",       action = function() snacks.picker.grep() end },
        { key = "m", desc = "Mini-Files", action = "<Leader>["},
        { key = "r",
          desc = "Recent Files",
          action = "<leader>fr" },
          -- action = function()
          --   vim.cmd('wshada')
          --   vim.cmd('rshada!')
          --   snacks.picker.recent({ refresh = true, file_pos = "main" })
          -- end },
        --   { key = "y", desc = "Yazi",        action = "<Leader>y" },
        { key = "q", desc = "Quit Menu", action = ":bwipeout" },
      },
    },
  },

  --  ────── Picker Configuration ──────

  picker       = {
    enabled   = true,
    layout    = "my_default",
    prompt    = '> ',
    ui_select = true,
    styles = {
      notification = {
        wo = { wrap = true } -- Wrap notifications
      }
    },
    win       = {
      border = "double",
      preview = {
        wo = { number = false, relativenumber = false, signcolumn = 'no' },
      },
      input = {
        keys = {
          ['<PageUp>']   = { 'list_scroll_up', mode = { 'i', 'n' } },
          ['<PageDown>'] = { 'list_scroll_down', mode = { 'i', 'n' } },
        },
      },
    },

    --  ─────── my custom layouts ────────

    layouts   = {
      my_default = { -- 2 pane standard
        layout = {
          box    = 'horizontal',
          width  = 0.85,
          height = 0.85,
          {
            box       = 'vertical',
            border    = 'rounded',
            title     = '{source} {live} {flags}',
            title_pos = 'center',
            { win = 'input',     height = 1,      border = 'bottom' },
            { win = 'list',      border = 'none' },
          },
          { win = 'preview', border = 'rounded', width = 0.65, title = '{preview}' },
        },
      },
      my_spelling = { -- single pane narrow
        layout = {
          box    = 'horizontal',
          width  = 0.5,
          height = 0.7,
          {
            box       = 'vertical',
            border    = 'rounded',
            title     = '{source} {live} {flags}',
            title_pos = 'center',
            { win = 'input',     height = 1,      border = 'bottom' },
            { win = 'list',      border = 'none' },
          },
        },
      },
      my_keymaps = { -- single pane wide
        layout = {
          box    = 'horizontal',
          width  = 0.9,
          height = 0.7,
          {
            box       = 'vertical',
            border    = 'rounded',
            title     = '{source} {live} {flags}',
            title_pos = 'center',
            { win = 'input',     height = 1,      border = 'bottom' },
            { win = 'list',      border = 'none' },
          },
        },
      },
    },

    --  ───── defaults for various pickers ─────

  sources = {

    buffers = {
      layout = { preset = 'my_default' },
    },

    command_history = {
      layout = { preset = 'my_spelling' },
    },

    files = {
      layout = { preset = 'my_default' },
      exclude = excluded,
      transform = exclude_file_item,
      matcher = { sort_empty = true },
      sort = case_insensitive_file_sort,
    },

    grep = {
      layout = { preset = 'my_default' },
      exclude = excluded,
      transform = exclude_file_item,
    },

    help = {
      layout = { preset = 'my_default' },
    },

    jumps = {
      layout = { preset = 'my_default' },
    },

    keymaps = {
      layout = { preset = 'my_keymaps' },
    },

    lines = {
      layout = { preset = 'my_default' },
    },

    lsp_symbols = {
      layout = { preset = 'my_default' },
    },

    marks = {
      layout = { preset = 'default' },
    },

    qflist = {
      layout = { preset = 'my_default' },
    },

    recent = {
      layout = { preset = 'my_default' },
      filter = { cwd = false },
      file_pos = 'main',
    },

    registers = {
      layout = { preset = 'my_default' },
    },

    search_history = {
      layout = { preset = 'my_spelling' },
    },

    undo = {
      layout = { preset = 'my_default' },
    },

    zoxide = {
      layout = { preset = 'my_keymaps' },
    },

    explorer = {

      exclude = excluded,
      transform = exclude_file_item,
      matcher = { sort_empty = true },
      sort = case_insensitive_explorer_sort,

      layout = {
        preview = true,
        layout = {
          box = 'horizontal',
          height = 0.85,
          width = 0.90,
          {
            border = 'double',
            box = 'vertical',
            title = '{source} {live} {flags}',
            title_pos = 'center',
            { win = 'input', height = 1, border = 'bottom' },
            { win = 'list', border = 'none' },
          },
          {
            win = 'preview',
            border = 'double',
            width = 0.65,
            title = '{preview}',
          },
        },
      },

      win = {
        list = {
          keys = {
            ['<left>'] = 'explorer_up',
            ['g.'] = 'toggle_hidden',
            ['<PageUp>'] = {
              'list_scroll_up',
              mode = { 'i', 'n' },
            },
            ['<PageDown>'] = {
              'list_scroll_down',
              mode = { 'i', 'n' },
            },
          },
        },
      },

      auto_close = true,
      diagnostics = true,
      follow_file = true,

      formatters = {
        file = { filename_only = true },
        tree = true,
      },
    },
  }
}
})

--  ─────────── end snacks configs ───────────

--    ╭────────────────────────────╮
--    │       custom pickers       │
--    ╰────────────────────────────╯

-- Show Neovim's raw oldfiles list in its existing order.
local function oldfiles_picker()
  local items = {}
  local seen = {}

  for _, file in ipairs(vim.v.oldfiles) do
    file = vim.fn.fnamemodify(file, ':p')

    if not seen[file] and vim.fn.filereadable(file) == 1 and not file_exclude.is_excluded(file) then
      seen[file] = true

      items[#items + 1] = {
        idx = #items + 1,
        file = file,
        text = file,
      }
    end
  end

  snacks.picker.pick({
    title = 'Recent',
    items = items,
    format = 'file',
    preview = 'file',
    layout = { preset = 'my_default' },
    matcher = { sort_empty = false },
  })
end

--    ╭────────────────────────────╮
--    │        key mappings        │
--    ╰────────────────────────────╯

-- stylua: ignore 
local function maps()

  Kset('n', '<Leader>fR', function() snacks.picker.registers() end,            { desc = 'registers' })
  Kset('n', '<Leader>fb', function() snacks.picker.buffers() end,              { desc = 'buffers'})
  Kset('n', '<Leader>fd', function() snacks.picker.diagnostics_buffer() end,   { desc = 'diagnostics - buffer' })
  Kset('n', '<Leader>fg', function() snacks.picker.grep() end,                 { desc = 'grep' })
  Kset('n', '<Leader>fh', function() snacks.picker.help() end,                 { desc = 'help' })
  Kset('n', '<Leader>fj', function() snacks.picker.jumps() end,                { desc = 'jumps' })
  Kset('n', '<Leader>fl', function() snacks.picker.lines() end,                { desc = 'buffer lines' })
  Kset('n', '<Leader>fm', function() snacks.picker.marks() end,                { desc = 'marks' })
  Kset('n', '<Leader>fn', function() snacks.picker.notifications() end,        { desc = 'notifications' })
  Kset('n', '<Leader>fq', function() snacks.picker.qflist() end,               { desc = 'quick fix' })
  Kset('n', '<Leader>ft', function() snacks.terminal() end,                    {desc = 'terminal'})
  Kset('n', '<Leader>fu', function() snacks.picker.undo() end,                 { desc = 'undo history' })
  Kset('n', '<Leader>z',  function() snacks.picker.zoxide() end,               { desc = 'Zoxide' })

  Kset('n', '<Leader>fk', function()
    snacks.picker.keymaps()
  end, { desc = 'keymaps' })

  Kset('n', '<Leader>x', function()
    snacks.explorer({
      auto_close = true,
      layout = { preset = 'sidebar', preview = true },
    })
  end, { desc = 'Explorer' })

  Kset('n', '<Leader>fs', function()
    snacks.picker({
      source = 'search_history',
    })
  end, { desc = 'search history' })

  Kset('n', '<Leader>fD', function()
    vim.cmd('wshada')
    vim.cmd('rshada!')
    snacks.dashboard.open()
  end, { desc = 'Dashboard (Synced)', silent = true })

  Kset('n', '<Leader>fr', function()
    vim.cmd('wshada')
    vim.cmd('rshada!')
    oldfiles_picker()
  end, { desc = 'Old Files (Synced)' })

  Kset('n', '<Leader>fw', function()
    snacks.picker.grep_word()
  end, { desc = 'grep selection or word' })

  Kset('n', '<leader>i', function()
    if snacks.indent.enabled then
      snacks.indent.disable()
    else
      snacks.indent.enable()
    end
  end, { desc = 'Toggle indent Guides' })

  Kset('n', '<Leader>ff', function()
    snacks.picker.files({
      title = Myfn.short_cwd(),
    })
  end, { desc = 'files cwd' })

  -- Kset('n', '<Leader><space>', function()
  --   snacks.picker({
  --     source = 'files',
  --     title = Myfn.short_cwd(),
  --   })
  -- end, { desc = 'Files cwd' })

  Kset('n', '<Leader>fo', function()
    snacks.picker.lsp_symbols()
  end, { desc = 'Search document symbols' })

  Kset('n', '<Leader>fp', function()
    snacks.picker.resume()
  end, { desc = 'resume last picker' })

  Kset('n', '<Leader>fB', function()
    snacks.picker.grep_buffers()
  end, { desc = 'grep open buffers' })

  Kset('n', '<Leader>n', '<cmd>lua snacks.notifier.show_history()<cr>', {desc = 'notification history'})

end

maps()

local notification_group = vim.api.nvim_create_augroup('SnacksNotifications', { clear = true })

-- Colorscheme changed
vim.api.nvim_create_autocmd('ColorScheme', {
  group = notification_group,
  callback = function()
    vim.notify(('Colorscheme: %s'):format(vim.g.colors_name or 'unknown'), vim.log.levels.INFO, {
      title = 'Theme',
    })
  end,
})

-- Recording a macro
vim.api.nvim_create_autocmd('RecordingEnter', {
  group = notification_group,
  callback = function()
    vim.notify(('Recording macro @%s'):format(vim.fn.reg_recording()), vim.log.levels.INFO, {
      title = 'Macro',
    })
  end,
})

vim.api.nvim_create_autocmd('RecordingLeave', {
  group = notification_group,
  callback = function()
    vim.defer_fn(function()
      vim.notify('Macro recording finished', vim.log.levels.INFO, { title = 'Macro' })
    end, 50)
  end,
})

-- Optionally notify when text is yanked
vim.api.nvim_create_autocmd('TextYankPost', {
  group = notification_group,
  callback = function()
    local count = vim.v.event.regcontents and #vim.v.event.regcontents or 0
    if count > 5 then
      vim.notify(('Yanked %d lines'):format(count), vim.log.levels.INFO, {
        title = 'Yank',
      })
    end
  end,
})
