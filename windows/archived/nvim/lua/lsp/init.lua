-- pull in gonvim since handles all go stuff
-- minus formatting, TODO: figure out how to make handle that
require 'lsp.gonvim'
-- project level typescript/javascript
require 'lsp.ts_js_project_config'

-- ⭐init.lua: Main LSP configuration
local lsps = {
  'neovim/nvim-lspconfig', -- for attaching lsps to your nvim instance
  dependencies = {
    { 'williamboman/mason.nvim', config = true }, -- Must be loaded before dependants
    'williamboman/mason-lspconfig.nvim', -- this gives us 'ensure_installed'
    'WhoIsSethDaniel/mason-tool-installer.nvim', -- todo add comment
    { 'j-hui/fidget.nvim', opts = {} }, -- Useful status updates for LSP.
    'hrsh7th/cmp-nvim-lsp', -- Allows extra capabilities provided by nvim-cmp
    'ray-x/lsp_signature.nvim', -- todo add comment
  },
  -- shut up semantic tokens error
  config = function()
    -- 🦄stuff to do at the beginning of the config
    vim.lsp.handlers['textDocument/semanticTokens/full'] = function()
      return nil
    end
    -- Add this near the start of your lsp config
    vim.g.angular_component_validation = false
    -- Create a local function to handle Angular schemas
    local function create_angular_schemas()
      local angularSchemas = {
        schemas = {
          CUSTOM_ELEMENTS_SCHEMA = true,
          NO_ERRORS_SCHEMA = false, -- Only enable if CUSTOM_ELEMENTS_SCHEMA isn't enough
        },
      }
      return angularSchemas
    end -- 🦄
    -- 󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆󱕆
    -- ⬜ Attach Lsp's
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        -- lsp highlights
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
        -- for lsp hints/docs inlines
        require('lsp_signature').on_attach({
          bind = true,
          handler_opts = {
            border = 'rounded',
          },
        }, event.buf)
        -- map lsp keys
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
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- ⬜ Setup LSP's here
    -- For correct lsp names see docs here:https://github.com/neovim/nvim-lspconfig
    -- Then install it with :Mason, names between lspconfig and Mason may differ.
    require('mason').setup()
    local ts_config = require 'lsp.typescript'
    local angularls = require 'lsp.angular'
    vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
      pattern = '*.component.html',
      callback = function()
        vim.bo.filetype = 'angular.html'
      end,
    })

    -- all basic lsps
    local servers = {
      cssls = {},
      html = {
        filetypes = { 'html', 'htmlangular', 'angular.html' },
        init_options = {
          configurationSection = { 'html', 'css', 'javascript' },
          embeddedLanguages = {
            css = true,
            javascript = true,
          },
          -- Add these options:
          customData = { './node_modules/@angular/language-server/angular-html.json' },
          provideFormatter = false,
        },
        settings = {
          html = {
            validate = {
              scripts = true,
              styles = true,
              -- Set HTML validation to be more lenient for Angular:
              customElements = true,
              angular = true,
            },
            experimental = {
              customData = { './node_modules/@angular/language-server/angular-html.json' },
            },
          },
          schemas = create_angular_schemas(),
        },
      },
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            diagnostics = { --TODO: double check
              globals = { 'vim', 'Snacks' },
            },
          },
        },
      },
      ts_ls = ts_config.setup,
      angularls = angularls.setup,
    }
    -- Capabilities setup
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.semanticTokens = nil
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
    -- Names here might not match above names. Only use Mason Official LSP names here. For names see :Mason
    local ensure_installed = vim.tbl_keys(servers or {
      -- LSP servers
      'typescript-language-server',
      'angular-language-server',
      'css-lsp',
      'html-lsp',
      'lua-language-server',
      -- 'markdownlint',
      -- Formatting/linting tools
      'eslint-lsp',
      'prettier',
      'stylua',
    })
    -- include things here to add via extending install list, i.e. add 'stylua', 'pyright', 'typescript-language-server',
    vim.list_extend(ensure_installed, {})
    require('mason-tool-installer').setup {
      ensure_installed = ensure_installed,
      auto_update = true,
      run_on_start = true,
      start_delay = 3000, -- Add delay for stability
    }
    -- lspconfig setup to handle the function-based config & extend lspconfig capabilities as needed
    require('mason-lspconfig').setup {
      ensure_installed = ensure_installed,
      automatic_installation = true,
      handlers = {
        function(server_name)
          local server = servers[server_name]

          -- Handle both function configurations and table configurations
          if type(server) == 'function' then
            -- Call the function to get the config
            local config = server(capabilities)
            config.on_init = function(client, _)
              if client.server_capabilities.semanticTokensProvider then
                client.server_capabilities.semanticTokensProvider = false
              end
              return true
            end
            require('lspconfig')[server_name].setup(config)
          else
            -- Handle regular table configurations
            server = server or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            server.on_init = function(client, _)
              if client.server_capabilities.semanticTokensProvider then
                client.server_capabilities.semanticTokensProvider = false
              end
              return true
            end
            require('lspconfig')[server_name].setup(server)
          end
        end,
      },
    }
  end,
}
return { lsps }
