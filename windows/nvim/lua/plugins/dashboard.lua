-- TODO: add to default overrides
-- lua/plugins/dashboard.lua
return {
  "nvimdev/dashboard-nvim",
  lazy = false, -- As https://github.com/nvimdev/dashboard-nvim/pull/450, dashboard-nvim shouldn't be lazy-loaded to properly handle stdin.
  opts = function()
    local datetime = os.date("%Y-%m-%d %I:%M:%S %p")
    local logo = [[
Chase Understanding Not Results
⠀⠀⠀⠀⠀⠀⢀⣀⣀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢰⡄⠀⠀⣠⣾⣿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢸⡇⠐⠾⣿⣿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⡇⠀⢠⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠐⣿⣾⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⣠⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⢹⣿⣿⣿⣿⣿⣿⣿⣏⠀⠀⣄⠀⢻⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀
⠀⢸⠈⠉⣿⣿⣿⣿⣿⣿⡄⠀⢸⣤⣼⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀
⠀⠸⡆⠀⣿⣿⣿⣿⣿⣿⣿⠀⠀⢏⠙⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀
⠀⠀⠇⢀⣿⣿⣿⣿⣿⣿⣿⣧⡀⠸⡀⣿⣿⣿⢆⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣷⡄⢣⠻⣟⠉⢻⣆⠀⠀⠀⠀⠀
⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣾⣷⣿⣶⣾⣷⣶⣦⡀⠀⠀
⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡄
A Knight always has is breathing.
]]
    logo = string.rep("\n", 1) .. logo .. "\n" .. datetime .. "\n"

    local opts = {
      theme = "doom",
      hide = {
        -- this is taken care of by lualine
        -- enabling this messes up the actual laststatus setting after loading a file
        statusline = false,
      },
      config = {
        header = vim.split(logo, "\n"),
        -- stylua: ignore
        center = {
          { action = 'lua LazyVim.pick()()',                           desc = " Find File",       icon = " ", key = "f" },
          { action = "ene | startinsert",                              desc = " New File",        icon = " ", key = "n" },
          { action = 'lua LazyVim.pick("oldfiles")()',                 desc = " Recent Files",    icon = " ", key = "r" },
          { action = 'lua LazyVim.pick("live_grep")()',                desc = " Find Text",       icon = " ", key = "g" },
          { action = 'lua LazyVim.pick.config_files()()',              desc = " Config",          icon = " ", key = "c" },
          { action = 'lua require("persistence").load()',              desc = " Restore Session", icon = " ", key = "s" },
          { action = "LazyExtras",                                     desc = " Lazy Extras",     icon = " ", key = "x" },
          { action = "Lazy",                                           desc = " Lazy",            icon = "󰒲 ", key = "l" },
          { action = function() vim.api.nvim_input("<cmd>qa<cr>") end, desc = " Quit",            icon = " ", key = "q" },
        },
        footer = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
        end,
      },
    }

    for _, button in ipairs(opts.config.center) do
      button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
      button.key_format = "  %s"
    end

    -- open dashboard after closing lazy
    if vim.o.filetype == "lazy" then
      vim.api.nvim_create_autocmd("WinClosed", {
        pattern = tostring(vim.api.nvim_get_current_win()),
        once = true,
        callback = function()
          vim.schedule(function()
            vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
          end)
        end,
      })
    end

    return opts
  end,
}
-- return {
--   "nvimdev/dashboard-nvim",
--   lazy = false, -- As https://github.com/nvimdev/dashboard-nvim/pull/450, dashboard-nvim shouldn't be lazy-loaded to properly handle stdin.
--   opts = function()
--     local datetime = os.date("%Y-%m-%d %I:%M:%S %p")
--     local logo = [[
--
-- ⠀⠀⠀⠀⠀⠀⢀⣀⣀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
-- ⢰⡄⠀⠀⣠⣾⣿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
-- ⢸⡇⠐⠾⣿⣿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
-- ⠀⡇⠀⢠⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
-- ⠐⣿⣾⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⣠⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀
-- ⠀⢹⣿⣿⣿⣿⣿⣿⣿⣏⠀⠀⣄⠀⢻⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀
-- ⠀⢸⠈⠉⣿⣿⣿⣿⣿⣿⡄⠀⢸⣤⣼⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀
-- ⠀⠸⡆⠀⣿⣿⣿⣿⣿⣿⣿⠀⠀⢏⠙⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀
-- ⠀⠀⠇⢀⣿⣿⣿⣿⣿⣿⣿⣧⡀⠸⡀⣿⣿⣿⢆⠀⠀⠀⠀⠀⠀
-- ⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣷⡄⢣⠻⣟⠉⢻⣆⠀⠀⠀⠀⠀
-- ⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣾⣷⣿⣶⣾⣷⣶⣦⡀⠀⠀
-- ⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡄
--
--  ▄▀▀ █▄█ ▄▀▄ ▄▀▀ ██▀   █ █ █▄ █ █▀▄ ██▀ █▀▄ ▄▀▀ ▀█▀ ▄▀▄ █▄ █ █▀▄ █ █▄ █ ▄▀    █▄ █ ▄▀▄ ▀█▀   █▀▄ ██▀ ▄▀▀ █ █ █   ▀█▀ ▄▀▀
--  ▀▄▄ █ █ █▀█ ▄██ █▄▄   ▀▄█ █ ▀█ █▄▀ █▄▄ █▀▄ ▄██  █  █▀█ █ ▀█ █▄▀ █ █ ▀█ ▀▄█   █ ▀█ ▀▄▀  █    █▀▄ █▄▄ ▄██ ▀▄█ █▄▄  █  ▄██
--
-- 宇宙で会おう、カウボーイ...
-- ]]
--     logo = string.rep("\n", 1) .. logo .. "\n" .. datetime .. "\n"
--
--     local opts = {
--       theme = "doom",
--       hide = {
--         -- this is taken care of by lualine
--         -- enabling this messes up the actual laststatus setting after loading a file
--         statusline = false,
--       },
--       config = {
--         header = vim.split(logo, "\n"),
--         -- stylua: ignore
--         center = {
--           { action = 'lua LazyVim.pick()()',                           desc = " Find File",       icon = " ", key = "f" },
--           { action = "ene | startinsert",                              desc = " New File",        icon = " ", key = "n" },
--           { action = 'lua LazyVim.pick("oldfiles")()',                 desc = " Recent Files",    icon = " ", key = "r" },
--           { action = 'lua LazyVim.pick("live_grep")()',                desc = " Find Text",       icon = " ", key = "g" },
--           { action = 'lua LazyVim.pick.config_files()()',              desc = " Config",          icon = " ", key = "c" },
--           { action = 'lua require("persistence").load()',              desc = " Restore Session", icon = " ", key = "s" },
--           { action = "LazyExtras",                                     desc = " Lazy Extras",     icon = " ", key = "x" },
--           { action = "Lazy",                                           desc = " Lazy",            icon = "󰒲 ", key = "l" },
--           { action = function() vim.api.nvim_input("<cmd>qa<cr>") end, desc = " Quit",            icon = " ", key = "q" },
--         },
--         footer = function()
--           local stats = require("lazy").stats()
--           local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
--           return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
--         end,
--       },
--     }
--
--     for _, button in ipairs(opts.config.center) do
--       button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
--       button.key_format = "  %s"
--     end
--
--     -- open dashboard after closing lazy
--     if vim.o.filetype == "lazy" then
--       vim.api.nvim_create_autocmd("WinClosed", {
--         pattern = tostring(vim.api.nvim_get_current_win()),
--         once = true,
--         callback = function()
--           vim.schedule(function()
--             vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
--           end)
--         end,
--       })
--     end
--
--     return opts
--   end,
-- }
--     local logo = [[
-- ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
-- ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣤⡴⠶⠶⠶⠞⠛⠛⠙⠛⠛⠛⠳⠦⠤⣤⣤⣤⣤⣤⣤⠤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
-- ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣾⣿⣿⣿⣿⣷⣶⣴⣶⣿⣿⣿⣿⣶⣶⣶⣶⣤⣭⣉⣀⠀⠐⠾⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀
-- ⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣠⣴⠞⠹⣿⣿⡿⠁⢸⠸⣿⣿⣿⡿⣿⣿⡿⠏⠙⠛⠿⠿⢛⡿⣿⣧⣄⠘⣿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀
-- ⠀⠀⠀⠀⠀⠀⠀⣠⣿⡿⠏⠃⠀⢇⢻⣿⡿⣦⣤⣾⣿⣿⡁⢱⣟⠋⠁⠀⠀⠀⠀⠀⠀⠀⠩⡿⢫⣿⣿⠿⠿⣿⣿⣿⣆⠀⠀⠀⠀⠀
-- ⠀⠀⠀⠀⠀⢀⣾⣿⢢⢁⢀⢆⡇⠀⠉⠙⠻⠟⠋⠿⢛⣿⠗⢸⣿⣷⣀⠀⠀⠀⠀⢀⣤⢀⡠⠕⣉⢨⢴⣲⣯⣧⣿⣶⠟⠀⠀⠀⠀⠀
-- ⠀⠀⠀⠀⢠⣿⡟⠈⠀⠀⢸⠊⢸⡂⠀⠀⠈⣉⠭⠽⢛⡋⣀⣐⢛⠛⣛⢻⠳⠶⢟⣋⢨⣽⣦⣯⣿⣿⣿⣿⣟⣯⠟⠁⠀⠀⠀⠀⠀⠀
-- ⠀⠀⠀⠀⣾⣿⠁⠀⠀⠑⠌⠲⠘⠁⠀⡊⡅⣰⢩⣇⡾⠴⠷⠿⢾⣿⣷⣿⣾⣿⣷⣿⣿⢿⣿⢿⣿⣿⣿⣿⣽⣶⡀⠀⠀⠀⠀⠀⠀⠀
-- ⠀⠀⢀⣾⣿⣿⠇⠀⠀⠀⠈⠀⣠⡶⠛⠓⠃⠉⢁⠀⣠⣤⣤⣤⣤⣤⣈⣍⣛⣛⣚⣓⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀
-- ⠀⠀⣾⣿⣿⠆⠐⣄⡀⠀⢀⣾⣿⣿⣭⣵⣶⣷⣾⣿⣿⣿⣿⣿⣿⣿⡿⡟⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠁⠀⠀⠀⠀⠀⠀⠀
-- ⠀⢸⣿⣏⣏⢷⡀⣉⠿⣷⠸⣿⣿⣿⣿⣿⡿⣿⡿⢿⡿⢿⢿⠿⡉⠁⠁⡈⠀⠀⣀⢁⣰⣶⡿⠿⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
-- ⠀⣾⡿⡿⠀⠉⠁⠁⣥⣿⣷⣌⣿⣿⡇⠀⢀⠀⡀⠀⠃⠀⢄⠀⠡⠀⣄⣄⣤⡼⠿⠟⠋⠁⠠⠴⠾⠿⠿⠿⣿⣿⣶⣦⣀⠀⠀⠀⠀⠀
-- ⢀⣿⡋⠁⠠⠁⠈⠓⠌⢻⣿⣿⡟⢿⣿⣄⢸⣦⣷⣄⣀⣦⣤⣤⣴⣿⡿⠟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢻⣿⣿⣷⡄⠀⠀⠀
-- ⢸⣿⠊⠃⠠⠂⠂⢍⠂⠈⠿⠇⢀⢋⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⡀⠀⠀
-- ⢸⡧⡀⠀⠑⠔⠄⠂⠖⠀⢞⠈⠇⣸⣿⣿⣿⡿⠏⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣀⣀⣴⣿⣿⣽⢷⠀⠀
-- ⢸⣿⠊⠀⠀⠠⠀⣄⣾⣞⡆⣷⣧⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣟⣲⢺⣿⣗⣷⡾⣿⣿⣦⣄⢰⠀⠀
-- ⣿⠏⠀⠑⠈⢠⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⠛⣿⣿⠟⠛⣟⣻⣿⣶⣾⣊⡟⢁⡆⠀
-- ⠙⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠻⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⠁⢸⣿⠇⠀⠀⠈⠉⢿⣿⣯⣹⠷⢶⢧⡀
-- ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠃⠀⠻⡀⠀⠀⠀⠀⠈⠻⠿⠿⠶⠷⠛⠃
--  __         __ __           __  __ __  _____         __       __        __ ___   __  __ __       ___ __
-- /  |__| /\ (_ |_   /  \|\ ||  \|_ |__)(_  |  /\ |\ ||  \||\ |/ _   |\ |/  \ |   |__)|_ (_ /  \|   | (_
-- \__|  |/--\__)|__  \__/| \||__/|__| \ __) | /--\| \||__/|| \|\__)  | \|\__/ |   | \ |____)\__/|__ | __)
--
-- 宇宙で会おう、カウボーイ...
-- ]]
