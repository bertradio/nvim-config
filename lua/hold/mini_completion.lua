-- mini-completion.lua
-- Drop this file into your Lazy spec directory, e.g. `lua/plugins/mini-completion.lua`
-- What you get:
--   • Mini.completion with LSP-first → buffer-keywords fallback
--   • "Super-Tab" behavior (Tab cycles / expands, Shift-Tab back, Enter confirms)
--   • On-demand PATH completion (Alt-p → <C-x><C-f>)
--   • Prose filetypes get spell; code gets Treesitter-gated spell in comments/strings
--   • LuaSnip + friendly-snippets pre-wired

return {
  {
    "echasnovski/mini.completion",
    event = "InsertEnter",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
      { "echasnovski/mini.icons", lazy = true },
    },
    opts = function()
      -- ── Treesitter-aware helper: are we inside a comment or string? ───────────
      local function in_comment_or_string()
        local ok_ts, ts = pcall(require, "vim.treesitter")
        if not ok_ts then return false end
        local row, col = unpack(vim.api.nvim_win_get_cursor(0)); row = row - 1
        local ok_caps, caps = pcall(ts.get_captures_at_pos, 0, row, col)
        if not ok_caps or not caps then return false end
        for _, cap in ipairs(caps) do
          local name = cap.capture or cap
          if name == "nospell" or name == "@nospell" then return false end
          if name == "comment" or name == "string" or name == "@comment" or name == "@string" then
            return true
          end
        end
        return false
      end

      -- Prose gets spell by default; code gets dynamic spell only in comments/strings
      local prose_ft = { markdown = true, text = true, gitcommit = true, rst = true, latex = true }

      -- Prose comforts
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "text", "gitcommit", "rst", "latex" },
        callback = function()
          vim.opt_local.spell = true
          vim.opt_local.spelllang = { "en" }
          vim.opt_local.conceallevel = 2
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
        end,
        desc = "Prose: enable spell & soft-wrap",
      })

      -- Default: spell off in code buffers
      vim.api.nvim_create_autocmd("InsertEnter", {
        callback = function()
          local ft = vim.bo.filetype
          if not prose_ft[ft] then vim.opt_local.spell = false end
        end,
      })

      -- Live toggle spell in code based on TS captures
      vim.api.nvim_create_autocmd({ "CursorMovedI", "TextChangedI" }, {
        callback = function()
          local ft = vim.bo.filetype
          if prose_ft[ft] then return end
          vim.opt_local.spell = in_comment_or_string()
        end,
        desc = "TS-gated spell in code",
      })

      -- Mini.completion options (UX close to Blink)
      return {
        delay = { completion = 100, info = 120, signature = 60 },
        window = {
          info = { height = 25, width = 80, border = "rounded" },
          signature = { height = 12, width = 80, border = "rounded" },
        },
        lsp_completion = {
          source_func = "completefunc", -- good default
          snippet_insert = function(snippet) require("luasnip").lsp_expand(snippet) end,
        },
        -- If LSP yields nothing, <C-n> will drive keyword completion
        fallback_action = "<C-n>",
        mappings = {
          force_twostep = "<C-Space>", -- used by our Super-Tab to *start* completion
          scroll_down = "<C-f>",
          scroll_up   = "<C-b>",
        },
        set_vim_settings = true, -- ensures sane completeopt, etc.
      }
    end,
    config = function(_, opts)
      -- Apply Mini.completion
      require("mini.completion").setup(opts)

      -- Menu predictability
      vim.o.completeopt = "menu,menuone,noselect"
      -- Prefer buffer keywords when falling back (new buffers inherit this)
      vim.opt.complete = ".,w,b,u,t,kspell"

      -- ── LuaSnip setup + snippets ─────────────────────────────────────────────
      local ls = require("luasnip")
      ls.config.setup({ history = true, updateevents = "TextChanged,TextChangedI" })
      local vs = require("luasnip.loaders.from_vscode")
      pcall(vs.lazy_load, { include = { "lua", "markdown", "shellscript", "powershell", "json" } })
      -- Optional: load user snippets from ~/.config/nvim/snippets
      local user_snips = vim.fn.stdpath('config') .. '/snippets'
      if vim.fn.isdirectory(user_snips) == 1 then pcall(vs.lazy_load, { paths = { user_snips } }) end

      -- Optional: nicer LSP kind glyphs if mini.icons is present
      pcall(function() require("mini.icons").tweak_lsp_kind() end)

      -- ── Super-Tab mappings ──────────────────────────────────────────────────
      local function feed(keys)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "i", true)
      end
      local function has_words_before()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        if col == 0 then return false end
        local prev = vim.api.nvim_buf_get_text(0, line - 1, col - 1, line - 1, col, {})[1]
        return prev and not prev:match("%s")
      end

      -- Tab: next item → snippet expand/jump → trigger completion → literal Tab
      vim.keymap.set("i", "<Tab>", function()
        if vim.fn.pumvisible() == 1 then return "<C-n>" end
        if ls.expand_or_locally_jumpable() then ls.expand_or_jump(); return "" end
        if has_words_before() then return "<C-Space>" end
        return "<Tab>"
      end, { expr = true, silent = true, desc = "Super-Tab: next/expand/trigger" })

      -- Shift-Tab: prev item → snippet back → literal Shift-Tab
      vim.keymap.set("i", "<S-Tab>", function()
        if vim.fn.pumvisible() == 1 then return "<C-p>" end
        if ls.jumpable(-1) then ls.jump(-1); return "" end
        return "<S-Tab>"
      end, { expr = true, silent = true, desc = "Super-Tab: previous/back" })

      -- Enter confirms when menu is visible
      vim.keymap.set("i", "<CR>", function()
        if vim.fn.pumvisible() == 1 then return "<C-y>" end
        return "<CR>"
      end, { expr = true, silent = true, desc = "Confirm completion item" })

      -- On-demand path completion (like a path source)
      vim.keymap.set("i", "<A-p>", function() feed("<C-x><C-f>") end,
        { silent = true, desc = "Path completion" })
    end,
  },

  -- Snippet engine
  {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    build = (function()
      -- Avoid building on Windows where `make` is uncommon
      if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then return nil end
      return "make install_jsregexp"
    end)(),
  },

  -- Big community snippet collection
  { "rafamadriz/friendly-snippets", event = "InsertEnter" },
}
