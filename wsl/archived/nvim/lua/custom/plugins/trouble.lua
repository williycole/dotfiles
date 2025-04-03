-- docs: https://github.com/folke/trouble.nvim
return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    multiline = true,
  },
  cmd = 'Trouble',
  keys = {
    {
      '<leader>tp',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Diagnostics (Trouble)',
    },
  },
}
