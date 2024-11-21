return {
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    priority = 1000,
    config = function()
      require('rose-pine').setup {
        variant = 'auto',
        dark_variant = 'main',
        bold_vert_split = false,
        dim_nc_background = false,
        disable_background = true,
        disable_float_background = true,
        disable_italics = false,
      }

      vim.cmd.colorscheme 'rose-pine'
      vim.cmd.hi 'Comment gui=italic'
    end,
  },
  -- transparent so we can let the terminal opacity handle the background
  {
    'xiyaowong/transparent.nvim',
    lazy = false,
    config = function()
      require('transparent').setup {
        extra_groups = {
          'NormalFloat',
          'NvimTreeNormal',
        },
        exclude_groups = {},
      }
      vim.cmd 'TransparentEnable'
    end,
  },
}
