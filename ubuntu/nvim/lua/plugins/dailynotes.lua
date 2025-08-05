return {
  {
    "VVoruganti/today.nvim",
    opts = {
      local_root = "/home/cboren/repos/cb-vault/dev-grind", -- NOT notes_path
      template = "template.md", -- NOT template_path
      -- filename option does not exist in standard today.nvim!
    },
    keys = {
      { "<leader>dn", "<cmd>Today<CR>", desc = "Open today's Daily Note" },
    },
  },
}
