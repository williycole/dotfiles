-- https://github.com/rachartier/tiny-inline-diagnostic.nvim
return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "VeryLazy",
  priority = 1000,
  opts = {

    preset = "ghost",

    hi = {
      error = "DiagnosticError",
      warn = "DiagnosticWarn",
      info = "DiagnosticInfo",
      hint = "DiagnosticHint",
      arrow = "NonText",
      background = "CursorLine",
      mixing_color = "None",
    },
    options = {
      show_source = true,
      use_icons_from_diagnostic = false,
      add_messages = true,
      throttle = 0,
      softwrap = 30,
      multiple_diag_under_cursor = false,
      multilines = {
        enabled = true,
        always_show = true,
      },
      show_all_diags_on_cursorline = true,
      enable_on_insert = true,
      overflow = {
        mode = "wrap",
      },
      virt_texts = {
        priority = 5000,
      },
    },
  },
  config = function(_, opts)
    vim.diagnostic.config({ virtual_text = false })
    require("tiny-inline-diagnostic").setup(opts)
    vim.opt.updatetime = 0
  end,
}
