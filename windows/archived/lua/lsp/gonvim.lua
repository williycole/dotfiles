--  gonvim,  docs : https://github.com/ray-x/go.nvim
local gonvim = {
  'ray-x/go.nvim',
  dependencies = {
    'ray-x/guihua.lua',
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
    'folke/which-key.nvim',
  },
  config = function()
    require('go').setup {
      goimports = 'gopls', -- if set to 'gopls' will use golsp format
      gofmt = 'gopls', -- if set to gopls will use golsp format
      tag_transform = false,
      test_dir = '',
      comment_placeholder = '   ',
      lsp_cfg = true, -- false: use your own lspconfig
      lsp_gofumpt = true, -- true: set default gofmt in gopls format to gofumpt
      lsp_on_attach = true, -- use on_attach from go.nvim
      dap_debug = true,
      null_ls = { -- set to false to disable null-ls setup
        golangci_lint = {
          method = { 'NULL_LS_DIAGNOSTICS_ON_SAVE', 'NULL_LS_DIAGNOSTICS_ON_OPEN' }, -- when it should run
          -- disable = {'errcheck', 'staticcheck'}, -- linters to disable empty by default
          enable = { 'govet', 'ineffassign', 'revive', 'gosimple' }, -- linters to enable; empty by default
          severity = vim.diagnostic.severity.INFO, -- severity level of the diagnostics
        },
      },
    }

    -- Setup format on save
    local format_sync_grp = vim.api.nvim_create_augroup('GoFormat', {})
    vim.api.nvim_create_autocmd('BufWritePre', {
      pattern = '*.go',
      callback = function()
        -- Using goimports will also run gofmt
        require('go.format').goimports()
      end,
      group = format_sync_grp,
    })

    -- Shortcut Commands setup
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'go' },
      callback = function(ev)
        -- CTRL/control keymaps
        vim.api.nvim_buf_set_keymap(0, 'n', '<C-f>', ':GoFillStruct<CR>', {})
        vim.api.nvim_buf_set_keymap(0, 'n', '<C-e>', ':GoIfErr<CR>', {})
        vim.api.nvim_buf_set_keymap(0, 'n', '<C-s>', ':GoFillSwitch<CR>', {})
        -- test all
        -- vim.api.nvim_buf_set_keymap(0, 'n', '<C-a>', ':GoCoverage -t<CR>', {})
        vim.api.nvim_set_keymap('n', '<leader>c', '<cmd>lua require("go.coverage").toggle()<CR>', { noremap = true, silent = true })
        -- test current
        vim.api.nvim_buf_set_keymap(0, 'n', '<C-t>', ':GoTest -c<CR>', {})
        -- toggle coverage
        vim.api.nvim_buf_set_keymap(0, 'n', '<C-c>', ':GoCoverage -t<CR>', {})
      end,
      group = vim.api.nvim_create_augroup('go_autocommands', { clear = true }),
    })
  end,
  event = { 'CmdlineEnter' },
  ft = { 'go', 'gomod' },
  build = ':lua require("go.install").update_all_sync()',
}

--  docs: https://github.com/maxandron/goplements.nvim, Visualize Go struct & interface impls
local goimplements = {
  {
    'maxandron/goplements.nvim',
    ft = { 'go', 'gomod' },
    opts = {}, -- config here else leave blank
  },
}

return { gonvim, goimplements }
