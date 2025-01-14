-- docs : https://github.com/ray-x/go.nvim
return {
  {
    'ray-x/go.nvim',
    dependencies = {
      'ray-x/guihua.lua',
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter',
      'folke/which-key.nvim',
      'nvim-neotest/neotest',
      'nvim-neotest/neotest-go',
    },
    config = function()
      require('go').setup {
        -- Add neotest integration
        test_runner = 'neotest',
        test_flags = { '-v' },
      }

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'go' },
        callback = function(ev)
          vim.api.nvim_buf_set_keymap(0, 'n', '<C-f>', ':GoFillStruct<CR>', {})
          vim.api.nvim_buf_set_keymap(0, 'n', '<C-e>', ':GoIfErr<CR>', {})
          vim.api.nvim_buf_set_keymap(0, 'n', '<C-s>', ':GoFillSwitch<CR>', {})
        end,
        group = vim.api.nvim_create_augroup('go_autocommands', { clear = true }),
      })

      -- NOTE: not using dap/debug
      -- Add debug integration
      -- vim.api.nvim_create_user_command('GoTestDebug', function()
      --   require('neotest').run.run { strategy = 'dap' }
      -- end, {})
    end,
    event = { 'CmdlineEnter' },
    ft = { 'go', 'gomod' },
    build = ':lua require("go.install").update_all_sync()',
  },
}
