-- In lua/plugins/lsp_custom.lua
-- return {
--   "neovim/nvim-lspconfig",
--   opts = {
--     servers = {
--       angularls = {
--         root_dir = function(fname)
--           return require("lspconfig.util").root_pattern("angular.json", "project.json")(fname)
--         end,
--         settings = {
--           angular = {
--             schemas = { "CUSTOM_ELEMENTS_SCHEMA" },
--           },
--         },
--       },
--     },
--   },
-- }
-- In lua/plugins/lsp_custom.lua
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
    },
  },
}
