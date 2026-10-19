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
-- 09/09/26 - Revised by codex for new file_exclude - changed shortcuts to start with f (s used for surround)
-- 09/15/26 - Replaced snacks with Snacks where appropriate - no local used

vim.pack.add({ Gh('folke/snacks.nvim') })
require('snacks') -- Initialize the Snacks global before startup plugin scripts run.

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

  local path = Snacks.picker.util.path(ctx.item)
  if not path then
    ctx.preview:notify('Item has no `file`', 'error')
    return
  end

  local name = vim.fn.fnamemodify(path, ':t')
  ctx.preview:set_title(ctx.item.title or name)

  local entries = {}
  for file, file_type in vim.fs.dir(path) do
    file_type = file_type or Snacks.util.path_type(path .. '/' .. file)
    if file_type == 'directory' or not file_exclude.is_excluded(file) then
      entries[#entries + 1] = { file = file, type = file_type }
    end
    if file_type == 'link' then
      file_type = Snacks.util.path_type(path .. '/' .. file)
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
    local icon, icon_highlight = Snacks.util.icon(item.file, category, {
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

vim.ui.select = Snacks.picker.select
vim.ui.input = Snacks.input.input

-- stylua: ignore
Snacks.setup({

  --  ────── enable/disable modules ──────
  -- only include those not defined elsewhere

  bigfile      = { enabled = true },
  explorer     = { enabled = true },
  indent       = { enabled = true },
  notifier     = { enabled = true },
  quickfile    = { enabled = true },
  rename       = { enabled = true },
  scope        = { enabled = true, treesitter = { enabled = false }, },
  scroll       = { enabled = true },
  terminal     = { enabled = true },
  words        = { enabled = true },

  styles = {
      notification = {
        wo = { wrap = true } -- Wrap notifications
      }
    },

  --  ──────── dashboard config ────────

  dashboard    = {
    enabled  = false,
    autokeys = "123456789abcdhijklnopstuvwxyz",
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
        limit   = 9, -- max number of recent files to display
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

    -- stylua: ignore 
    preset = {
      -- header = "If it ain't broke, don't fix it!\n",
      header = "",

      keys    = {
          { key = "e", desc = "Explorer",       action = "<Leader>["},
          { key = "f", desc = "Find Files",     action = "<Leader><space>"},
          { key = "g", desc = "Grep",           action = "<Leader>fg"},
          { key = "u", desc = "Update Plugins", action = "<Leader>U" },
          { key = "y", desc = "Yazi",           action = "<Leader>y" },
          { key = "q", desc = "Quit Menu",      action = ":bwipeout"},
      },
    },
  },

  --  ────── Picker Configuration ──────

  picker       = {
    enabled   = true,
    layout    = "my_default",
    prompt    = '> ',
    matcher = {
      fuzzy     = false,
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
      my_single_narrow = { -- single pane narrow
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
      layout = { preset = 'my_single_narrow' },
    },

    files = {
      layout = { preset = 'my_single_narrow' },
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
      layout = { preset = 'my_single_narrow' },
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
      auto_close = true,
      diagnostics = true,
      follow_file = true,
      trash = true,
      replace_netrw = false,
      git_status = false, -- disabled because a bug causes false directory entry

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

local function refresh_oldfiles()
  vim.cmd('wshada')
  vim.cmd('rshada!')
end

-- Show Neovim's raw oldfiles list in its existing order.
local function oldfiles_picker()
  local items = {}
  local seen = {}

  refresh_oldfiles()

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

  Snacks.picker.pick({
    title = 'Recent',
    items = items,
    format = 'file',
    preview = 'file',
    layout = { preset = 'my_single_narrow' },
    matcher = { sort_empty = false },
  })
end

--    ╭────────────────────────────╮
--    │        key mappings        │
--    ╰────────────────────────────╯

   -- stylua: ignore 
local function maps()

Kset('n', '<Leader>fB', function() Snacks.picker.grep_buffers() end,        { desc = 'grep open buffers' })
Kset('n', '<Leader>fR', function() Snacks.picker.registers() end,           { desc = 'Registers' })
Kset('n', '<Leader>fb', function() Snacks.picker.buffers() end,             { desc = 'buffers'})
Kset('n', '<Leader>fc', function() Snacks.picker.command_history() end,     { desc = 'command History' })
-- Kset('n',  "<Leader>fC", function() Snacks.picker.colorschemes() end, {desc = "Colorschemes" })
Kset('n', '<Leader>fD', function() Snacks.picker.diagnostics_buffer() end,  { desc = 'diagnostics - buffer' })
Kset('n', '<Leader>fg', function() Snacks.picker.grep() end,                { desc = 'grep' })
Kset('n', '<Leader>fh', function() Snacks.picker.help() end,                { desc = 'help' })
Kset('n', '<Leader>fj', function() Snacks.picker.jumps() end,               { desc = 'jumps' })
Kset('n', '<Leader>fk', function() Snacks.picker.keymaps() end,             { desc = 'keymaps' })
Kset('n', '<Leader>fl', function() Snacks.picker.lines() end,               { desc = 'buffer lines' })
Kset('n', '<Leader>fm', function() Snacks.picker.marks() end,               { desc = 'marks' })
Kset('n', '<Leader>fn', function() Snacks.picker.notifications() end,       { desc = 'notifications' })
Kset('n', '<Leader>fo', function() Snacks.picker.lsp_symbols() end,         { desc = 'search document symbols' })
Kset('n', '<Leader>fp', function() Snacks.picker.resume() end,              { desc = 'resume last picker' })
Kset('n', '<Leader>fq', function() Snacks.picker.qflist() end,              { desc = 'quick fix' })
Kset('n', '<Leader>ft', function() Snacks.terminal() end,                   { desc = 'terminal'})
Kset('n', '<Leader>fu', function() Snacks.picker.undo() end,                { desc = 'undo history' })
Kset({'n', 'x'}, '<Leader>fw', function() Snacks.picker.grep_word() end,    { desc = 'grep selection or word' })

Kset('n', '<Leader>n',  function() Snacks.notifier.show_history() end, {desc = 'notification history'})

Kset('n', '<Leader>z', function()
  if vim.fn.executable('zoxide') == 1 then
    Snacks.picker.zoxide()
  else
    vim.notify('zoxide not found', vim.log.levels.WARN)
  end
end, { desc = 'Zoxide' })

-- Spelling picker
Kset('n', 'zz', function()
  require('snacks').picker.spelling({
    layout = {
      layout = {
        relative = "cursor",
        row = 1,
        col = 0,
        width = 40,
        height = 10,
        box = "vertical",
        border = "rounded",
        { win = "input", height = 1, border = "bottom" },
        { win = "list", border = "none" },
      },
    },
  })
end, { desc = 'Spelling Suggestions' })

Kset('n', '<Leader>[', function()
  Snacks.explorer({
    auto_close = true,
    layout = { preset = 'sidebar', preview = true },
  })
end, { desc = 'Snacks explorer' })

Kset('n', '<Leader>fs', function()
  Snacks.picker({
    source = 'search_history',
  })
end, { desc = 'search history' })

Kset('n', '<Leader>]', function()
  refresh_oldfiles()
  Snacks.dashboard.open()
end, { desc = 'Dashboard', silent = true })

-- Kset('n', '<Leader>fr', function()
Kset('n', '<Leader>fr', function()
  oldfiles_picker()
end, { desc = 'recent' })

Snacks.toggle.indent():map('<Leader>I')
Snacks.toggle.dim():map('<Leader>D')

-- Kset('n', '<Leader>ff', function()
Kset('n', '<Leader><space>', function()
Snacks.picker.files({
  cmd = 'fd',
  args = { '-t', 'd', '-t', 'f', '--max-depth', '1' },
  title = Myfn.short_cwd(),
  layout = { preset = 'my_default' },

  transform = function(item)
    item.dir = vim.fn.isdirectory(Snacks.picker.util.path(item)) == 1
    return exclude_file_item(item)
  end,
    sort = function(a, b)
      if a.dir ~= b.dir then
        return a.dir
      end
      return case_insensitive_file_sort(a, b)
    end,
})
end, { desc = 'files cwd only'})

Kset('n','<Leader>.', function() Snacks.scratch() end, { desc = "Toggle Scratch Buffer"})
Kset('n','<Leader>x', function() Snacks.scratch.select() end, { desc = "Select Scratch Buffer"})

end

maps()

local notification_group = vim.api.nvim_create_augroup('snacksNotifications', { clear = true })

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
