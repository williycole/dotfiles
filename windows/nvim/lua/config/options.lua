-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Set global defaults for TypeScript (4 spaces)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- Filetype-specific settings for .gql, .json, .jsonc, .yaml (2 spaces)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "graphql", "json", "jsonc", "yaml" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})

-- Add autocmd for source.organizeImports code action
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
  callback = function(args)
    vim.lsp.buf.code_action({
      context = { only = { "source.organizeImports" } },
      apply = true,
      buffer = args.buf,
    })
  end,
})

vim.g.lazyvim_prettier_needs_config = false

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    require("conform").format({ async = false })
  end,
})
