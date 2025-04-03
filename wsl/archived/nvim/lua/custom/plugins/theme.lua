-- docs: https://github.com/rose-pine/neovim
local rose_pine = {
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
}

-- https://github.com/rebelot/kanagawa.nvim
local kanagawa = {
  'rebelot/kanagawa.nvim',
  name = 'kanagawa',
  priority = 1000,
  config = function()
    require('kanagawa').setup {
      compile = false,
      undercurl = true,
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = true,
      dimInactive = false,
      terminalColors = true,
      theme = 'wave',
      background = {
        dark = 'wave',
        light = 'lotus',
      },
      overrides = function(colors)
        local theme = colors.theme
        return {
          NormalFloat = { bg = 'none' },
          FloatBorder = { bg = 'none' },
          FloatTitle = { bg = 'none' },
          TelescopeBorder = { bg = 'none' },
          VertSplit = { bg = 'none', fg = theme.ui.bg_m3 },
          SignColumn = { bg = 'none' },
          LineNr = { bg = 'none' },
          CursorLineNr = { bg = 'none' },
          FoldColumn = { bg = 'none' },

          LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
          MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
        }
      end,
    }
    vim.cmd.colorscheme 'kanagawa'
    vim.cmd.hi 'Comment gui=italic'
  end,
}

-- transparent configuration
local transparent = {
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
}

-- NOTE: switch theme here
local theme = kanagawa
return {
  theme,
  transparent,
}
