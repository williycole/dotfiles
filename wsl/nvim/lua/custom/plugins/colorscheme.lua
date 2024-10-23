return { -- NOTE: set colorscheme here
  'rose-pine/neovim',
  name = 'rose-pine',
  priority = 1000, -- Make sure to load this before all the other start plugins.
  config = function()
    require('rose-pine').setup {
      -- You can configure Rose Pine here
      variant = 'auto', -- Options: 'auto', 'main', 'moon', 'dawn'
      dark_variant = 'main', -- 'main' or 'moon' for dark variant
      bold_vert_split = false,
      dim_nc_background = false,
      disable_background = false,
      disable_float_background = false,
      disable_italics = false,
    }

    -- Load the colorscheme here.
    vim.cmd.colorscheme 'rose-pine'

    -- You can configure highlights by doing something like:
    vim.cmd.hi 'Comment gui=italic'
  end,
}
