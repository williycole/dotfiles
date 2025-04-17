-- Custom/Non LazyExtra Lsp related Defaults
return {
  "neovim/nvim-lspconfig",
  opts = {
    setup = {
      angularls = function()
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
      end,
      pyright = function(_, opts)
        -- Custom Pyright settings (example: point to your venv)
        opts.settings = opts.settings or {}
        opts.settings.python = opts.settings.python or {}
        opts.settings.python.pythonPath = vim.fn.getcwd() .. "/.venv/bin/python"
        return false -- let LazyVim do the rest of the setup
      end,
    },
  },
}
