-- all overrides for LazyVim Defaults
return {
  -- inlay_hints
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },
    },
  },
  -- snacks
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        enabled = true,
        icons = {
          icon_sources = { "nerd_fonts", "emoji" }, -- Enable both Nerd Fonts and emojis
        },
      },
      --     zen = {
      --       toggles = {
      --         dim = false,
      --         wrap = true,
      --       },
      --       win = {
      --         backdrop = {
      --           transparent = false,
      --           -- bg = "#1a1b26", -- Custom background color
      --           bg = (function()
      --             local bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
      --             return bg and string.format("#%06x", bg) or "#1a1b26"
      --           end)(),
      --         },
      --       },
      --     }
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
}
