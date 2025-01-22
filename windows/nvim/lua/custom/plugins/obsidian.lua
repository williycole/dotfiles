-- docs: https://github.com/epwalsh/obsidian
-- Base Setup
-- return {
--   'epwalsh/obsidian.nvim',
--   version = '*',
--   lazy = true,
--   ft = 'markdown',
--   dependencies = {
--     'nvim-lua/plenary.nvim',
--     'hrsh7th/nvim-cmp',
--     'nvim-telescope/telescope.nvim',
--   },
--   opts = {
--     workspaces = {
--       {
--         name = 'personal',
--         path = '~/repos/cb-vault',
--       },
--     },
--     notes_subdir = nil,
--     daily_notes = {
--       folder = '1. Overwolf/daily-notes',
--       date_format = '%Y-%m-%d',
--       template = '1. Overwolf/zbag-of-holding/templates/daily template.md', -- Updated path
--     },
--     templates = {
--       subdir = '1. Overwolf/zbag-of-holding/templates', -- Updated path
--       date_format = '%Y-%m-%d',
--       time_format = '%H:%M',
--     },
--     completion = {
--       nvim_cmp = true,
--       min_chars = 2,
--     },
--     new_notes_location = 'current_dir',
--     wiki_link_func = function(opts)
--       return require('obsidian.util').wiki_link_id_prefix(opts)
--     end,
--     preferred_link_style = 'wiki',
--     open_notes_in = 'current',
--     ui = {
--       enable = true,
--       update_debounce = 200,
--       checkboxes = {
--         [' '] = { char = '☐', hl_group = 'ObsidianTodo' },
--         ['x'] = { char = '✔', hl_group = 'ObsidianDone' },
--       },
--     },
--   },
--   config = function(_, opts)
--     require('obsidian').setup(opts)
--     vim.api.nvim_create_autocmd('FileType', {
--       pattern = 'markdown',
--       callback = function()
--         vim.opt_local.conceallevel = 2
--       end,
--     })
--   end,
-- }

-- Base Setup with Daily Rollover
return {
  'epwalsh/obsidian.nvim',
  version = '*',
  lazy = true,
  ft = 'markdown',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'hrsh7th/nvim-cmp',
    'nvim-telescope/telescope.nvim',
  },
  opts = {
    workspaces = {
      {
        name = 'personal',
        path = '~/repos/cb-vault',
      },
    },
    notes_subdir = nil,
    daily_notes = {
      folder = '1. Overwolf/daily-notes',
      date_format = '%Y-%m-%d',
      template = '1. Overwolf/zbag-of-holding/templates/daily template.md',
    },
    templates = {
      subdir = '1. Overwolf/zbag-of-holding/templates',
      date_format = '%Y-%m-%d',
      time_format = '%H:%M',
    },
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },
    new_notes_location = 'current_dir',
    wiki_link_func = function(opts)
      return require('obsidian.util').wiki_link_id_prefix(opts)
    end,
    preferred_link_style = 'wiki',
    open_notes_in = 'current',
    ui = {
      enable = true,
      update_debounce = 200,
      checkboxes = {
        [' '] = { char = '☐', hl_group = 'ObsidianTodo' },
        ['x'] = { char = '✔', hl_group = 'ObsidianDone' },
      },
    },
  },
  config = function(_, opts)
    require('obsidian').setup(opts)

    -- Set conceallevel for markdown files
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'markdown',
      callback = function()
        vim.opt_local.conceallevel = 2
      end,
    })

    -- Add rollover functionality
    vim.api.nvim_create_autocmd('BufNewFile', {
      pattern = vim.fn.expand '~/repos/cb-vault/1. Overwolf/daily-notes' .. '/*.md',
      callback = function()
        local function get_previous_note()
          local notes_dir = vim.fn.expand '~/repos/cb-vault/1. Overwolf/daily-notes'
          local files = vim.fn.glob(notes_dir .. '/*.md', false, true)
          table.sort(files, function(a, b)
            return a > b
          end)

          -- Find the most recent file that's not today's file
          local today = os.date '%Y-%m-%d'
          for _, file in ipairs(files) do
            local date = file:match '([%d-]+).md$'
            if date and date < today then
              return file
            end
          end
          return nil
        end

        local function extract_unchecked_todos(file_path)
          local todos = {}
          local current_section = nil
          local file = io.open(file_path, 'r')

          if file then
            for line in file:lines() do
              -- Track the current section
              local section = line:match '^## (.+)$'
              if section then
                current_section = section
              end

              -- Capture unchecked todos with their indentation
              local indent = line:match '^(%s*)'
              local todo = line:match '^%s*- %[ %](.+)$'
              if todo and current_section == 'TODO first week' then
                table.insert(todos, { indent = indent, text = line })
              end
            end
            file:close()
          end
          return todos
        end

        -- Get the previous note and extract todos
        local prev_note = get_previous_note()
        if prev_note then
          local todos = extract_unchecked_todos(prev_note)

          -- If we found unchecked todos, add them to the new note
          if #todos > 0 then
            -- Wait for the template to be loaded
            vim.defer_fn(function()
              -- Find the "TODO first week" section
              local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
              local todo_section_index = nil

              for i, line in ipairs(lines) do
                if line:match '^## TODO first week$' then
                  todo_section_index = i
                  break
                end
              end

              if todo_section_index then
                -- Insert todos after the section header
                local new_lines = {}
                for _, todo in ipairs(todos) do
                  table.insert(new_lines, todo.text)
                end

                vim.api.nvim_buf_set_lines(0, todo_section_index, todo_section_index, false, new_lines)
              end
            end, 100) -- Small delay to ensure template is loaded
          end
        end
      end,
    })
  end,
}
