-- https://github.com/nvim-lualine/lualine.nvim?tab=readme-ov-file
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('lualine').setup {
      options = {
        theme = 'auto', -- Auto-detect colorscheme from Tinted Vim
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = {
          {
            'filename',
            path = 1, -- Show relative path (0 = filename only)
            symbols = { modified = ' [+]', readonly = ' [-]' },
          },
        },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_c = {
          {
            'filename',
            path = 1, -- Show path in inactive windows too
            color = { fg = '#bbbbbb', gui = 'italic' },
          },
        },
      },
    }
  end,
}
