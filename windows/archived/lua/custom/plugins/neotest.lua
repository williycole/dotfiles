-- TODO: consider retiring
-- docs: https://github.com/nvim-neotest/neotest
return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-neotest/neotest-go',
  },
  config = function()
    require('neotest').setup {
      log_level = vim.log.levels.INFO,
      consumers = {},
      icons = {
        -- Add your preferred icons here
        passed = '✔',
        failed = '✖',
        running = '🔄',
        skipped = '⏭',
      },
      highlights = { true, true },
      floating = {
        options = {},
        border = 'rounded',
        max_height = 0.9,
        max_width = 0.9,
      },
      strategies = { 'integrated' },
      run = { enabled = true },
      summary = {
        enabled = true,
        expand_errors = true,
        animated = true,
        follow = true,
        -- mappings = ,
        -- open = ,
        -- count = ,
      },
      output = {
        enabled = true,
        open_on_run = true,
      },
      output_panel = {
        open = '',
        enabled = true,
      },
      quickfix = {
        open = true,
        enabled = true,
      },
      status = {
        virtual_text = true,
        signs = true,
        enabled = true,
      },
      state = {
        enabled = true,
      },
      watch = {
        symbol_queries = {},
        enabled = true,
      },
      diagnostic = {
        severity = 1,
        enabled = true,
      },
      projects = {},
      adapters = {
        require 'neotest-go' {
          args = { '-coverprofile=coverage.out' },
          experimental = {
            test_table = true,
          },
          args = { '-count=1', '-timeout=60s' },
        },
      },
    }
  end,
  keys = {
    {
      '<leader>rA',
      function()
        require('neotest').run.run(vim.loop.cwd())
      end,
      desc = 'Run All Test Files',
    },
    {
      '<leader>rf',
      function()
        require('neotest').run.run(vim.fn.expand '%')
      end,
      desc = 'Run File',
    },
    {
      '<leader>rN',
      function()
        require('neotest').run.run()
      end,
      desc = 'Run Nearest',
    },
    {
      '<leader>rs',
      function()
        require('neotest').summary.toggle()
      end,
      desc = 'Toggle Summary',
    },
    {
      '<leader>ro',
      function()
        require('neotest').output.open { enter = true, auto_close = true }
      end,
      desc = 'Show Output',
    },
    {
      '<leader>rO',
      function()
        require('neotest').output_panel.toggle()
      end,
      desc = 'Toggle Output Panel',
    },
    {
      '<leader>rS',
      function()
        require('neotest').run.stop()
      end,
      desc = 'Stop',
    },
  },
}
