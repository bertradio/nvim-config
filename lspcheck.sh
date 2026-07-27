#!/usr/bin/env bash

file="${1:-$HOME/lspcheck-test.sh}"

if [[ ! -e "$file" ]]; then
  cat >"$file" <<'EOF'
#!/usr/bin/env bash

name="world"
echo "Hello, $name"
EOF
fi

nvim --headless "$file" \
  "+lua vim.defer_fn(function()
    print('Neovim:', vim.version().major .. '.' .. vim.version().minor .. '.' .. vim.version().patch)
    print('File:', vim.api.nvim_buf_get_name(0))
    print('Filetype:', vim.bo.filetype)
    print('bash-language-server executable:', vim.fn.executable('bash-language-server'))
    print('bash-language-server path:', vim.fn.exepath('bash-language-server'))
    print('bashls enabled:', vim.inspect(vim.lsp.is_enabled('bashls')))
    print('bashls config:', vim.inspect(vim.lsp.config.bashls ~= nil))

    local clients = vim.lsp.get_clients({ bufnr = 0 })
    print('Attached clients:', #clients)

    for _, client in ipairs(clients) do
      print('  ' .. client.name .. ' — id ' .. client.id)
    end

    vim.cmd('qa!')
  end, 1500)" \
  "+sleep 2"
