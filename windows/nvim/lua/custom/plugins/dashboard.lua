-- docs: https://github.com/nvimdev/dashboard-nvim, alternative https://github.com/goolord/alpha-nvim for even more customization
-- TODO: migrate this to snacks.nvim dashboard settings customize futher, image, or gif, icons etc..
--
local dashboard = {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  opts = {
    theme = 'hyper',
    config = {
      week_header = {
        enable = true,
        concat = '',
        append = {
          '',
          '',
          '▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
          '██ ████▀▄▄▀█ ▄▄▄████ ▄▄▄ █ ▄▄█ ▄▄█',
          '██ ████ ██ █ █▄▀████ ███ █ ▄██ ▄██',
          '██ ▀▀ ██▄▄██▄▄▄▄████ ▀▀▀ █▄███▄███',
          '▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
          '',
          '',
        },
      },
      hide = {
        statusline = true,
        tabline = false,
        winbar = true,
      },
      shortcut = {
        { desc = '󰊳 Update', group = '@property', action = 'Lazy update', key = 'u' },
        {
          icon = ' ',
          icon_hl = '@variable',
          desc = 'Files',
          group = 'Label',
          action = 'Telescope find_files',
          key = 'f',
        },
        {
          desc = ' Apps',
          group = 'DiagnosticHint',
          action = 'Telescope app',
          key = 'a',
        },
        {
          desc = ' dotfiles',
          group = 'Number',
          action = 'Telescope dotfiles',
          key = 'd',
        },
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
        '',
        ' 󱎓 Keep it simple stupid 󱎓 ',
        '',
        '',
        '(੭｡╹▿╹｡)੭',
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
return { dashboard }
