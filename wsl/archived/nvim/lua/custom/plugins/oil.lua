-- docs: https://github.com/stevearc/oil.nvim
return {
  'stevearc/oil.nvim',
  opts = {
    view_options = {
      show_hidden = true,
    },
    float = {
      padding = 2,
      max_width = 0.6,
      max_height = 0.35,
      border = 'rounded',
      win_options = {
        winblend = 0,
      },
    },
  },
  dependencies = { { 'echasnovski/mini.icons', opts = {} } },
  lazy = false,
  keys = {
    {
      '<C-o>',
      function()
        require('oil').toggle_float()
      end,
      desc = 'Toggle Oil',
    },
  },
}
