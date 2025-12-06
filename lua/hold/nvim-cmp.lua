-- nvim-cmp.lua
--
-- Created: 12/10/23

-- mappings to move in templates
vim.cmd([[
	" press <Tab> to expand or jump in a snippet. These can also be mapped separately
	" via <Plug>luasnip-expand-snippet and <Plug>luasnip-jump-next.
	imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' 
	" -1 for jumping backwards.
	inoremap <silent> <S-Tab> <cmd>lua require'luasnip'.jump(-1)<Cr>

	snoremap <silent> <Tab> <cmd>lua require('luasnip').jump(1)<Cr>
	snoremap <silent> <S-Tab> <cmd>lua require('luasnip').jump(-1)<Cr>

	" For changing choices in choiceNodes (not strictly necessary for a basic setup).
	imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
	smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
]])

return {
  'hrsh7th/nvim-cmp',
  lazy = true,
  dependencies = {
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lua',
    'hrsh7th/cmp-path',
    'onsails/lspkind.nvim',
    'L3MON4D3/LuaSnip',
    'neovim/nvim-lspconfig',
    'rafamadriz/friendly-snippets',
    'saadparwaiz1/cmp_luasnip',
  },

  config = function()
    -- set up vscode-like completions
    require('luasnip.loaders.from_vscode').lazy_load()
    vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
    local cmp = require('cmp')
    local lspkind = require('lspkind')
    cmp.setup({
      -- set up for display and icons
      formatting = {
        -- format = lspkind.cmp_format({
        --   mode = 'symbol_text', -- Show symbol and text (e.g., "Function fn")
        --   maxwidth = 60, -- Limit popup width
        --   ellipsis_char = '...', -- Show ellipsis for truncated text
        -- }),
        format = lspkind.cmp_format({
          mode = 'symbol_text',
          menu = {
            buffer = '[Buffer]',
            nvim_lua = '[Lua]',
            nvim_lsp = '[LSP]',
            path = '[Path]',
          },
        }),
      },
      window = {
        completion = cmp.config.window.bordered({ border = 'rounded' }),
        documentation = cmp.config.window.bordered({ border = 'rounded' }),
      },
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<Tab>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected
        -- ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected
      }),
      sources = cmp.config.sources({
        { name = 'luasnip' },
        { name = 'nvim_lua' },
        { name = 'nvim_lsp' },
        { name = 'path' },
        { name = 'friendly-snippets' },
        { name = 'buffer', keyword_length = 3 },
      }),
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'path' },
          { name = 'cmdline' },
        },
      }),
    })
  end,
}
