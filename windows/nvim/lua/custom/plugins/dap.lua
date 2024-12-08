return {
  -- Dap
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
      'leoluz/nvim-dap-go',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      require('mason-nvim-dap').setup {
        automatic_setup = true,
        handlers = {},
        ensure_installed = {
          'delve',
        },
      }

      -- Keymaps
      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
      vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Set Breakpoint' })

      -- DAP UI setup
      dapui.setup()
      vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: Toggle UI' })

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      -- Go debugger setup
      require('dap-go').setup()
      -- require('dap').set_log_level 'INFO'
      require('dap').set_log_level 'TRACE'

      -- Configure Go adapters
      -- dap.adapters.go = {
      --   type = 'executable',
      --   command = 'node',
      --   args = { os.getenv 'HOME' .. '/.local/share/nvim/mason/packages/go-debug-adapter/extension/dist/debugAdapter.js' },
      -- }
      dap.adapters.go = {
        type = 'executable',
        command = 'dlv',
        args = { 'dap', '-l', '127.0.0.1:${port}', '--log', '--log-output=dap,debugger,gdbwire,lldbout,rpc' },
      }
      -- Configure Go debugger
      -- dap.configurations.go = {
      --   {
      --     type = 'go',
      --     name = 'Debug : filerDirname',
      --     request = 'launch',
      --     program = '${fileDirname}',
      --   },
      --   {
      --     type = 'go',
      --     name = 'Debug',
      --     request = 'attach',
      --     mode = 'remote',
      --     remotePath = '/src',
      --     port = 2345,
      --     host = '127.0.0.1',
      --     cwd = '${workspaceFolder}',
      --   },
      -- }
      -- dap.configurations.go = {
      --   {
      --     type = 'go',
      --     name = 'Debug (Attach Remote)',
      --     request = 'attach',
      --     mode = 'remote',
      --     remotePath = '/src',
      --     port = 2345,
      --     host = '127.0.0.1',
      --     cwd = '${workspaceFolder}',
      --   },
      --   {
      --     type = 'go',
      --     name = 'Debug',
      --     request = 'launch',
      --     program = '${file}',
      --   },
      --   {
      --     type = 'go',
      --     name = 'Debug test',
      --     request = 'launch',
      --     mode = 'test',
      --     program = '${file}',
      --   },
      --   {
      --     type = 'go',
      --     name = 'Debug test (go.mod)',
      --     request = 'launch',
      --     mode = 'test',
      --     program = './${relativeFileDirname}',
      --   },
      -- }
      -- Configure debugger for unknown files
      -- dap.configurations._ = {
      --   {
      --     type = 'go',
      --     name = 'Debug',
      --     request = 'attach',
      --     mode = 'remote',
      --     remotePath = '/src',
      --     port = 2345,
      --     host = '127.0.0.1',
      --     cwd = '${workspaceFolder}',
      --   },
      -- }
      -- dap.configurations.go = {
      --   {
      --     type = 'go',
      --     name = 'Debug',
      --     request = 'attach',
      --     mode = 'remote',
      --     remotePath = '/src',
      --     port = 2345,
      --     host = '127.0.0.1',
      --     cwd = '${workspaceFolder}',
      --     trace = true,
      --     logOutput = 'console,file',
      --   },
      -- }
      -- table.insert(dap.configurations.go, {
      --   type = 'go',
      --   name = 'Debug in Docker',
      --   request = 'attach',
      --   mode = 'remote',
      --   remotePath = '/src',
      --   port = 2345,
      --   host = '127.0.0.1',
      --   cwd = '${workspaceFolder}',
      --   substitutePath = {
      --     { from = '${workspaceFolder}', to = '/src' },
      --     trace = true,
      --     logOutput = 'console,file',
      --   },
      -- })

      dap.configurations.go = {
        {
          type = 'go',
          name = 'Debug in Docker',
          request = 'attach',
          mode = 'remote',
          host = '127.0.0.1',
          port = 38697,
          substitutePath = {
            {
              from = '${workspaceFolder}',
              to = '/src',
            },
          },
        },
        {
          -- Second configuration (example)
          type = 'go',
          name = 'Launch File',
          request = 'launch',
          mode = 'debug',
          program = '${workspaceFolder}/launch.json',
        },
      }

      -- Dap Select Config like vscode
      local dap_config_selector = function()
        local configs = dap.configurations.go
        local names = {}
        for _, config in ipairs(configs) do
          table.insert(names, config.name)
        end
        vim.ui.select(names, { prompt = 'Select debug configuration:' }, function(choice)
          if choice then
            for _, config in ipairs(configs) do
              if config.name == choice then
                dap.run(config)
                break
              end
            end
          end
        end)
      end
      vim.keymap.set('n', '<leader>dc', dap_config_selector, { desc = 'Debug: Select Configuration' })
      --
      --
      -- Open Dap Logs
      local function open_dap_log()
        local log_file = vim.fn.stdpath 'cache' .. '/dap.log'
        vim.cmd('edit ' .. log_file)
      end
      vim.keymap.set('n', '<leader>dl', open_dap_log, { desc = 'Open DAP Log' })
    end,
  },
  -- Tasks
  {
    'stevearc/overseer.nvim',
    opts = {},
    config = function()
      require('overseer').setup()
      vim.api.nvim_create_user_command('OverseerRestartLast', function()
        local overseer = require 'overseer'
        local task = overseer.get_last_task()
        if task then
          task:restart()
        else
          vim.notify('No last task found', vim.log.levels.WARN)
        end
      end, {})

      vim.keymap.set('n', '<leader>or', ':OverseerRun<CR>', { desc = 'Run Overseer Task' })
      vim.keymap.set('n', '<leader>ot', ':OverseerToggle<CR>', { desc = 'Toggle Overseer' })
    end,
  },
}
