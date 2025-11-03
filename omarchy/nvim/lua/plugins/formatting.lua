-- All formatting is handled by lsp.none-ls and other builtin configuration through LazyExtras and Mason
-- This and options.lua handel most of the formating. For more info on any file run ConformInfo or LspInfo.
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        json = { "prettier" }, -- Explicitly keep Prettier for non-TS files
        yaml = { "prettier" },
        lua = { "stylua" },
        go = { "gofmt" }, -- Default gofmt for go files, always favor gopls
        python = { "black" }, -- use black for python files
      },
      -- NOTE: SEEME this commented out code is used to organzie my imports but gives me
      ---- when its not commented out I get
      -- "Don't set `opts.format_on_save` for `conform.nvim`.**LazyVim** will use the conform formatter automatically"
      -- when its commented out I get "Language server `vtsls` does not support command `_typescript.didOrganizeImports`. This command may require a client extension."
      -- format_on_save = {
      --   timeout_ms = 1000, -- Allow time for LSP and none-ls formatters
      --   lsp_fallback = true, -- Use attached LSP servers (vtsls) for TS/JS
      -- },
      -- NOTE: See note in options.lua about this autocmd
      log_level = vim.log.levels.DEBUG, -- Debug output
      notify_on_error = true, -- Show errors in Neovim
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Keep eslint disabled for formatting
        eslint = { format = false },
        -- Enable formatting via vtsls
        -- TODO: do this later on with the rest of the research in here
        -- enable import sorting for ts by something else
        -- so that conform can auto handle formatting on save as needed
        -- this file should just handle how things are done
        vtsls = {
          settings = {
            typescript = {
              format = { enable = true },
            },
            javascript = {
              format = { enable = true },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              hint = {
                enable = true,
                paramType = true,
                paramName = "All",
                arrayIndex = "Enable",
                semicolon = "All",
                setType = true,
              },
            },
          },
        },
      },
    },
  },
  {
    "nvimtools/none-ls.nvim",
    opts = {
      sources = {
        -- LazyExtras gives us gofmt and gopls but these o not handle imports
        require("null-ls").builtins.formatting.goimports,
      },
    },
  },
}

-- Previously, using both 'prettier' and 'eslint_d' caused import ordering issues due to execution order conflicts
-- in conform.nvim, where prettier's pre-formatting might disrupt eslint_d's import sorting. Additionally, an ENOSPC
-- error ('System limit for number of file watchers reached') occurred with eslint_d's daemon due to the large
-- node_modules directory exceeding the default inotify max_user_watches limit (initially 65536). This was fixed by
-- increasing the limit to 262144 via 'sudo sysctl fs.inotify.max_user_watches=262144' and making it persistent in
-- /etc/sysctl.d/99-inotify.conf, then restarting the daemon. The solution now relies on none-ls.nvim for automatic
-- Go formatting (via goimports and gofumpt) as it was before, and uses LSP fallback with vtsls for TS/JS files to
-- match VSCode's import ordering and named import sorting (externals before relatives, alphabetical within groups
-- and within import declarations) via source.organizeImports code action, as eslint's flat config (eslint.config.mjs)
-- limited CLI rule overrides like sort-imports.
--
-- NOTE:⭐This may be what I need to start over with  then get the imports sorting properly
-- Near perfect match to vscode formatting, imports where the only difference, leaving this here for now for reference
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
--
--
--
-- TODO: research later
--
-- You’re running into two issues related to formatting and organizing imports for TypeScript/JavaScript with vtsls and conform.nvim:
--
-- 1. **Conform.nvim + LazyVim**:
--    LazyVim manages format-on-save for you, so you should not set `opts.format_on_save` in conform.nvim. That’s why you see the warning when you uncomment it.
--
-- 2. **Organize Imports with vtsls**:
--    The error `"Language server 'vtsls' does not support command '_typescript.didOrganizeImports'"` means vtsls doesn’t implement the VSCode-style organize imports command. This is a limitation of vtsls itself, not your config.
--
-- **Key points:**
-- - Formatting (prettier, stylua, gofmt, black) is handled by conform.nvim and none-ls.
-- - Organizing imports for TypeScript/JavaScript is not the same as formatting. vtsls may not support this command natively.
-- - You can’t use the commented-out conform.nvim `format_on_save` block with LazyVim, but that’s not related to organize imports.
--
-- **Alternatives for organizing imports:**
-- - Use a CLI tool (like `tslint`, `eslint --fix`, or `prettier --write`) for organizing imports.
-- - Use another LSP (like typescript-language-server) if you need that command.
-- - Consider a null-ls/none-ls source for organize imports if available.
--
-- **Tradeoffs:**
-- - Sticking with vtsls: better performance, but missing organize imports.
-- - Switching to typescript-language-server: more features, but possibly slower or less stable.
--
-- **Questions for you:**
-- - Is organizing imports on save a must-have, or is manual/CLI-based organization acceptable?
-- - Are you open to switching LSPs or adding a null-ls/none-ls source for this?
--
-- Let me know your priorities and I can suggest a more concrete approach.
