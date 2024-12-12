-- docs: https://github.com/nvimdev/dashboard-nvim, alternative https://github.com/goolord/alpha-nvim for even more customization
-- TODO: customize futher, time icons etc..
return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  opts = {
    theme = 'hyper',
    config = {
      header = {
        '',
        '██╗      ██████╗  ██████╗     ██████╗ ███████╗███████╗',
        '██║     ██╔═══██╗██╔════╝    ██╔═══██╗██╔════╝██╔════╝',
        '██║     ██║   ██║██║  ███╗   ██║   ██║█████╗  █████╗',
        '██║     ██║   ██║██║   ██║   ██║   ██║██╔══╝  ██╔══╝',
        '███████╗╚██████╔╝╚██████╔╝   ╚██████╔╝██║     ██║',
        '╚══════╝ ╚═════╝  ╚═════╝     ╚═════╝ ╚═╝     ╚═╝',
        '',
        '',
        os.date '%Y-%m-%d %H:%M',
        '',
      },
      -- week_header = {
      --   enable = true,
      --   concat = '',
      --   append = { '' },
      -- },
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
        'neovim loaded XX packages',
        '🚀 Sharp tools make good work.',
      },
    },
  },
  dependencies = {
    { 'nvim-tree/nvim-web-devicons' },
  },
}
