-- docs: https://github.com/stevearc/oil.nvim

vim.keymap.set('n', '<leader>te', function()
  require('oil').toggle_float(vim.fn.expand '%:p:h')
end, { desc = 'Toggle Oil float for current directory' })

vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE' })

return {
  'stevearc/oil.nvim',
  --@module 'oil'
  --@type oil.SetupOpts
  opts = {
    view_options = {
      show_hidden = true,
    },
    float = {
      padding = 2,
      max_width = 0.6,
      max_height = 0.15,
      border = 'rounded',
      win_options = {
        winblend = 0,
      },
    },
  },
  -- Optional dependencies
  dependencies = { { 'echasnovski/mini.icons', opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
}
