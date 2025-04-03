-- docs: https://github.com/Exafunction/codeium.nvim
return {
  'Exafunction/codeium.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'hrsh7th/nvim-cmp',
  },
  config = function()
    require('codeium').setup {}
  end,

  vim.keymap.set('n', '<leader>ai', ':Codeium Chat', { noremap = true, silent = true }),
}
