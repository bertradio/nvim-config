-- treesitter.lua
-- code from ChatGPT and Gemini

-- Helper to auto-disable on huge files (Defined outside to keep config clean)
local function too_big(_, buf)
    local max = 100 * 1024 -- Reduced to 100 KB for even better performance
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
    return ok and stats and stats.size > max
end

return {
    'nvim-treesitter/nvim-treesitter',
    version = false, -- Last release is very old, use master for better perf
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall' },
    
    -- Using 'main' lets lazy.nvim call setup automatically
    main = 'nvim-treesitter.configs',
    
    opts = {
        ensure_installed = {
            'awk', 'bash', 'c', 'csv', 'diff', 'json', 'lua', 'markdown', 'markdown_inline',
            'powershell', 'python', 'query', 'regex', 'toml', 'vim', 'vimdoc'
        },
        auto_install = true,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
            disable = too_big,
        },
        indent = {
            enable = true,
            disable = { 'markdown' },
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = '<CR>',
                node_incremental = '<CR>',
                node_decremental = '<BS>',
                scope_incremental = '<TAB>',
            },
        },
    },
    
    -- Use config if you need custom logic, otherwise 'opts' + 'main' is faster
    config = function(_, opts)
        require('nvim-treesitter.configs').setup(opts)
    end,
}
