-- NOTE: all formatting is handled by lsp.none-ls and other builtin configuration through LazyExtras and Mason
-- For more info on any file run ConformInfo or LspInfo to see what you are working with.
-- Using these settings with the few others under lua/config/option.lua allows conform to take advantage
-- of project settings i.e. .prettierrc, .eslintrc, etc. without any extra configuration.
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        typescript = { "prettier", "eslint_d" },
        typescriptreact = { "prettier", "eslint_d" },
        javascript = { "prettier", "eslint_d" },
        javascriptreact = { "prettier", "eslint_d" },
        json = { "prettier", "eslint_d" },
        yaml = { "prettier", "eslint_d" },
      },
    },
  },
}
