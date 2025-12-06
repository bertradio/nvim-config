-- plugins/mini.lua
-- All mini.nvim modules in one file with configs and lazy-load triggers
-- Includes: stronger ga override + one-shot presets (gA=, gA,, gA:)

return {
  -- mini.ai: textobjects – attach when a buffer is ready
  {
    "echasnovski/mini.ai",
    version = false,
    event = "BufReadPost",
    config = function()
      require("mini.ai").setup()
    end,
  },

-- mini.align: load only on align keys, override built-in ga
{
  "echasnovski/mini.align",
  version = false,
  keys = {
    { "ga",  mode = { "n", "x" }, desc = "Align (MiniAlign)" },
    { "gA=", mode = "x", desc = "Align on =" }, -- one-shot
    { "gA,", mode = "x", desc = "Align on ," }, -- one-shot
    { "gA:", mode = "x", desc = "Align on :" }, -- one-shot
  },
  init = function()
    -- Reserve 'ga' early so the built-in ASCII inspector doesn't grab it
    vim.keymap.set({ "n", "x" }, "ga", "<Nop>", { noremap = true })
  end,
  config = function()
    -- 1) Properly enable mini.align
    require("mini.align").setup({
      -- keep plugin's own mappings: we'll use 'ga' (start) and 'gA' (preview)
      mappings = { start = "ga", start_with_preview = "gA" },
    })

    -- 2) One-shot presets (visual mode): simulate typing modifiers after start.
    --    Each does: start align (ga) -> choose special split -> accept (<CR>)
    local function oneshot(mod)
      return function()
        -- start (ga), apply modifier (like '='), accept with <CR>
        vim.api.nvim_feedkeys("ga" .. mod .. "\r", "n", false)
      end
    end

    vim.keymap.set("x", "gA=", oneshot("="), { desc = "Align on =" })
    vim.keymap.set("x", "gA,", oneshot(","), { desc = "Align on ," })
    vim.keymap.set("x", "gA:", oneshot(":"), { desc = "Align on :" })
  end,
},

  -- mini.clue: lightweight, enable on VeryLazy
  {
    "echasnovski/mini.clue",
    version = false,
    event = "VeryLazy",
    config = function()
      local miniclue = require("mini.clue")
      miniclue.setup({
        triggers = {
          { mode = "n", keys = "<Leader>" },
          { mode = "x", keys = "<Leader>" },
          { mode = "n", keys = "g" },
          { mode = "x", keys = "g" },
          { mode = "n", keys = "'" },
          { mode = "n", keys = "`" },
          { mode = "x", keys = "'" },
          { mode = "x", keys = "`" },
          { mode = "n", keys = '"' },
          { mode = "x", keys = '"' },
          { mode = "i", keys = "<C-r>" },
          { mode = "c", keys = "<C-r>" },
          { mode = "n", keys = "<C-w>" },
          { mode = "n", keys = "z" },
        },
        clues = {
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
        },
      })
    end,
  },

  -- mini.move: load when you press move keys
  {
    "echasnovski/mini.move",
    version = false,
    keys = {
      { "<C-left>",  mode = { "n", "x" } },
      { "<C-right>", mode = { "n", "x" } },
      { "<C-up>",    mode = { "n", "x" } },
      { "<C-down>",  mode = { "n", "x" } },
    },
    config = function()
      local move = require("mini.move")
      move.setup()
      vim.keymap.set("n", "<C-left>",  "<cmd>lua MiniMove.move_line('left')<cr>")
      vim.keymap.set("n", "<C-right>", "<cmd>lua MiniMove.move_line('right')<cr>")
      vim.keymap.set("n", "<C-up>",    "<cmd>lua MiniMove.move_line('up')<cr>")
      vim.keymap.set("n", "<C-down>",  "<cmd>lua MiniMove.move_line('down')<cr>")
      vim.keymap.set("x", "<C-left>",  ":MoveSelectionLeft<CR>")
      vim.keymap.set("x", "<C-right>", ":MoveSelectionRight<CR>")
      vim.keymap.set("x", "<C-up>",    ":MoveSelectionUp<CR>")
      vim.keymap.set("x", "<C-down>",  ":MoveSelectionDown<CR>")
    end,
  },

  -- mini.surround: load on first surround keypress
  {
    "echasnovski/mini.surround",
    version = false,
    keys = {
      { "gza", mode = { "n", "x" } }, -- add
      { "gzd", mode = { "n", "x" } }, -- delete
      { "gzr", mode = { "n", "x" } }, -- replace
      { "gzf", mode = { "n", "x" } }, -- find right
      { "gzF", mode = { "n", "x" } }, -- find left
      { "gzh", mode = { "n", "x" } }, -- highlight
      { "gzn", mode = "n" },          -- update n_lines
    },
    config = function()
      local surround = require("mini.surround")
      surround.setup({
        mappings = {
          add = "gza",
          delete = "gzd",
          find = "gzf",
          find_left = "gzF",
          highlight = "gzh",
          replace = "gzr",
          update_n_lines = "gzn",
        },
      })
    end,
  },
}
