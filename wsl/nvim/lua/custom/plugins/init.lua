-- -- Function to find main.go file in the project
-- local function find_main_go()
--   local root = vim.fn.getcwd()
--   local main_go = vim.fn.globpath(root, '**/main.go', 0, 1)
--   if #main_go > 0 then
--     return vim.fn.fnamemodify(main_go[1], ':h')
--   end
--   return root
-- end
--
-- return {
--   -- Core DAP (Debug Adapter Protocol) plugin
--   {
--     'mfussenegger/nvim-dap',
--     dependencies = {
--       -- Creates a beautiful debugger UI
--       'rcarriga/nvim-dap-ui',
--
--       -- Installs the debug adapters for you
--       'williamboman/mason.nvim',
--       'jay-babu/mason-nvim-dap.nvim',
--
--       -- Add your own debuggers here
--       'leoluz/nvim-dap-go',
--     },
--     config = function()
--       local dap = require 'dap'
--       local dapui = require 'dapui'
--
--       -- Configure Mason to automatically install DAP adapters
--       require('mason-nvim-dap').setup {
--         -- Makes a best effort to setup the various debuggers with
--         -- reasonable debug configurations
--         automatic_setup = true,
--
--         -- You can provide additional configuration to the handlers,
--         -- see mason-nvim-dap README for more information
--         handlers = {},
--
--         -- You'll need to check that you have the required things installed
--         -- online, please don't ask me how to install them :)
--         ensure_installed = {
--           -- Update this to ensure that you have the debuggers for the langs you want
--           'delve',
--         },
--       }
--
--       -- Basic debugging keymaps, feel free to change to your liking!
--       vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
--       vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
--       vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
--       vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
--       vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
--       vim.keymap.set('n', '<leader>B', function()
--         dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
--       end, { desc = 'Debug: Set Breakpoint' })
--
--       -- Dap UI setup
--       -- For more information, see |:help nvim-dap-ui|
--       dapui.setup {
--
--         -- Set icons to characters that are more likely to work in every terminal.
--         --    Feel free to remove or use ones that you like more! :)
--         --    Don't feel like these are good choices.
--         icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
--         controls = {
--           icons = {
--             play = '▶ (F5)',
--             step_into = '⏎ (F1)',
--             step_over = '⏭ (F2)',
--             step_out = '⏮ (F3)',
--             toggle_breakpoint = '🛑 (<leader>b)',
--             set_breakpoint = '🔴 (<leader>B)',
--             debug_ui_toggle = '👁 (F7)',
--           },
--         },
--       }
--
--       -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
--       vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result' })
--
--       dap.listeners.after.event_initialized['dapui_config'] = dapui.open
--       dap.listeners.before.event_terminated['dapui_config'] = dapui.close
--       dap.listeners.before.event_exited['dapui_config'] = dapui.close
--
--       -- Install golang specific config
--       require('dap-go').setup()
--
--       -- Override dap-go's launch configuration
--       dap.configurations.go = {
--         {
--           type = 'go',
--           name = 'Debug',
--           request = 'launch',
--           program = function()
--             return find_main_go()
--           end,
--         },
--       }
--     end,
--   },
-- }
return {
  -- Core DAP (Debug Adapter Protocol) plugin
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      -- Creates a beautiful debugger UI
      'rcarriga/nvim-dap-ui',

      -- Installs the debug adapters for you
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',

      -- Add your own debuggers here
      'leoluz/nvim-dap-go',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      -- Configure Mason to automatically install DAP adapters
      require('mason-nvim-dap').setup {
        automatic_setup = true,
        handlers = {},
        ensure_installed = {
          'delve', -- Ensure Delve is installed for Go debugging
        },
      }

      -- Basic debugging keymaps
      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
      vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Set Breakpoint' })

      -- Dap UI setup
      dapui.setup {
        icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        controls = {
          icons = {
            play = '▶ (F5)',
            step_into = '↓ (F1)',
            step_over = '→ (F2)',
            step_out = '↑ (F3)',
            toggle_breakpoint = '⛔ (<leader>b)',
            set_breakpoint = '⚠ (<leader>B)',
            debug_ui_toggle = '🖥 (F7)',
          },
        },
      }

      -- Toggle to see last session result
      vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result' })

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      -- Install golang specific config
      require('dap-go').setup()

      -- Override dap-go's launch configuration for attaching to a container
      dap.configurations.go = {
        {
          type = 'go',
          name = 'Attach to Container',
          request = 'attach',
          mode = 'remote',
          remotePath = '/src', -- This is where your project is mounted in the container
          port = 2345, -- Make sure this matches the port Delve is listening on
          host = '127.0.0.1', -- Use localhost if connecting from host machine
        },
      }
    end,
  },
}
