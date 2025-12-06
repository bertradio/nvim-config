-- markdown-pdf.lua
--
-- Makes pdf from md file and displays in Okular
--
-- Created: 05/10/24

Myfn.map('n', '<Leader>,', function()
  require('md-pdf').convert_md_to_pdf()
end, { desc = 'Markdown pdf preview' })

return {
  'arminveres/md-pdf.nvim',
  branch = 'main', -- you can assume that main is somewhat stable until releases will be made
  -- lazy = true,
  -- keys = {
  --     {
  --         "<leader>,",
  --         function() require("md-pdf").convert_md_to_pdf() end,
  --         desc = "Markdown preview",
  --     },
  -- },
  require('md-pdf').setup({
    toc = false,
    opts = {},
  }),
}
