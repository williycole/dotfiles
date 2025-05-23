-- Custom/Non LazyExtra Lsp related Defaults
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
--
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

local pyright = function(_, opts)
  -- Custom Pyright settings (example: point to your venv)
  opts.settings = opts.settings or {}
  opts.settings.python = opts.settings.python or {}
  opts.settings.python.pythonPath = vim.fn.getcwd() .. "/.venv/bin/python"
  return false -- let LazyVim do the rest of the setup
end

local eslint_lsp = {
  settings = {
    workingDirectories = { mode = "auto" },
    format = false, -- Disable auto-format
    experimental = {
      useFlatConfig = true,
    },
    rulesCustomizations = {
      { rule = "@typescript-eslint/no-unsafe-assignment", severity = "off" },
      { rule = "@typescript-eslint/no-unsafe-member-access", severity = "off" },
      { rule = "@typescript-eslint/no-unsafe-call", severity = "off" },
      { rule = "@typescript-eslint/no-unsafe-return", severity = "off" },
      { rule = "@typescript-eslint/no-explicit-any", severity = "off" },
    },
  },
}

return {
  "neovim/nvim-lspconfig",
  opts = {
    setup = { -- just hook in the lsp configs here
      angularls = angularls,
      pyright = pyright,
      eslint = eslint_lsp,
    },
  },
}
