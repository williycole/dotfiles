-- all overrides for LazyVim Defaults
return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        enabled = true,
        icons = {
          icon_sources = { "nerd_fonts", "emoji" }, -- Enable both Nerd Fonts and emojis
        },
      },
      zen = {
        toggles = { dim = false, wrap = true },
        win = { backdrop = { transparent = false, bg = "#1f1f28" } },
        -- show = { statusline = true, tabline = true },
      },
    },
    keys = {
      {
        "<leader>si",
        function()
          Snacks.picker.icons()
        end,
        desc = "Search Icons",
      },
    },
  },
  {
    "nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
    },
  },
}
