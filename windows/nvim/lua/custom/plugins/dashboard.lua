-- docs: https://github.com/nvimdev/dashboard-nvim, alternative https://github.com/goolord/alpha-nvim for even more customization
-- TODO: customize futher, image, or gif, icons etc..
return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  opts = {
    theme = 'hyper',
    config = {
      header = {
        '                                                        ',
        '                                                        ',
        '                                             ▄▄▄▄   ▄▄▄▄',
        '▀████▀                          ▄▄█▀▀██▄   ▄█▀ ▀▀ ▄█▀ ▀▀',
        '  ██                          ▄██▀    ▀██▄ ██▀    ██▀   ',
        '  ██       ▄██▀██▄ ▄█▀█████   ██▀      ▀███████  █████  ',
        '  ██      ██▀   ▀████  ██     ██        ██ ██     ██    ',
        '  █▓     ▄██     ██▓▓███▀     ██        ██ ▓█     ▓█    ',
        '  █▓    ▒███     ▓█▓          ▀██      ██▀ ▓█     ▓█    ',
        '  ▓▓     ▓▓█     ▓▓▓▓▓▓▓▀     ▓██      ▓█▓ ▓▒     ▓▒    ',
        '  ▓▒    ▓▓▓▓▓   ▓▓▓▒          ▀█▓▓▓    ▓▓▓ ▓▒     ▓▒    ',
        '▒ ▒▒ ▓▒ ▒  ▒ ▒ ▒ ▒ ▒ ▒▓▒ ▒      ▒ ▒ ▒ ▒  ▒ ▒▒▒  ▒ ▒▒▒   ',
        '                  ▒▒     ▒▒                             ',
        '                  ▒▒▒▒ ▒▒                               ',
        '                                                        ',
        '                                                        ',
        os.date '%Y-%m-%d %H:%M:%S',
        '                                                        ',
      },
      hide = {
        statusline = true,
        tabline = false,
        winbar = true,
      },
      shortcut = {
        { desc = 'Update', group = '@property', action = 'Lazy update', key = 'u' },
        { desc = 'Files', group = '@property', action = 'Telescope find_files', key = 'f' },
        { desc = 'Apps', group = '@property', action = 'e ~/.config/nvim/lua/plugins/', key = 'a' },
        { desc = 'Dotfiles', group = '@property', action = 'e ~/.config/nvim/', key = 'd' },
      },
      project = {
        enable = true,
        limit = 8,
        icon = '',
        label = 'Recently Projects:',
        action = 'Telescope find_files cwd=',
      },
      mru = {
        limit = 10,
        icon = '',
        label = 'Most Recent Files:',
        cwd_only = false,
      },
      footer = {
        '',
        -- 'neovim loaded XX packages',
        '🚀 Sharp tools make good work.',
      },
    },
  },
  -- Setup Dashboard and then add further customization
  config = function(_, opts)
    -- Setup dashboard first
    require('dashboard').setup(opts)
    -- Set dashboard colors immediately
    vim.api.nvim_set_hl(0, 'DashboardHeader', { fg = '#F6C177' })
    -- Disable indent lines & ~'s on dashboard
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'dashboard',
      callback = function()
        require('ibl').setup_buffer(0, { enabled = false })
      end,
    })
    vim.opt.fillchars = { eob = ' ' }
  end,

  dependencies = {
    { 'nvim-tree/nvim-web-devicons' },
  },
}
