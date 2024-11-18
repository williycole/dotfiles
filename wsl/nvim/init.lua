-- ============ Initial Configuration ============
require 'custom/basic-keymaps-and-remaps'

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- ============ General UI Settings ============
-- Line numbers and UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.opt.scrolloff = 10

-- ============ General Clipboard Settings ============
-- TODO: this might not be needed if its not the default of kickstart, check it out and update accordingly
-- Clipboard and undo
-- vim.schedule(function()
--   vim.opt.clipboard = 'unnamedplus'
-- end)
-- vim.opt.undofile = true
-- NOTE: for Usage with WSL
vim.schedule(function()
  if vim.fn.has 'wsl' == 1 then
    vim.g.clipboard = {
      name = 'wsl-clipboard',
      copy = {
        ['+'] = 'clip.exe',
        ['*'] = 'clip.exe',
      },
      paste = {
        ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      },
      cache_enabled = 0,
    }
  else
    vim.opt.clipboard = 'unnamedplus'
  end
  vim.opt.undofile = true
end)

-- Search and replace
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = 'split'

-- Indentation and whitespace
vim.opt.breakindent = true
vim.opt.list = false
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Performance and timing
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Split behavior
vim.opt.splitright = true
vim.opt.splitbelow = true

-- ============ Autocommands ============
-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- ============ Plugin Management ============
-- Install and configure lazy.nvim plugin manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end
vim.opt.rtp:prepend(lazypath)

-- ============ Plugin Configuration ============
require('lazy').setup({
  -- Basic plugins
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  -- Git integration
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  -- LSP and development tools
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },

  -- Additional plugins
  require 'kickstart.plugins.debug',
  require 'kickstart.plugins.indent_line',
  require 'kickstart.plugins.lint',
  require 'kickstart.plugins.autopairs',
  require 'kickstart.plugins.neo-tree',
  require 'kickstart.plugins.gitsigns',

  -- Custom plugins
  { import = 'custom.plugins' },
  {
    'nvim-tree/nvim-web-devicons',
    lazy = false,
  },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
