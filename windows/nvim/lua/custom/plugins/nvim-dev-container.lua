-- Docs: https://github.com/esensar/nvim-dev-container
return {
  -- Toggle term
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = true,
  },
  -- Nvim dev conainer
  {
    'https://codeberg.org/esensar/nvim-dev-container',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'akinsho/toggleterm.nvim' },
    config = function()
      require('devcontainer').setup {
        container_name = 'ggs-dev-1',
        container_runtime = 'docker',
        container_user = 'dev',
        command_prefix = 'sudo',
        attach_mounts = {
          neovim_config = {
            -- enables mounting local config to /root/.config/nvim in container
            enabled = false,
            -- makes mount readonly in container
            options = {},
          },
          neovim_data = {
            -- enables mounting local data to /root/.local/share/nvim in container
            enabled = false,
            -- no options by default
            options = {},
          },
          -- Only useful if using neovim 0.8.0+
          neovim_state = {
            -- enables mounting local state to /root/.local/state/nvim in container
            enabled = false,
            -- no options by default
            options = {},
          },
        },
        --
        --
        terminal_handler = function(command)
          if type(command) == 'table' then
            command = table.concat(command, ' ')
          end
          vim.cmd('tabnew | terminal ' .. command)
        end,
        --
        --
        -- NOTE: new stuf below here
        --
        --
        -- terminal_handler = function(command)
        --   local toggleterm = require 'toggleterm'
        --   if type(command) == 'table' then
        --     command = table.concat(command, ' ')
        --   end
        --   toggleterm.exec(command)
        -- end,
        --
        --
        -- Add container-specific LSP settings
        on_attach = function(bufnr)
          local lspconfig = require 'lspconfig'
          lspconfig.gopls.setup {
            cmd = { 'gopls', 'serve' },
            filetypes = { 'go', 'gomod' },
            root_dir = lspconfig.util.root_pattern('go.work', 'go.mod', '.git'),
            settings = {
              gopls = {
                analyses = {
                  unusedparams = true,
                },
                staticcheck = true,
              },
            },
          }
        end,
      }
    end,
  },
}
