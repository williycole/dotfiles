-- docs : https://github.com/ray-x/go.nvim
return {
  {
    'ray-x/go.nvim',
    dependencies = {
      'ray-x/guihua.lua',
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter',
      'folke/which-key.nvim',
    },
    config = function()
      -- defaults setup, see docs for options
      require('go').setup {}

      --Shortcut Commands setup
      vim.api.nvim_create_autocmd('FileType', {

        pattern = { 'go' },

        callback = function(ev)
          -- CTRL/control keymaps
          -- vim.api.nvim_buf_set_keymap(0, 'n', '<C-i>', ':GoImport<CR>', {})
          -- vim.api.nvim_buf_set_keymap(0, 'n', '<C-b>', ':GoBuild %:h<CR>', {})
          vim.api.nvim_buf_set_keymap(0, 'n', '<C-t>', ':GoTest<CR>', {})
          vim.api.nvim_buf_set_keymap(0, 'n', '<C-c>', ':GoCoverage -t<CR>', {})
          vim.api.nvim_buf_set_keymap(0, 'n', '<C-f>', ':GoFillStruct<CR>', {})
          vim.api.nvim_buf_set_keymap(0, 'n', '<C-e>', ':GoIfErr<CR>', {})
          vim.api.nvim_buf_set_keymap(0, 'n', '<C-s>', ':GoFillSwitch<CR>', {})
          -- Opens test files
          -- vim.api.nvim_buf_set_keymap(0, 'n', 'A', ":lua require('go.alternate').switch(true, '')<CR>", {}) -- Test
          -- vim.api.nvim_buf_set_keymap(0, 'n', 'V', ":lua require('go.alternate').switch(true, 'vsplit')<CR>", {}) -- Test Vertical
          -- vim.api.nvim_buf_set_keymap(0, 'n', 'S', ":lua require('go.alternate').switch(true, 'split')<CR>", {}) -- Test Split
        end,

        group = vim.api.nvim_create_augroup('go_autocommands', { clear = true }),
      })
    end,
    event = { 'CmdlineEnter' },
    ft = { 'go', 'gomod' },
    build = ':lua require("go.install").update_all_sync()',
  },
  -- docs: https://github.com/maxandron/goplements.nvim, Visualize Go struct and interface implementationsfor interface visualizastions
  {
    'maxandron/goplements.nvim',
    ft = 'go',
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
}
