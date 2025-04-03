-- docs https://github.com/ray-x/navigator.lua
-- Code analysis & navigation plugin for Neovim. Navigate codes like a breeze🎐 Exploring LSP and 🌲Treesitter symbols a piece of 🍰 Take control like a boss 🦍
return {
  'ray-x/navigator.lua',
  dependencies = {
    { 'hrsh7th/nvim-cmp' },
    { 'nvim-treesitter/nvim-treesitter' },
    { 'ray-x/guihua.lua', run = 'cd lua/fzy && make' },
    {
      'ray-x/go.nvim',
      event = { 'CmdlineEnter' },
      ft = { 'go', 'gomod' },
      build = ':lua require("go.install").update_all_sync()',
    },
    {
      'ray-x/lsp_signature.nvim', -- Show function signature when you type
      event = 'VeryLazy',
      config = function()
        require('lsp_signature').setup()
      end,
    },
  },
}
