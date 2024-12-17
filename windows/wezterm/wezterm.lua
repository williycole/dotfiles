local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Window configuration
config.window_decorations = "TITLE | RESIZE"

-- Color scheme
config.color_scheme = 'rose-pine'
-- config.window_background_opacity = 0.95

-- Font configuration
config.font = wezterm.font('DroidSansM Nerd Font Propo')
config.font_size = 12.0

-- Tab bar
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- Key bindings
config.keys = {
  {
    key = 't',
    mods = 'CTRL',
    action = wezterm.action.SpawnCommandInNewTab {
      args = {'wsl.exe', '--distribution', 'Ubuntu-24.04'},
    },
  },
  {
    key = 'w',
    mods = 'CTRL',
    action = wezterm.action.CloseCurrentTab{confirm=true},
  },
}

-- Launch menu
config.launch_menu = {
  {
    label = 'PowerShell',
    args = {'powershell.exe'},
  },
  {
    label = 'Ubuntu 24.04',
    args = {'wsl.exe', '--distribution', 'Ubuntu-24.04'},
  },
}

-- Set default program to run in new tabs/windows
config.default_prog = {'wsl.exe', '--distribution', 'Ubuntu-24.04'}

return config

