vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Basic Keymaps
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })

-- Diagnostic navigation
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic quickfix list' })

-- Terminal mode exit
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Split navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Remaps
vim.keymap.set('n', '<leader>te', ':Ex<CR>', { noremap = true, silent = true, desc = 'Open file explorer' })
vim.keymap.set('n', '<leader>ts', ':Neotree toggle<CR>', { noremap = true, silent = true, desc = 'Toggle NeoTree' })
vim.keymap.set('n', '<leader>ww', ':w<CR>', { noremap = true, silent = true, desc = 'Save file' })
vim.keymap.set('n', '<leader>we', ':wq<CR>', { noremap = true, silent = true, desc = 'Save and quit' })
vim.keymap.set('n', '<leader>ee', ':q<CR>', { noremap = true, silent = true, desc = 'Quit' })
vim.keymap.set('n', '<leader>fe', ':q!<CR>', { noremap = true, silent = true, desc = 'Force Quit' })
vim.keymap.set('n', '<C-_>', 'gcc', { noremap = false, silent = true, desc = 'Toggle comment' })
vim.keymap.set('v', '<C-_>', 'gc', { noremap = false, silent = true, desc = 'Toggle comment' })
