-- docs: https://github.com/ThePrimeagen/harpoon/tree/harpoon2
return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'folke/which-key.nvim',
  },
  config = function()
    local harpoon = require 'harpoon'

    -- REQUIRED
    harpoon:setup()

    -- Basic keymaps
    vim.keymap.set('n', '<leader>ha', function()
      harpoon:list():add()
    end, { desc = 'Harpoon add file' })

    vim.keymap.set('n', '<leader>hl', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Harpoon quick menu' })
    --TODO: navigate to a setup like oil and simplify this, we don't need leader
    -- vim.keymap.set('n', '<C-h>', function()
    --   harpoon.ui:toggle_quick_menu(harpoon:list())
    -- end, { desc = 'Harpoon quick menu' })
    --
    vim.keymap.set('n', '<leader>h1', function()
      harpoon:list():select(1)
    end, { desc = 'Harpoon file 1' })

    vim.keymap.set('n', '<leader>h2', function()
      harpoon:list():select(2)
    end, { desc = 'Harpoon file 2' })

    vim.keymap.set('n', '<leader>h3', function()
      harpoon:list():select(3)
    end, { desc = 'Harpoon file 3' })

    vim.keymap.set('n', '<leader>h4', function()
      harpoon:list():select(4)
    end, { desc = 'Harpoon file 4' })

    vim.keymap.set('n', '<leader>hp', function()
      harpoon:list():prev()
    end, { desc = 'Harpoon prev file' })

    vim.keymap.set('n', '<leader>hn', function()
      harpoon:list():next()
    end, { desc = 'Harpoon next file' })

    -- Extended functionality for splits and tabs
    harpoon:extend {
      UI_CREATE = function(cx)
        vim.keymap.set('n', '<C-v>', function()
          harpoon.ui:select_menu_item { vsplit = true }
        end, { buffer = cx.bufnr })

        vim.keymap.set('n', '<C-x>', function()
          harpoon.ui:select_menu_item { split = true }
        end, { buffer = cx.bufnr })

        vim.keymap.set('n', '<C-t>', function()
          harpoon.ui:select_menu_item { tabedit = true }
        end, { buffer = cx.bufnr })

        vim.keymap.set('n', 'da', function()
          harpoon:list():clear()
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { buffer = cx.bufnr, desc = 'Delete all Harpoon items' })
      end,
    }

    -- Telescope integration (optional)
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          finder = require('telescope.finders').new_table {
            results = file_paths,
          },
          previewer = require('telescope.config').values.file_previewer {},
          sorter = require('telescope.config').values.generic_sorter {},
        })
        :find()
    end

    vim.keymap.set('n', '<leader>hm', function()
      toggle_telescope(harpoon:list())
    end, { desc = 'Harpoon marks in Telescope' })
  end,
}
