return {
  "fredrikaverpil/godoc.nvim",
  ft = { "go" },
  config = function()
    require("godoc").setup()
    vim.keymap.set("n", "<leader>gD", ":GoDoc<CR>", { desc = "Open GoDoc" })
  end,
}
