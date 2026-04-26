--    ╭────────────────────────────╮
--    │       catppuccin.lua       │
--    ╰────────────────────────────╯

-- Updated by Perplexity 4-23-26:
--                  Removed redundant EndOfBuffer custom_highlight (show_end_of_buffer=false
--                  already handles it), removed duplicate Folded from 'all' block,
--                  removed no_italic/no_bold (defaults), added fzf integration,
--                  removed likely-invalid blink_indent key.

-- need to name it otherwise vim.pack.add assigns the name 'nvim'
-- vim.pack.add({ { src = Gh('catppuccin/nvim'), name = 'catppuccin' } })

vim.pack.add({ Gh('catppuccin/nvim') })

-- Set before setup and colorscheme to ensure true color is active
vim.opt.termguicolors = true

-- stylua: ignore
require('catppuccin').setup({
  flavour                = 'mocha',
  transparent_background = false,
  show_end_of_buffer     = false,
  styles                 = { comments = { 'italic' } },

  -- stylua: ignore
  highlight_overrides = {
    all = function(colors)
      return {
        -- Folded removed here — defined in mocha block below (mocha wins anyway)
        FoldColumn = { fg = colors.lavender, bg = colors.none },
        SignColumn  = { bg = colors.none },
      }
    end,
    mocha = function(colors)
      return {
        Comment             = { bg = '#1f1f1f', style     = { 'italic' } },
        Cursor              = { bg = '#a8a8a8' },
        CursorLine          = { bg = '#273746' },
        LineNr              = { bg = '#262626', fg        = 'Grey' },
        Folded              = { bg = '#262626', fg        = '#ffffff' },
        FoldColumn          = { bg = '#262626', fg        = colors.sapphire },
        FzfLuaSearch        = { fg = colors.yellow, style = { 'bold' } },
        FzfLuaGrep          = { fg = colors.yellow, style = { 'bold' } },
        FzfLuaGrepHighlight = { fg = colors.sky,    style = { 'bold' } },
        Search              = { fg = colors.base,   bg    = colors.yellow },  -- general search matches
        CurSearch           = { fg = colors.base,   bg    = colors.red }, -- currently selected match
      }
    end,
  },

  -- stylua: ignore
  integrations = {
    blink_cmp          = { style = 'bordered' },
    fzf                = true,   -- base FzfLua theming; needed for highlight_overrides above to build on
    markdown           = true,
    noice              = true,
    rainbow_delimiters = true,
    indent_blankline   = {
      enabled               = true,
      colored_indent_levels = false,
    },
    mini = { enabled = true, indentscope_color = '' },
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors      = { 'italic' },
        hints       = { 'italic' },
        warnings    = { 'italic' },
        information = { 'italic' },
        ok          = { 'italic' },
      },
      underlines = {
        errors      = { 'underline' },
        hints       = { 'underline' },
        warnings    = { 'underline' },
        information = { 'underline' },
        ok          = { 'underline' },
      },
      inlay_hints = { background = true },
    },
  },
})

vim.cmd.colorscheme('catppuccin-nvim')
