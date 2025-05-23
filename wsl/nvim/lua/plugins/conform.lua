local angular_html_formatter_settings = {
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
    -- "--tab-width",
    -- "2",
    -- "--single-quote",
    -- "true",
    -- "--print-width",
    -- "120",
  },
  stdin = true,
}

return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    -- Add the custom formatter to the formatters table
    opts.formatters = opts.formatters or {}
    opts.formatters.prettier_htmlangular = angular_html_formatter_settings

    -- Map the htmlangular filetype to your custom formatter
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters_by_ft.htmlangular = { "prettier_htmlangular" }
  end,
}
