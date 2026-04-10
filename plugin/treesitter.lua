-- treesitter re-write for new main branch of treesitter
-- changed from lazy to vim.pack 3-30-26
-- code from Gemini 12/30/25

-- simplified code from ChatGPT for simplicity
-- have to load parsers manually

-- Enable treesitter highlighting
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
