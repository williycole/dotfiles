-- Custom Pyright settings (example: point to your venv)
-- more play nice magic, don't sweat this its not used much atm
local pyright = function(_, opts)
  opts.settings = opts.settings or {}
  opts.settings.python = opts.settings.python or {}
  opts.settings.python.pythonPath = vim.fn.getcwd() .. "/.venv/bin/python"
  return false -- let LazyVim do the rest of the setup
end

-- nothing custom here but currently nothig for this is baked int to LazyVim
-- and I want to use outline view for css
local cssls = function(_, opts)
  opts.filetypes = { "css", "scss", "less" }
  opts.settings = opts.settings or {}
  opts.settings.css = { validate = true }
  opts.settings.scss = { validate = true }
  return false -- Let LazyVim handle the rest
end

return {
  "neovim/nvim-lspconfig",
  opts = {
    setup = { -- just hook in the lsp configs here
      pyright = pyright,
      cssls = cssls,
    },
  },
}
