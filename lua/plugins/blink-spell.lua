-- blink-spell.lua (merged) - code from ChatGPT
-- Keeps your original Blink UI & docs behavior intact.
-- Adds LuaSnip config, curated friendly-snippets, and small Bash/PowerShell snippets.
-- Also preserves your spell gating, cmdline/search completion, and prose autocmds.

return {
  {
    'saghen/blink.cmp',
    version = '1.*',

    dependencies = {
      { 'rafamadriz/friendly-snippets', lazy = true }, -- from Gemini only laod when needed
      'nvim-lua/plenary.nvim',
      'ribru17/blink-cmp-spell',
      'L3MON4D3/LuaSnip',
    },
    event = 'InsertEnter',
    -- event = 'LspAttach', -- suggested by Gemini to speed up load - more lazy

    opts = {
      keymap = { preset = 'super-tab' },

      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },

      signature = { enabled = true, window = { border = 'rounded' } },

      completion = {
        menu = {
          border = 'rounded',
          draw = {
            columns = {
              {
                'label',
                'label_description',
                gap = 1,
              },
              { 'kind_icon' },
              { 'source_name' },
            },
          },
        },
        documentation = { auto_show = true, window = { border = 'rounded' } },
        trigger = { show_in_snippet = false },
        list = { selection = { preselect = false, auto_insert = false } },
      },

      sources = {
        default = { 'buffer', 'path', 'spell' },

        per_filetype = {
          -- Explicitly handle buffers with no filetype (empty string)
          [''] = { 'buffer', 'path', 'spell' },

          -- Code-like
          lua = { 'buffer', 'lsp', 'path', 'snippets' },
          sh = { 'buffer', 'lsp', 'path', 'snippets' },
          ps1 = { 'lsp', 'buffer', 'path', 'snippets' },
          python = { 'buffer', 'lsp', 'path', 'snippets' },
          javascript = { 'buffer', 'lsp', 'path', 'snippets' },
          typescript = { 'buffer', 'lsp', 'path', 'snippets' },

          -- Prose-like
          markdown = { 'spell', 'buffer', 'path' },
          text = { 'spell', 'buffer', 'path' },
          gitcommit = { 'spell', 'buffer', 'path' },
          rst = { 'spell', 'buffer', 'path' },
          latex = { 'spell', 'buffer', 'path' },
        },

        providers = {
          lsp = {
            score_offset = 3,
            fallbacks = {},
          },
          buffer = {
            score_offset = 10,
            min_keyword_length = 2,
            opts = {
              get_bufnrs = function()
                return { vim.api.nvim_get_current_buf() }
              end,
            },
          },
          path = { score_offset = 2 },
          snippets = { score_offset = 1 },
          cmdline = { score_offset = 1 },

          spell = {
            name = 'Spell',
            module = 'blink-cmp-spell',
            score_offset = 3,
            opts = {
              max_entries = 8,
              preselect_current_word = false,
              keep_all_entries = false,
              use_cmp_spell_sorting = false,
            },
          },
        },
      },

      fuzzy = {
        implementation = 'prefer_rust_with_warning',
        use_proximity = true,
        prebuilt_binaries = { download = true },
      },
    },

    config = function(_, opts)
      -- Treesitter-aware check for comments/strings in code buffers
      local function in_comment_or_string()
        local ok, ts = pcall(require, 'vim.treesitter')
        if not ok then
          return false
        end
        local bufnr = 0
        local pos = vim.api.nvim_win_get_cursor(0)
        local row, col = pos[1] - 1, pos[2]
        local ok_caps, caps = pcall(ts.get_captures_at_pos, bufnr, row, col)
        if not ok_caps or not caps then
          return false
        end
        for _, cap in ipairs(caps) do
          local name = cap.capture or cap
          if name == 'nospell' or name == '@nospell' then
            return false
          end
          if name == 'comment' or name == 'string' or name == '@comment' or name == '@string' then
            return true
          end
        end
        return false
      end

      -- Always-on for prose; TS-gated in code
      local prose_fts_set = {
        markdown = true,
        text = true,
        gitcommit = true,
        rst = true,
        latex = true,
        markdown = true,
        [''] = true, -- empty string here to enable spell in no-filetype buffers
      }
      local function enable_spell_context()
        local ft = vim.bo.filetype
        if prose_fts_set[ft] then
          return true
        end
        return in_comment_or_string()
      end

      if opts and opts.sources and opts.sources.providers and opts.sources.providers.spell then
        opts.sources.providers.spell.opts.enable_in_context = enable_spell_context
      end

      -- Apply Blink setup
      require('blink.cmp').setup(opts)

      -- Blink on command-line ":" and search "/" "?"
      pcall(function()
        local cmdline = require('blink.cmp.cmdline')
        if cmdline and cmdline.setup then
          cmdline.setup({
            cmdline = { enabled = true },
            search = { enabled = true },
          })
        end
      end)

      -- Prose-friendly spell settings (turn spell on, set lang + spellfile)
      local SPELL_LANGS = { 'en' } -- add more (e.g., 'he') if you like
      local spellfile_path = vim.fs.normalize(
        vim.fn.stdpath('config') .. '/spell/' .. (SPELL_LANGS[1] or 'en') .. '.utf-8.add'
      )
      do
        local dir = vim.fs.dirname(spellfile_path)
        if dir and vim.fn.isdirectory(dir) == 0 then
          vim.fn.mkdir(dir, 'p')
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'markdown', 'text', 'gitcommit', 'rst', 'latex' },
        callback = function()
          vim.opt_local.spell = true
          vim.opt_local.spelllang = SPELL_LANGS
          vim.opt_local.spellfile = spellfile_path
          -- QoL for prose
          vim.opt_local.conceallevel = 2
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
        end,
        desc = 'Enable spell (and comfy settings) for prose buffers',
      })

      -- Explicitly keep spell off for common code buffers
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'bash',
          'c',
          'cpp',
          'go',
          'java',
          'javascript',
          'jsx',
          'kotlin',
          'lua',
          'ps1',
          'python',
          'rust',
          'sh',
          'tsx',
          'typescript',
          'zsh',
        },
        callback = function()
          vim.opt_local.spell = false
        end,
        desc = 'Disable spell for code buffers',
      })

      -- Shell UX tweaks
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'sh', 'bash', 'zsh' },
        callback = function()
          vim.opt_local.iskeyword:append('-')
        end,
        desc = 'Shell editing comfort',
      })
    end,
  },

  -- === LuaSnip engine + curated snippets + tiny shell/ps snippets ===
  {
    'L3MON4D3/LuaSnip',
    event = 'InsertEnter',
    build = (function()
      -- Optional: jsregexp for advanced regex in snippets (skip on Windows)
      local is_windows = require('platform').is_windows()
      return is_windows and nil or 'make install_jsregexp'
    end)(),
    opts = {
      history = true,
      updateevents = 'TextChanged,TextChangedI',
      enable_autosnippets = false,
      region_check_events = 'CursorMoved,CursorHold,InsertEnter',
      delete_check_events = 'TextChanged,InsertLeave',
    },
    config = function(_, opts)
      local ls = require('luasnip')
      ls.config.setup(opts)

      -- Curated friendly-snippets (Lua, Markdown, Shell, PowerShell)
      local vs = require('luasnip.loaders.from_vscode')
      pcall(vs.lazy_load, { include = { 'lua', 'markdown', 'shellscript', 'powershell' } })

      -- User snippets folder if present
      local user_snips = vim.fn.stdpath('config') .. '/snippets'
      if vim.fn.isdirectory(user_snips) == 1 then
        pcall(vs.lazy_load, { paths = { user_snips } })
      end

      -- Tiny extra snippets
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node

      -- Bash: Shebang + strict mode scaffold
      ls.add_snippets('sh', {
        s('shb', {
          t({
            '#!/usr/bin/env bash',
            'set -euo pipefail',
            "IFS=$'\\n\\t'",
            '',
          }),
          t({ '# ' }),
          i(1, 'script description'),
          t({ '', '', 'main() {', '  ' }),
          i(2, '# TODO'),
          t({ '', '}', '', 'main "$@"' }),
        }),
      })
      ls.add_snippets('bash', ls.get_snippets('sh'))
      -- ls.add_snippets('zsh', ls.get_snippets('sh'))

      -- PowerShell: Param block scaffold
      ls.add_snippets('ps1', {
        s('param', {
          t({ '[CmdletBinding()]', 'param(', '    ' }),
          i(1, '[string]$Path = "."'),
          t({ '', ')', '', 'begin {', '    ' }),
          i(2, '# init'),
          t({ '', '}', '', 'process {', '    ' }),
          i(3, '# work'),
          t({ '', '}', '', 'end {', '    ' }),
          i(4, '# cleanup'),
          t({ '', '}' }),
        }),
      })
      ls.add_snippets('powershell', ls.get_snippets('ps1'))

      -- Non-conflicting snippet keys (keep Blink's <Tab>/<CR> behavior)
      local map_opts = { expr = true, silent = true, desc = 'LuaSnip jump/expand' }
      Snacks.keymap.set({ 'i', 's' }, '<C-j>', function()
        return ls.expand_or_jumpable() and '<Plug>luasnip-expand-or-jump' or '<C-j>'
      end, map_opts)
      Snacks.keymap.set({ 'i', 's' }, '<C-k>', function()
        return ls.jumpable(-1) and '<Plug>luasnip-jump-prev' or '<C-k>'
      end, map_opts)
      Snacks.keymap.set('i', '<C-l>', function()
        return ls.choice_active() and '<Plug>luasnip-next-choice' or '<C-l>'
      end, map_opts)
    end,
  },

  -- Big library of snippets (filtered by include above)
  { 'rafamadriz/friendly-snippets', event = 'InsertEnter' },
}
