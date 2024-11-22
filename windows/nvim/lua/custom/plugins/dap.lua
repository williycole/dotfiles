-- return {
--   {
--     'mfussenegger/nvim-dap',
--     dependencies = {
--       'rcarriga/nvim-dap-ui',
--       'williamboman/mason.nvim',
--       'jay-babu/mason-nvim-dap.nvim',
--       'leoluz/nvim-dap-go',
--     },
--     config = function()
--       local dap = require 'dap'
--       local dapui = require 'dapui'
--
--       require('mason-nvim-dap').setup {
--         automatic_setup = true,
--         handlers = {},
--         ensure_installed = {
--           'delve',
--         },
--       }
--
--       -- Keymaps
--       vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
--       vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
--       vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
--       vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
--       vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
--       vim.keymap.set('n', '<leader>B', function()
--         dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
--       end, { desc = 'Debug: Set Breakpoint' })
--
--       -- DAP UI setup
--       dapui.setup()
--       vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: Toggle UI' })
--
--       dap.listeners.after.event_initialized['dapui_config'] = dapui.open
--       dap.listeners.before.event_terminated['dapui_config'] = dapui.close
--       dap.listeners.before.event_exited['dapui_config'] = dapui.close
--
--       -- Go debugger setup
--       require('dap-go').setup()
--
--       -- Configure Go debugger
--       dap.configurations.go = {
--         {
--           type = 'go',
--           name = 'Debug',
--           request = 'attach',
--           mode = 'remote',
--           remotePath = '/src',
--           port = 2345,
--           host = '127.0.0.1',
--           cwd = '${workspaceFolder}',
--         },
--       }
--     end,
--   },
-- }
--
return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'leoluz/nvim-dap-go',
    },
    config = function()
      local dap = require 'dap'
      local dap_go = require 'dap-go'

      dap_go.setup()

      table.insert(dap.configurations.go, {
        type = 'go',
        name = 'Debug in Docker',
        request = 'attach',
        mode = 'remote',
        remotePath = '/src',
        port = 2345,
        host = '127.0.0.1',
        cwd = '${workspaceFolder}',
        substitutePath = {
          {
            from = '${workspaceFolder}',
            to = '/src',
          },
        },
      })

      vim.keymap.set('n', '<F5>', function()
        require('dap').continue()
      end)
      vim.keymap.set('n', '<F10>', function()
        require('dap').step_over()
      end)
      vim.keymap.set('n', '<F11>', function()
        require('dap').step_into()
      end)
      vim.keymap.set('n', '<F12>', function()
        require('dap').step_out()
      end)
      vim.keymap.set('n', '<Leader>b', function()
        require('dap').toggle_breakpoint()
      end)
    end,
  },
}
