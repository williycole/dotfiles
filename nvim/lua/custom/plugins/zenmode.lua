return {
  'folke/zen-mode.nvim',
  cmd = 'ZenMode',
  opts = {
    window = {
      width = 0.85, -- width will be 85% of the editor width
    },
    plugins = {
      options = {
        enabled = true,
        ruler = false, -- disables the ruler text in the cmd line area
        showcmd = false, -- disables the command in the last line of the screen
      },
    },
  },
  keys = { { '<leader>tz', '<cmd>ZenMode<cr>', desc = 'Toggle Zen Mode' } },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        vim.cmd 'ZenMode'
      end,
    })
  end,
}
