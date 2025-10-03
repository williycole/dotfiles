return {
  {
    "VVoruganti/today.nvim",
    opts = {
      local_root = "/home/cb/repos/cb-vault/daily", -- NOT notes_path

      template = "template.md", -- NOT template_path
      -- filename option does not exist in standard today.nvim!
    },
    keys = {
      { "<leader>dn", "<cmd>Today<CR>", desc = "Open today's Daily Note" },
    },
  },
  {
    "fredrikaverpil/godoc.nvim",
    ft = { "go" },
    config = function()
      require("godoc").setup()
      vim.keymap.set("n", "<leader>gD", ":GoDoc<CR>", { desc = "Open GoDoc" })
    end,
  },
  {
    "S1M0N38/love2d.nvim",
    event = "VeryLazy",
    version = "2.*",
    opts = {},
    keys = {
      { "<leader>v", ft = "lua", desc = "LÖVE" },
      { "<leader>vv", "<cmd>LoveRun<cr>", ft = "lua", desc = "Run LÖVE" },
      { "<leader>vs", "<cmd>LoveStop<cr>", ft = "lua", desc = "Stop LÖVE" },
      { "<leader>vh", "<cmd>help love2d<cr>", ft = "lua", desc = "Help LÖVE" },
    },
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    opts = {

      preset = "ghost",

      hi = {
        error = "DiagnosticError",
        warn = "DiagnosticWarn",
        info = "DiagnosticInfo",
        hint = "DiagnosticHint",
        arrow = "NonText",
        background = "CursorLine",
        mixing_color = "None",
      },
      options = {
        show_source = true,
        use_icons_from_diagnostic = false,
        add_messages = true,
        throttle = 0,
        softwrap = 30,
        multiple_diag_under_cursor = false,
        multilines = {
          enabled = true,
          always_show = true,
        },
        show_all_diags_on_cursorline = true,
        enable_on_insert = true,
        overflow = {
          mode = "wrap",
        },
        virt_texts = {
          priority = 5000,
        },
      },
    },
    config = function(_, opts)
      vim.diagnostic.config({ virtual_text = false })
      require("tiny-inline-diagnostic").setup(opts)
      vim.opt.updatetime = 0
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup()
      vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", { desc = "Open vertical terminal" })
    end,
  },
}
