-- formatting and linting to respect project settings
local nvimlint = {
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
}

local conform = {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters = opts.formatters or {}

    -- Define your custom prettier formatter for Angular HTML
    opts.formatters.prettier_htmlangular = {
      command = "prettier",
      args = {
        "--config-precedence",
        "cli-override", -- force CLI flags to take precedence
        "--parser",
        "angular",
        "--trailing-comma",
        "none",
        "--stdin-filepath",
        "$FILENAME",
        -- other defaults you could set
        -- "--tab-width",
        -- "2",
        -- "--single-quote",
        -- "true",
        -- "--print-width",
        -- "120",
      },
      stdin = true,
    }

    opts.formatters_by_ft = opts.formatters_by_ft or {}
    -- Map the htmlangular filetype to your custom formatter
    opts.formatters_by_ft.htmlangular = { "prettier_htmlangular" }
  end,
}

return { nvimlint, conform }
