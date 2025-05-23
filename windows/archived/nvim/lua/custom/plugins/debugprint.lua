-- docs: https://github.com/andrewferrier/debugprint.nvim, A debugger alertnative
return {
  'andrewferrier/debugprint.nvim',

  -- for default
  -- opts = { … },
  -- opts = {
  keymaps = {
    normal = {
      --       plain_below = 'g?p',
      --       plain_above = 'g?P',
      --       variable_below = 'g?v',
      --       variable_above = 'g?V',
      --       variable_below_alwaysprompt = '',
      --       variable_above_alwaysprompt = '',
      --       textobj_below = 'g?o',
      --       textobj_above = 'g?O',
      --       toggle_comment_debug_prints = '',
      --       delete_debug_prints = '',
      plain_below = '<leader>cb',
      plain_above = '<leader>ca',
    },
    --     insert = {
    --       plain = '<C-G>p',
    --       variable = '<C-G>v',
    --     },
    --     visual = {
    --       variable_below = 'g?v',
    --       variable_above = 'g?V',
    --     },
    --   },
    commands = {
      toggle_comment_debug_prints = 'ToggleCommentDebugPrints',
      delete_debug_prints = 'DeleteDebugPrints',
      reset_debug_prints_counter = 'ResetDebugPrintsCounter',
    },
    -- },
    dependencies = {
      'echasnovski/mini.nvim', -- Needed for :ToggleCommentDebugPrints (not needed for NeoVim 0.10+)
    },

    version = '*', -- Remove if you DON'T want to use the stable version
  },
}
