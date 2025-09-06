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
                require_cwd = false, -- Keep this until we're sure .prettierrc is detected
                command = "prettier",
                prepend_args = {
                    "--print-width", "120",
                    "--tab-width", "4",
                    "--use-tabs", "false",
                    "--single-quote", "true",
                    "--trailing-comma", "es5",
                    "--bracket-spacing", "true",
                    "--arrow-parens", "always",
                    "--brace-style", "1tbs",
                    "--single-attribute-per-line", "false",
                    "--bracket-same-line", "false",
                },
                extra_args = function(params)
                    if vim.tbl_contains({ "json", "jsonc", "graphql", "yaml" }, params.ft) then
                        return { "--tab-width", "2" }
                    end
                    return {}
                end,
            },
            eslint_d = {
                command = "eslint_d",
                args = {
                    "--fix-to-stdout",
                    "--stdin",
                    "--stdin-filename",
                    "$FILENAME",
                    "--config",
                    vim.fn.getcwd() .. "/nitropay/panel/.eslintrc.json",
                    "--rule",
                    "import/order: [error, {groups: [['builtin', 'external', 'internal', 'parent', 'sibling', 'index'], 'type'], 'alphabetize': {order: 'asc', caseInsensitive: true}}]",
                },
                stdin = true,
            },
        },
        format_on_save = {
            timeout_ms = 1000,
            lsp_fallback = false,
        },
        log_level = vim.log.levels.DEBUG,
        notify_on_error = true,
    },
    init = function()
        vim.api.nvim_create_autocmd("BufWritePost", {
            callback = function()
                vim.notify("Conform format attempted", vim.log.levels.INFO)
            end,
        })
    end,
}
