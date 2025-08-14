local extra_themes = {
  { "rose-pine/neovim" },
  { "rebelot/kanagawa.nvim" }, -- already installed but we want to set it as default
  { "sainnhe/everforest" },
  { "sainnhe/gruvbox-material" },
  { "EdenEast/nightfox.nvim" },
  { "lunarvim/darkplus.nvim" },
}

return {
  { extra_themes },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa-wave", -- default theme
    },
  },
}
