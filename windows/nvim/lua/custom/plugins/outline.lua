return {
  'hedyhli/outline.nvim',
  lazy = true,
  cmd = { 'Outline', 'OutlineOpen' },
  keys = {
    { '<leader>to', '<cmd>Outline<CR>', desc = 'Toggle outline' },
  },
  opts = {
    outline_window = {
      position = 'right',
      width = 25,
      relative_width = true,
    },
    -- Add any other configuration options here
  },
  config = function(_, opts)
    require('outline').setup(opts)
  end,
}
