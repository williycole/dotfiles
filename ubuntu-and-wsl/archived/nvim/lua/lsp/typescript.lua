-- typescript.lua: TypeScript LSP configuration
local M = {}
-- TypeScript-specific keymaps to add when LSP attaches
local function ts_keymaps(bufnr)
  -- Add TypeScript-specific keymaps here
  vim.keymap.set('n', '<leader>toi', ':TypescriptOrganizeImports<CR>', { buffer = bufnr, desc = 'Organize Imports' })
  vim.keymap.set('n', '<leader>tru', ':TypescriptRemoveUnused<CR>', { buffer = bufnr, desc = 'Remove Unused Variables' })
  vim.keymap.set('n', '<leader>tfi', ':TypescriptFixAll<CR>', { buffer = bufnr, desc = 'Fix All' })
  vim.keymap.set('n', '<leader>trf', ':TypescriptRenameFile<CR>', { buffer = bufnr, desc = 'Rename File' })
end

function M.setup(capabilities)
  return {
    filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'typescript.tsx' },
    capabilities = capabilities,
    -- Add on_attach for TypeScript-specific features
    on_attach = function(client, bufnr)
      -- Add TypeScript-specific keymaps
      ts_keymaps(bufnr)

      -- Set up autoformatting on save for TypeScript files
      if client.supports_method 'textDocument/formatting' then
        vim.api.nvim_create_autocmd('BufWritePre', {
          group = vim.api.nvim_create_augroup('TypeScriptFormatting', { clear = true }),
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format {
              filter = function(c)
                return c.name == 'ts_ls'
              end,
              bufnr = bufnr,
              timeout_ms = 1000,
            }
          end,
        })
      end
    end,
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
        suggest = {
          completeFunctionCalls = true,
        },
        format = {
          indentSize = 2,
          convertTabsToSpaces = true,
          tabSize = 2,
        },
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
        suggest = {
          completeFunctionCalls = true,
        },
        format = {
          indentSize = 2,
          convertTabsToSpaces = true,
          tabSize = 2,
        },
      },
      completions = {
        completeFunctionCalls = true,
      },
    },
    commands = {
      TypescriptOrganizeImports = {
        function()
          vim.lsp.buf.execute_command {
            command = '_typescript.organizeImports',
            arguments = { vim.api.nvim_buf_get_name(0) },
            title = '',
          }
        end,
        description = 'Organize Imports',
      },
      TypescriptRemoveUnused = {
        function()
          vim.lsp.buf.execute_command {
            command = '_typescript.removeUnused',
            arguments = { vim.api.nvim_buf_get_name(0) },
            title = '',
          }
        end,
        description = 'Remove Unused Variables',
      },
      TypescriptFixAll = {
        function()
          vim.lsp.buf.execute_command {
            command = '_typescript.fixAll',
            arguments = { vim.api.nvim_buf_get_name(0) },
            title = '',
          }
        end,
        description = 'Fix All',
      },
      TypescriptRenameFile = {
        function()
          local current_file = vim.api.nvim_buf_get_name(0)
          local input_opts = {
            prompt = 'New File Name: ',
            default = current_file,
          }
          vim.ui.input(input_opts, function(new_file)
            if new_file and new_file ~= '' and new_file ~= current_file then
              vim.lsp.buf.execute_command {
                command = '_typescript.moveToFile',
                arguments = { current_file, new_file },
                title = '',
              }
            end
          end)
        end,
        description = 'Rename File',
      },
    },
  }
end

return M
