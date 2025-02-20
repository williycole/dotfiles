-- docs:  https://github.com/neovim/nvim-lspconfig
-- Automatically install LSPs and related tools to stdpath for Neovim
-- add LSP Deps here for anything custom
capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.diagnostic = { dynamicRegistration = true }
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} }, -- Useful status updates for LSP.
    'hrsh7th/cmp-nvim-lsp', -- Allows extra capabilities provided by nvim-cmp
    'ray-x/lsp_signature.nvim',
  },
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        -- for lsp hints/docs inlines
        require('lsp_signature').on_attach({
          bind = true,
          handler_opts = {
            border = 'rounded',
          },
        }, event.buf)

        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end
        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', {
            clear = false,
          })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
        -- TODO: might can remove this as it's likely handled by go.nvim
        -- enable auto-import on save for gopls
        if client.name == 'gopls' then
          vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = event.buf,
            callback = function()
              vim.lsp.buf.format()
              vim.lsp.buf.code_action { context = { only = { 'source.organizeImports' } }, apply = true }
            end,
          })
        end
      end,
    })

    -- NOTE: Setup LSP's
    require('mason').setup()
    -- NOTE: add new lsps in one of three places
    -- 1. servers var
    local servers = {
      -- Golang
      gopls = {
        settings = {
          gopls = {
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
            gofumpt = false,
            usePlaceholders = false,
            completeUnimported = true,
          },
        },
      },
      --Lua
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            --TODO: double check
            diagnostics = {
              globals = { 'vim', 'Snacks' },
            },
          },
        },
      },
      markdownlint = {
        settings = {
          config = {
            MD013 = {
              line_length = 120,
              code_block_line_length = 120,
              heading_line_length = 120,
            },
          },
        },
      },
      angularls = {
        cmd = {
          'ngserver',
          '--stdio',
          '--tsProbeLocations',
          '${workspaceFolder}/node_modules', -- Absolute path template
          '--ngProbeLocations',
          '${workspaceFolder}/node_modules',
        },
        on_new_config = function(new_config, root_dir)
          new_config.cmd = {
            'ngserver',
            '--stdio',
            '--tsProbeLocations',
            root_dir .. '/node_modules', -- Dynamic path resolution
            '--ngProbeLocations',
            root_dir .. '/node_modules',
          }
        end,
        root_dir = require('lspconfig.util').root_pattern(
          'angular.json',
          'project.json',
          'package.json' -- Additional fallback
        ),
        capabilities = capabilities,
      },
    }
    -- NOTE: 2. here directly
    local ensure_installed = vim.tbl_keys(servers or {
      '@angular/language-server@18.2.0',
      'typescript-language-server',
      -- 'typescript',
      'pyright',
      'stylua',
      'markdownlint-cli2',
      -- 'ts_ls',
      -- 'angularls',
    })
    -- NOTE: 3. here via extending install list
    vim.list_extend(ensure_installed, {
      -- 'pyright',
      -- 'typescript-language-server', --TypeScript
      -- 'stylua', -- Used to format Lua code
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    -- Extend lsp capabilities as needed
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
    require('mason-lspconfig').setup {
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
      },
    }
  end,
}
