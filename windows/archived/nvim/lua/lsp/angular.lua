return {
  setup = function(capabilities)
    return {
      -- Define which files are considered Angular files
      filetypes = { 'typescript', 'html', 'angular.html', 'typescriptreact' },

      -- Important: Use proper project detection
      root_dir = require('lspconfig.util').root_pattern('angular.json', 'nx.json', 'project.json'),

      -- Pass the shared capabilities
      capabilities = capabilities,

      -- Add an on_attach function for Angular-specific features
      on_attach = function(client, bufnr)
        -- You can add Angular-specific keymaps here if needed

        -- Enable formatting on save for Angular files
        if client.supports_method 'textDocument/formatting' then
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = vim.api.nvim_create_augroup('AngularFormatting', { clear = true }),
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format {
                filter = function(c)
                  return c.name == 'angularls'
                end,
                bufnr = bufnr,
              }
            end,
          })
        end
      end,

      settings = {
        angular = {
          analyticsSharing = false,
          suggestStrictMode = true,
          autoImportQuotes = 'double',
          completions = {
            showComponentAndDirectivePlaceholders = true,
          },
          -- Add this option for handling custom components
          experimental = {
            skipUnknownComponentValidation = true,
          },
          -- Add Angular template validation settings
          templateParser = {
            -- This is critical for custom components
            ignoreUnknownTags = true,
            ignoreUnknownAttributes = true,
          },
          schemas = {
            'CUSTOM_ELEMENTS_SCHEMA',
          },
        },
      },
    }
  end,
}
