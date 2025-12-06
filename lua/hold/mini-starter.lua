-- mini-starter.lua
--
-- Created: 01/07/25

return {
  'echasnovski/mini.starter',
  version = false,

  config = function()
    -- local starter = require('mini.starter')
    -- starter.setup({
    --   evaluate_single = true,
    --   items = {
    --     starter.sections.builtin_actions(),
    --     starter.sections.recent_files(10, false),
    --     -- starter.sections.recent_files(10, true),
    --     -- Use this if you set up 'mini.sessions'
    --     -- starter.sections.sessions(5, true),
    --   },
    --   content_hooks = {
    --     starter.gen_hook.adding_bullet(),
    --     starter.gen_hook.indexing('all', { 'Builtin actions' }),
    --     starter.gen_hook.padding(3, 2),
    --   },
    -- })
    local starter = require('mini.starter')
    starter.setup({
      items = {
        starter.sections.telescope(),
      },
      content_hooks = {
        starter.gen_hook.adding_bullet(),
        starter.gen_hook.aligning('center', 'center'),
      },
    })
  end,
}
