-- NOTE: all formatting is handled by lsp.none-ls and other builtin configuration through LazyExtras and Mason
-- For more info on any file run ConformInfo or LspInfo to see what you are working with.
-- Using these settings with the few others under lua/config/option.lua allows conform to take advantage
-- of project settings i.e. .prettierrc, .eslintrc, etc. without any extra configuration.
-- Perfect match to vscode formatting

-- NOTE: Previously, using both 'prettier' and 'eslint_d' caused import ordering issues due to execution order conflicts
-- in conform.nvim, where prettier's pre-formatting might disrupt eslint_d's import sorting. Additionally, an ENOSPC
-- error ('System limit for number of file watchers reached') occurred with eslint_d's daemon due to the large
-- node_modules directory exceeding the default inotify max_user_watches limit (initially 65536). This was fixed by
-- increasing the limit to 262144 via 'sudo sysctl fs.inotify.max_user_watches=262144' and making it persistent in
-- /etc/sysctl.d/99-inotify.conf, then restarting the daemon. The solution now relies on none-ls.nvim for automatic
-- Go formatting (via goimports and gofumpt) as it was before, and uses LSP fallback with vtsls for TS/JS files to
-- match VSCode's import ordering and named import sorting (externals before relatives, alphabetical within groups
-- and within import declarations) via source.organizeImports code action, as eslint's flat config (eslint.config.mjs)
-- limited CLI rule overrides like sort-imports.
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        json = { "prettier" }, -- Explicitly keep Prettier for non-TS files
        yaml = { "prettier" },
        lua = { "stylua" }, -- Keep Stylua for Lua
      },
      format_on_save = {
        timeout_ms = 1000, -- Allow time for LSP and none-ls formatters
        lsp_fallback = true, -- Use attached LSP servers (vtsls) for TS/JS
      },
      log_level = vim.log.levels.DEBUG, -- Debug output
      notify_on_error = true, -- Show errors in Neovim
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        eslint = { format = false }, -- Keep eslint disabled for formatting
        vtsls = {
          settings = {
            typescript = {
              format = { enable = true }, -- Enable formatting
            },
            javascript = {
              format = { enable = true },
            },
          },
        },
      },
    },
  },
  {
    "nvimtools/none-ls.nvim",
    opts = {
      sources = { -- Ensure Go formatters are enabled if not auto-configured
        require("null-ls").builtins.formatting.goimports,
        require("null-ls").builtins.formatting.gofumpt,
      },
    },
  },
}

-- NOTE: Near perfect match to vscode formatting, imports where the only difference, leaving this here for now for reference
--
-- return {
--   {
--     "stevearc/conform.nvim",
--     opts = {
--       formatters_by_ft = {
--         typescript = { "prettier", "eslint_d" },
--         typescriptreact = { "prettier", "eslint_d" },
--         javascript = { "prettier", "eslint_d" },
--         javascriptreact = { "prettier", "eslint_d" },
--         json = { "prettier", "eslint_d" },
--         yaml = { "prettier", "eslint_d" },
--       },
--     },
--   },
-- }
