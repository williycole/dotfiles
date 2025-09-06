-- return {
--   {
--     "stevearc/conform.nvim",
--     opts = {
--       formatters_by_ft = {
--         typescript = { "prettier" },
--         typescriptreact = { "prettier" },
--       },
--       formatters = {
--         prettier = {
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
--             "avoid",
--             "--single-attribute-per-line",
--             "false",
--             "--bracket-same-line",
--             "false",
--           },
--         },
--       },
--     },
--   },
-- }
--
return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      typescript = { { "prettier", "eslint_d" } },
      typescriptreact = { { "prettier", "eslint_d" } },
      json = { "prettier" },
      jsonc = { "prettier" },
      graphql = { "prettier" },
      yaml = { "prettier" },
    },
    formatters = {
      prettier = {
        -- Temporarily disable require_cwd to test
        require_cwd = false,
        -- Explicitly use global prettier
        command = "prettier",
        prepend_args = {
          "--print-width",
          "120",
          "--tab-width",
          "4",
          "--use-tabs",
          "false",
          "--single-quote",
          "true",
          "--trailing-comma",
          "es5",
          "--bracket-spacing",
          "true",
          "--arrow-parens",
          "always",
          "--brace-style",
          "1tbs",
          "--single-attribute-per-line",
          "false",
          "--bracket-same-line",
          "false",
        },
        extra_args = function(params)
          if vim.tbl_contains({ "json", "jsonc", "graphql", "yaml" }, params.ft) then
            return { "--tab-width", "2" }
          end
          return {}
        end,
      },
      eslint_d = {
        -- Explicitly use global eslint_d
        command = "eslint_d",
        args = {
          "--fix-to-stdout",
          "--stdin",
          "--stdin-filename",
          "$FILENAME",
          "--config",
          vim.fn.getcwd() .. "/nitropay/panel/.eslintrc.json", -- Point to your ESLint config
        },
        stdin = true,
      },
    },
    format_on_save = {
      timeout_ms = 1000, -- Increase timeout to 1s
      lsp_fallback = false, -- Disable LSP fallback to isolate conform.nvim
    },
    log_level = vim.log.levels.DEBUG, -- Enable detailed logging
    notify_on_error = true, -- Show errors if formatting fails
  },
  init = function()
    -- Log when conform tries to format
    vim.api.nvim_create_autocmd("BufWritePost", {
      callback = function()
        vim.notify("Conform format attempted", vim.log.levels.INFO)
      end,
    })
  end,
}
