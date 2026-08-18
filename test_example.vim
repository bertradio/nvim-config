version
echo "--------------------------------"
echo "LspStart command:"
echo exists(':LspStart')

echo "--------------------------------"
echo "vim.lsp.enable():"
lua print(vim.inspect(vim.lsp.enable))

echo "--------------------------------"
echo "bashls enabled:"
lua print(vim.inspect(vim.lsp.is_enabled('bashls')))

echo "--------------------------------"
echo "VIMRUNTIME:"
echo $VIMRUNTIME

echo "--------------------------------"
echo "plugin/lsp.lua exists:"
echo filereadable($VIMRUNTIME .. '/plugin/lsp.lua')

echo "--------------------------------"
messages
