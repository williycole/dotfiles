-- TODO: finish setting up trouble, look at prevous configs for examples, don't forget the silent setting to fix the which key stuff
-- currently shows errors but not warnings, almost there
-- see thread here: https://www.perplexity.ai/search/is-there-a-neovim-plugin-for-s-MLX7NfQtQDaPIeBlOB.zsw
-- essentially gotta tell it to look everywhere at once vs only the open file which is the default
-- maybe search for how others set that up
--
-- return {
--   'folke/trouble.nvim',
--   opts = {}, -- for default options, refer to the configuration section for custom setup.
--   cmd = 'Trouble',
--   keys = {
--     {
--       '<leader>xx',
--       '<cmd>Trouble diagnostics toggle<cr>',
--       desc = 'Diagnostics (Trouble)',
--     },
--     {
--       '<leader>xX',
--       '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
--       desc = 'Buffer Diagnostics (Trouble)',
--     },
--     {
--       '<leader>cs',
--       '<cmd>Trouble symbols toggle focus=false<cr>',
--       desc = 'Symbols (Trouble)',
--     },
--     {
--       '<leader>cl',
--       '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
--       desc = 'LSP Definitions / references / ... (Trouble)',
--     },
--     {
--       '<leader>xL',
--       '<cmd>Trouble loclist toggle<cr>',
--       desc = 'Location List (Trouble)',
--     },
--     {
--       '<leader>xQ',
--       '<cmd>Trouble qflist toggle<cr>',
--       desc = 'Quickfix List (Trouble)',
--     },
--   },
-- }
-- docs: https://github.com/folke/trouble.nvim
return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {},
  cmd = 'Trouble',
  keys = {
    {
      '<leader>tp',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Diagnostics (Trouble)',
    },
  },
}
