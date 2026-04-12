-- snacks-config.lua
-- changed from lazy to vim.pack 3-30-26

if Myfn and Myfn.is_windows and Myfn.is_windows() then
  vim.o.shell = 'pwsh.exe'
  vim.o.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
  vim.o.shellquote = ''
  vim.o.shellxquote = ''
end

vim.pack.add({ Gh('folke/snacks.nvim') })

require('snacks').setup({
  bigfile = { enabled = true },
  input = { enabled = true },
  lazygit = { enabled = true },
  quickfile = { enabled = true },
  rename = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },

  statuscolumn = {
    enabled = true,
    segments = {
      { text = { '%s' }, click = 'v:lua.scsa' },
      { text = { '%c' } },
      {
        text = {
          function()
            if vim.v.virtnum ~= 0 then
              return ''
            end
            if vim.wo.relativenumber then
              local rel = math.abs(vim.fn.line('.') - vim.v.lnum)
              return (rel == 0 and vim.v.lnum or rel) .. ' '
            end
            return string.format('%d ', vim.v.lnum)
          end,
        },
        click = 'v:lua.scna',
      },
    },
  },

  dashboard = { enabled = false },
  image = { enabled = false },
  indent = { enabled = false },
  notifier = { enabled = false },
  terminal = { enabled = false },

  picker = {
    enabled = true,
    prompt = '> ',
    ui_select = true,
    exclude = require('config.file_exclude'),
    layout = {
      layout = {
        box = 'horizontal',
        width = 0.9,
        height = 0.8,
        {
          box = 'vertical',
          border = 'rounded',
          title = '{source} {live} {flags}',
          title_pos = 'center',
          { win = 'input', height = 1, border = 'bottom' },
          { win = 'list', border = 'none' },
        },
        {
          win = 'preview',
          border = 'rounded',
          width = 0.65,
          title = '{preview}',
        },
      },
    },

    win = {
      preview = {
        wo = {
          number = false,
          relativenumber = false,
          signcolumn = 'no',
        },
      },
      input = {
        keys = {
          ['<PageDown>'] = { 'list_scroll_down', mode = { 'i', 'n' } },
          ['<PageUp>'] = { 'list_scroll_up', mode = { 'i', 'n' } },
        },
      },
    },
  },
})
