-- snacks-config.lua

if Myfn and Myfn.is_windows and Myfn.is_windows() then
  vim.o.shell = 'pwsh.exe'
  vim.o.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
  vim.o.shellquote = ''
  vim.o.shellxquote = ''
end

vim.pack.add({
  'https://github.com/folke/snacks.nvim',
})

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
      { text = { '%s' }, click = 'v:lua.ScSa' },
      { text = { '%C' } },
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
        click = 'v:lua.ScNa',
      },
    },
  },

  dashboard = { enabled = false },
  image = { enabled = false },
  indent = { enabled = false },
  notifier = { enabled = false },
  terminal = { enabled = false },
})
