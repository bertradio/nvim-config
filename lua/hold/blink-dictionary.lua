-- blink.lua
-- blink with dictionary for md and text filss
-- Fuzzy finding disabled
-- Created: 12/23/24

return {

  'saghen/blink.cmp',
  version = '1.*',
  event = 'InsertEnter',
  dependencies = {
    'rafamadriz/friendly-snippets',
    'Kaiser-Yang/blink-cmp-dictionary',
  },

  opts = {

    -- keymap presets
    keymap = { preset = 'super-tab' },

    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono',
    },

    -- show fields while filing in a snippet
    signature = { enabled = true, window = { border = 'rounded' } },

    completion = {
      menu = {
        border = 'rounded',
        -- set columns to display in menu
        draw = {
          columns = {
            { 'label', 'label_description', gap = 1 },
            { 'kind_icon' },
            { 'kind' },
            { 'source_name' },
          },
        },
      },
      documentation = { auto_show = true, window = { border = 'rounded' } },
      trigger = { show_in_snippet = false },
    },

    sources = {
      -- set priorities for display using score_offset
      default = { 'dictionary', 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        buffer = { score_offset = 1 },
        lsp = { score_offset = 4 },
        path = { score_offset = 3 },
        snippets = { score_offset = 1 },
        cmdline = { score_offset = 1 },
        dictionary = {
          module = 'blink-cmp-dictionary',
          name = '',
          score_offset = 3,
          -- Make sure this is at least 2.
          -- 3 is recommended
          min_keyword_length = 3,
          opts = {
            -- options for blink-cmp-dictionary
            -- All .txt files in these directories will be treated as dictionary files
            dictionary_directories = {
              vim.fn.expand('/home/bert/.config/nvim/dictionary/'),
            },
            exact = true, -- disable fuzzy matching
          },
        },
      },

      -- Define providers to display per filetype
      per_filetype = {
        lua = { 'lsp', 'buffer', 'path', 'snippets' },
        markdown = { 'buffer', 'path', 'dictionary' },
        text = { 'buffer', 'path', 'dictionary' },
        ps1 = { 'lsp', 'buffer', 'path', 'snippets' },
      },
    },
  },
  opts_extend = { 'sources.default' },
}
