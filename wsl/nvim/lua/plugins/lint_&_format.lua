-- formatting and linting to respect project settings
return {
  -- In lua/plugins/linting.lua
  {
    "mfussenegger/nvim-lint",
    opts = {
      -- Configure ESLint to use project config
      linters = {
        eslint = {
          -- Only run when config exists
          condition = function(ctx)
            return vim.fs.find({
              ".eslintrc",
              ".eslintrc.js",
              ".eslintrc.json",
              ".eslintrc.yaml",
              ".eslintrc.yml",
              "eslint.config.js",
            }, { path = ctx.filename, upward = true })[1] ~= nil
          end,
        },
      },
    },
  },
  -- In lua/plugins/formatting.lua
  {
    "stevearc/conform.nvim",
    opts = {
      -- Make Prettier use project config
      formatters = {
        prettier = {
          prepend_args = { "--config-precedence", "prefer-file" },
        },
      },
    },
  },
}
