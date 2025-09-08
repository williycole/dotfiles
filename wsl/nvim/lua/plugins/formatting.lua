-- return {
--   {
--     -- NOTE: this is not lsp.none-ls its the actual plugin none-ls.
--     --I only want to use markdownlint from this plugin bc I don't have a prettier
--     --file setup anywhere for markdown files
--     "nvimtools/none-ls.nvim",
--     opts = function(_, opts)
--       local nls = require("null-ls")
--       opts.sources = opts.sources or {}
--       vim.list_extend(opts.sources, {
--         nls.builtins.formatting.markdownlint.with({
--           extra_args = { "--fix" },
--           filetypes = { "markdown" },
--         }),
--       })
--     end,
--   },
--   {
--     "stevearc/conform.nvim",
--     opts = {
--       formatters_by_ft = {
--         typescript = { { "prettier", "eslint_d" } },
--         typescriptreact = { { "prettier", "eslint_d" } },
--         json = { "prettier" },
--         jsonc = { "prettier" },
--         graphql = { "prettier" },
--         yaml = { "prettier" },
--       },
--       formatters = {
--         prettier = {
--           require_cwd = false, -- Keep for now to ensure stability
--           command = "prettier",
--           prepend_args = {
--             "--print-width",
--             "120",
--             "--tab-width",
--             "4",
--             "--use-tabs",
--             "false",
--             "--single-quote",
--             "true",
--             "--trailing-comma",
--             "es5",
--             "--bracket-spacing",
--             "true",
--             "--arrow-parens",
--             "always",
--             "--brace-style",
--             "1tbs",
--             "--single-attribute-per-line",
--             "false",
--             "--bracket-same-line",
--             "false",
--           },
--           extra_args = function(params)
--             if vim.tbl_contains({ "json", "jsonc", "graphql", "yaml" }, params.ft) then
--               return { "--tab-width", "2" }
--             end
--             return {}
--           end,
--         },
--         eslint_d = {
--           command = "eslint_d",
--           args = {
--             "--fix-to-stdout",
--             "--stdin",
--             "--stdin-filename",
--             "$FILENAME",
--             "--config",
--             vim.fn.getcwd() .. "/nitropay/panel/.eslintrc.json",
--             "--rule",
--             "import/order: [error, {groups: [['builtin', 'external', 'internal', 'parent', 'sibling', 'index'], 'type'], 'named': {order: 'asc', caseInsensitive: true}, 'alphabetize': {order: 'asc', caseInsensitive: true}}]",
--           },
--           stdin = true,
--         },
--       },
--       format_on_save = {
--         timeout_ms = 1000,
--         lsp_fallback = true, -- this sets formatting for all other types not specified in this file
--       },
--       log_level = vim.log.levels.DEBUG,
--       notify_on_error = true,
--     },
--     init = function()
--       vim.api.nvim_create_autocmd("BufWritePost", {
--         callback = function()
--           -- vim.notify("Conform format attempted", vim.log.levels.INFO)
--         end,
--       })
--     end,
--   },
-- }

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
