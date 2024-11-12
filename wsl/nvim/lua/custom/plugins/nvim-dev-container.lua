-- default setup
-- see for more options: https://github.com/esensar/nvim-dev-container
-- return {
--   {
--     'https://codeberg.org/esensar/nvim-dev-container',
--     dependencies = 'nvim-treesitter/nvim-treesitter',
--     config = function()
--       require("devcontainer").setup({
--         container_id = "46773be39f16",
--         container_runtime = "docker",
--         container_user = "dev",
--         command_prefix = "sudo",
--         attach_mounts = {
--           neovim_config = {
--             source = vim.fn.expand("~/.config/nvim"),
--             target = "/home/dev/.config/nvim"
--           },
--         },
--         terminal_handler = function(command)
--           if type(command) == "table" then
--             command = table.concat(command, " ")
--           end
--           vim.cmd('vsplit term://' .. command)
--         end,
--       })
--     end
--   }
-- }
-- TODO: Working ish below, commented out bc I'm trying to just attach it to the dev containter with a script
return {
  {
    'https://codeberg.org/esensar/nvim-dev-container',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('devcontainer').setup {
        -- for better consistency we use container name
        -- container_id = "46773be39f16",
        container_name = 'ggs-dev-q',
        container_runtime = 'docker',
        container_user = 'dev',
        command_prefix = 'sudo',
        attach_mounts = {
          neovim_config = {
            source = vim.fn.expand '~/.config/nvim',
            target = '/home/dev/.config/nvim',
          },
        },
        terminal_handler = function(command)
          if type(command) == 'table' then
            command = table.concat(command, ' ')
          end
          vim.cmd('tabnew | terminal ' .. command)
        end,
      }
    end,
  },
}
