-- Optional Angular Language Server settins, only if needed
-- pretty much the same as the one being used below but with a few more settings
-- probably will be removed in the future
-- local angularls = function()
--   local original_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]
--   vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
--     if result and result.diagnostics then
--       local filtered = {}
--       for _, diagnostic in ipairs(result.diagnostics) do
--         -- Filter out Angular custom element errors AND ESLint unsafe warnings
--         local should_filter = diagnostic.code == -998001
--           or diagnostic.code == -998002
--           or (
--             diagnostic.source == "eslint"
--             and (
--               string.match(diagnostic.message or "", "Unsafe assignment")
--               or string.match(diagnostic.message or "", "Unsafe member access")
--               or string.match(diagnostic.message or "", "Unsafe call")
--               or string.match(diagnostic.message or "", "Unsafe return")
--               or string.match(diagnostic.message or "", "Unexpected any")
--             )
--           )
--         if not should_filter then
--           table.insert(filtered, diagnostic)
--         end
--       end
--       result.diagnostics = filtered
--     end
--     return original_handler(err, result, ctx, config)
--   end
--   return true
-- end

-- angular ls settings, helps with some diagnostics error handling we don't care about most of the time
local angularls = function()
  -- Store the original handler
  local original_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]
  -- Create custom handler that filters out custom element errors
  vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
    if result and result.diagnostics then
      local filtered = {}
      for _, diagnostic in ipairs(result.diagnostics) do
        -- Filter out specific Angular error codes for unknown elements
        if not (diagnostic.code == -998001 or diagnostic.code == -998002) then
          table.insert(filtered, diagnostic)
        end
      end
      result.diagnostics = filtered
    end
    -- Call original handler with filtered results
    return original_handler(err, result, ctx, config)
  end

  return true
end

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

-- nvim-lint.eslint installed through LazExtras so here we just handle some options
-- this lets warnigns be a little less noisy for typescript

local eslint_lsp = function(_, opts)
  opts.settings = opts.settings or {}
  opts.settings.workingDirectories = { mode = "auto" }
  opts.settings.format = false
  opts.settings.experimental = {
    useFlatConfig = true,
  }
  opts.settings.rulesCustomizations = {
    { rule = "@typescript-eslint/no-unsafe-assignment", severity = "off" },
    { rule = "@typescript-eslint/no-unsafe-member-access", severity = "off" },
    { rule = "@typescript-eslint/no-unsafe-call", severity = "off" },
    { rule = "@typescript-eslint/no-unsafe-return", severity = "off" },
    { rule = "@typescript-eslint/no-explicit-any", severity = "off" },
  }
  return false -- Let LazyVim handle the rest
end

return {
  "neovim/nvim-lspconfig",
  opts = {
    setup = { -- just hook in the lsp configs here
      angularls = angularls,
      pyright = pyright,
      eslint = eslint_lsp,
      cssls = cssls,
    },
  },
}
