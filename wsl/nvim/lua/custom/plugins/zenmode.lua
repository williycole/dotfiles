return {
  'folke/zen-mode.nvim',
  cmd = 'ZenMode',
  opts = {
    window = {
      width = 0.60, -- width will be 75% of the editor width
    },
    plugins = {
      options = {
        enabled = true,
        ruler = false, -- disables the ruler text in the cmd line area
        showcmd = true, -- enables the command in the last line of the screen
      },
    },
  },
  keys = { { '<leader>tz', '<cmd>ZenMode<cr>', desc = 'Toggle Zen Mode' } },
  -- init = function()
  --   vim.api.nvim_create_autocmd('User', {
  --     pattern = 'VeryLazy',
  --     callback = function()
  --       vim.cmd 'ZenMode'
  --     end,
  --   })
  -- end,
}
