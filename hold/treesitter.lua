-- Ensure the main plugin and textobjects dependency are loaded
vim.cmd([[packadd nvim-treesitter]])
vim.cmd([[packadd nvim-treesitter-textobjects]])

require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'lua',
    'bash',
    'markdown',
    'markdown_inline',
    'vim',
    'vimdoc',
    'toml',
  },

  -- Automatically install missing parsers when opening a file
  auto_install = true,

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },

  indent = {
    enable = true,
  },

  -- Text Objects configuration
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to matching text object
      keymaps = {
        -- Functions
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        -- Conditionals (if/else)
        ['ai'] = '@conditional.outer',
        ['ii'] = '@conditional.inner',
        -- Loops (for/while)
        ['al'] = '@loop.outer',
        ['il'] = '@loop.inner',
        -- Assignments (useful for Lua key-value pairs / tables)
        ['a='] = '@assignment.outer',
        ['i='] = '@assignment.inner',
      },
    },

    move = {
      enable = true,
      set_jumps = true, -- Tracks jumps in C-o / C-i
      goto_next_start = {
        [']m'] = '@function.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
      },
    },
  },
})
