-- lua/plugins/reactive.lua
return {
  'rasulomaroff/reactive.nvim',
  config = function()
    require('reactive').setup({
      builtin = {
        cursorline = false, -- let our extmark handle it
        cursor = true,
        modemsg = true,
      },
    })
  end,
}
