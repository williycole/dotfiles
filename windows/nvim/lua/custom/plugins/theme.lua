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
          TelescopeTitle = { fg = theme.ui.special, bold = true },
          TelescopePromptNormal = { bg = theme.ui.bg_p1 },
          TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
          TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
          TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
          TelescopePreviewNormal = { bg = theme.ui.bg_dim },
          TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },
        }
      end,
    }
    vim.cmd.colorscheme 'kanagawa'
    vim.cmd.hi 'Comment gui=italic'
  end,
}

-- transparent configuration
local transparent = {
  { 'xiyaowong/transparent.nvim' },
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
