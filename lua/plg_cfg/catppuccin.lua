--    ╭────────────────────────────╮
--    │       catppuccin.lua       │
--    ╰────────────────────────────╯

-- Updated by Perplexity 4-23-26:
--                  Removed redundant EndOfBuffer custom_highlight (show_end_of_buffer=false
--                  already handles it), removed duplicate Folded from 'all' block,
--                  removed no_italic/no_bold (defaults), added fzf integration,
--                  removed likely-invalid blink_indent key.

vim.pack.add({ { src = Gh('catppuccin/nvim'), name = 'catppuccin' } })

-- Set before setup and colorscheme to ensure true color is active
vim.opt.termguicolors = true

-- stylua: ignore
require('catppuccin').setup({
  flavour                = 'mocha',
  show_end_of_buffer     = false,
  styles                 = { comments = { 'italic' } },
  transparent_background = false,

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
        CurSearch           = { fg = colors.blue,   bg    = colors.white }, -- currently selected match
        Cursor              = { bg = '#a8a8a8' },
        CursorLine          = { bg = '#273746' },
        FoldColumn          = { bg = '#262626', fg        = colors.sapphire },
        Folded              = { bg = '#262626', fg        = '#ffffff' },
        FzfLuaGrep          = { fg = colors.yellow, style = { 'bold' } },
        FzfLuaGrepHighlight = { fg = colors.red,    style = { 'bold' } },
        FzfLuaSearch        = { fg = colors.yellow, style = { 'bold' } },
        LineNr              = { bg = '#262626', fg        = 'Grey' },
        -- Search              = { fg = colors.base,   bg    = colors.yellow },  -- general search matches
    }
    end,
  },

  integrations = {
    blink_cmp          = { style = 'bordered' },
    flash              = true,
    fzf                = true,   -- base FzfLua theming; needed for highlight_overrides above to build on
    markdown           = true,
    mason              = false,
    mini               = { enabled = true, indentscope_color = '' },
    rainbow_delimiters = true,
    -- render_markdown    = true,

    colorful_winsep = {
      enabled = true,
      color = "yellow",
    },

    native_lsp = {
        enabled = true,
        virtual_text = {
          errors      = { 'italic' },
          hints       = { 'italic' },
          information = { 'italic' },
          ok          = { 'italic' },
          warnings    = { 'italic' },
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
  }
})

vim.cmd.colorscheme('catppuccin-nvim')
