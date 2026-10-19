-- markdown-plus.lua

-- Created: 08/19/26

vim.pack.add({ { src = Gh('yousefhadder/markdown-plus.nvim'), ft = 'markdown' } })

require('markdown-plus').setup()

-- code from ChatGPT to automatically format the table when moving cells

local function set_markdown_table_maps(buf)
  local opts = {
    buffer = buf,
    remap = true,
    silent = true,
  }

  vim.keymap.set(
    'i',
    -- '<Tab>',
    '<A-Left>',
    '<C-o><Plug>(MarkdownPlusTableFormat)<Plug>(MarkdownPlusTableNavLeft)',
    opts
  )

  vim.keymap.set(
    'i',
    '<A-Down>',
    '<C-o><Plug>(MarkdownPlusTableFormat)<Plug>(MarkdownPlusTableNavDown)',
    opts
  )

  vim.keymap.set(
    'i',
    '<A-Up>',
    '<C-o><Plug>(MarkdownPlusTableFormat)<Plug>(MarkdownPlusTableNavUp)',
    opts
  )

  vim.keymap.set(
    'i',
    -- '<S-Tab>',
    '<A-Right>',
    '<C-o><Plug>(MarkdownPlusTableFormat)<Plug>(MarkdownPlusTableNavRight)',
    opts
  )
end

local function remove_code_block_navigation_maps(buf)
  local maps = {
    ['[b'] = '<Plug>(MarkdownPlusCodeBlockPrev)',
    [']b'] = '<Plug>(MarkdownPlusCodeBlockNext)',
  }

  vim.api.nvim_buf_call(buf, function()
    for lhs, rhs in pairs(maps) do
      local map = vim.fn.maparg(lhs, 'n', false, true)
      if map.buffer == 1 and map.rhs == rhs then
        vim.keymap.del('n', lhs, { buffer = buf })
      end
    end
  end)
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function(args)
    set_markdown_table_maps(args.buf)
    remove_code_block_navigation_maps(args.buf)
  end,
})
