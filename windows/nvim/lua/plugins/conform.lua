return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
      },
      formatters = {
        prettier = {
          prepend_args = {
            "--print-width",
            "100",
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
            "avoid",
            "--single-attribute-per-line",
            "false",
            "--bracket-same-line",
            "false",
          },
        },
      },
    },
  },
}
