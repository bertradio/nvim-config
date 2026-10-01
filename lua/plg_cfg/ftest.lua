--    ╭────────────────────────────╮
--    │        TESTING FILE        │
--    ╰────────────────────────────╯

vim.pack.add({ { src = Gh('catppuccin/nvim'), name = 'catppuccin' } })

-- Set before setup and colorscheme to ensure true color is active
vim.opt.termguicolors = true

require('catppuccin').setup({
  auto_integrations = true,
  flavour = 'mocha',
  show_end_of_buffer = false,
  styles = { comments = { 'italic' } },
  transparent_background = false,

  highlight_overrides = {

    mocha = function(colors)
      return {
        CursorLine = { bg = colors.surface0 },
        LineNr = { bg = colors.mantle, fg = colors.overlay1 },
        Comment = {
          bg = colors.mantle,
          style = { 'italic' },
        },

        Cursor = { bg = '#a8a8a8' },
        Folded = { fg = '#cccccc', bg = '#154360', italic = true },
        FoldColumn = { bg = '#262626', fg = colors.sapphire },
      }
    end,
  },

  integrations = {
    blink_cmp = { style = 'bordered' },
    markdown = true,
    mini = { enabled = true },
    noice = true,
    rainbow_delimiters = true,
  },
})

vim.cmd.colorscheme('catppuccin-mocha')
-- vim.cmd.colorscheme('catppuccin')
