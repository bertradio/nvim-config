return {
  'snacks.nvim',
  opts = {
    zen = {
      enter = true,
      fixbuf = false,
      minimal = false,
      width = 120,
      height = 40,
      backdrop = { transparent = true, blend = 40 },
      keys = { q = false },
      zindex = 40,
      wo = {
        winhighlight = 'NormalFloat:Normal',
      },
      w = {
        snacks_main = true,
      },
    },
  },
}
