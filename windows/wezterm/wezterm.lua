local wezterm = require("wezterm")

-- Wezterm-Config for nvim Access of this file
local wezterm_config_nvim = wezterm.plugin.require('https://github.com/winter-again/wezterm-config.nvim')
wezterm.on('user-var-changed', function(window, pane, name, value)
  local overrides = window:get_config_overrides() or {}
  overrides = wezterm_config_nvim.override_user_var(overrides, name, value)
  window:set_config_overrides(overrides)
end)

-- Everything Else
local act = wezterm.action
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Window configuration
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

-- Color Scheme & Background Color Configuration
-- Kanagawa
local kana_bg
kana_bg ="rgba(31, 31, 40, 0.85)"
config.color_scheme = 'Kanagawa (Gogh)'
bg_color = kana_bg

-- Background Image Configuration
-- Enable Acrylic effect for better blending
config.win32_system_backdrop = "Acrylic"
config.window_background_opacity = 0.95
config.window_background_opacity = 0.9
config.win32_system_backdrop = "Acrylic"
config.background = {
	{
		source = {
			File = "C:\\Users\\William\\Pictures\\wallpapers\\wallhaven-j8rj15.jpg",
		},
		height = "Cover", -- This preserves aspect ratio while filling the viewport
		width = "Cover",
		horizontal_align = "Center",
		vertical_align = "Middle",
	},
	{
		source = { Color =  bg_color }, -- TODO: figure out a better way
		height = "100%",
		width = "100%",
	},
}


-- Tab bar
config.use_fancy_tab_bar = true 
config.hide_tab_bar_if_only_one_tab = false
config.window_frame = {
  font_size = 11.0,
  -- The overall background color of the tab bar when the window is focused
  active_titlebar_bg = 'rgba(0, 0, 0, 0)',
  -- The overall background color of the tab bar whenthe window is not focused
  inactive_titlebar_bg = 'rgba(0, 0, 0, 0)',
}
config.colors = {
  tab_bar = {
	-- The color of the inactive tab bar edge/divider
    inactive_tab_edge = '#575757',
    -- The color of the strip that goes along the top of the window
    -- (does not apply when fancy tab bar is in use)
    -- background = '#0b0022',

    -- The active tab is the one that has focus in the window
    active_tab = {
      -- The color of the background area for the tab
      bg_color = '#363646',
      -- The color of the text for the tab
      fg_color = '#c0c0c0',

      -- Specify whether you want "Half", "Normal" or "Bold" intensity for the
      -- label shown for this tab.
      -- The default is "Normal"
      intensity = 'Normal',

      -- Specify whether you want "None", "Single" or "Double" underline for
      -- label shown for this tab.
      -- The default is "None"
      underline = 'None',

      -- Specify whether you want the text to be italic (true) or not (false)
      -- for this tab.  The default is false.
      italic = false,

      -- Specify whether you want the text to be rendered with strikethrough (true)
      -- or not for this tab.  The default is false.
      strikethrough = false,
    },

    -- Inactive tabs are the tabs that do not have focus
    inactive_tab = {
      bg_color = kana_bg,
      fg_color = '#808080',

      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `inactive_tab`.
    },

    -- You can configure some alternate styling when the mouse pointer
    -- moves over inactive tabs
    inactive_tab_hover = {
      bg_color = '#363646',
      fg_color = '#909090',
      italic = true,

      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `inactive_tab_hover`.
    },

    -- The new tab button that let you create new tabs
    new_tab = {
      bg_color = '#363646',
      fg_color = '#808080',

      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `new_tab`.
    },

    -- You can configure some alternate styling when the mouse pointer
    -- moves over the new tab button
    new_tab_hover = {
      bg_color = '#363646',
      fg_color = '#909090',
      italic = true,
      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `new_tab_hover`.
    },
  },
}

-- Font configuration
config.font = wezterm.font_with_fallback({
	"DroidSansM Nerd Font Propo",
	"Cambria Math",
	"STIX Two Math",
})
config.font_size = 12.0

-- Key bindings
config.keys = {
	-- Open WSL Home
	{
		key = "t",
		mods = "ALT",
		action = wezterm.action.SpawnCommandInNewTab({
			args = { "wsl.exe", "--distribution", "Ubuntu-24.04", "--exec", "/bin/zsh", "-c", "cd ~ && exec zsh" },
		}),
	},
	-- Open PowerShell Home
	{
		key = "p",
		mods = "ALT",
		action = wezterm.action.SpawnCommandInNewTab({
			args = { "powershell.exe" },
			cwd = wezterm.home_dir,
		}),
	},
	-- Close Tab
	{
		key = "e",
		mods = "ALT",
		action = wezterm.action.CloseCurrentTab({ confirm = false }),
	},
	-- Copy to clipboard
	{ key = "y", mods = "CTRL", action = act.CopyTo("ClipboardAndPrimarySelection") },
	-- Paste from clipboard
	{ key = "v", mods = "CTRL", action = act.PasteFrom("Clipboard") },
	-- Pane Navigation
	{ key = 'h', mods = 'CTRL', action = act.ActivatePaneDirection 'Left' },
	{ key = 'j', mods = 'CTRL', action = act.ActivatePaneDirection 'Down' },
	{ key = 'k', mods = 'CTRL', action = act.ActivatePaneDirection 'Up' },
	{ key = 'l', mods = 'CTRL', action = act.ActivatePaneDirection 'Right' },
	-- Close current pane 
	{ key = 'e', mods = 'CTRL', action = act.CloseCurrentPane { confirm = false } },  
}

-- Default program configuration
config.default_prog = {
	"wsl.exe",
	"--distribution",
	"Ubuntu-24.04",
	"--exec",
	"/bin/zsh",
	"-c",
	"cd ~ && exec zsh -l",
}

config.launch_menu = {
	{
		label = "PowerShell",
		args = { "powershell.exe" },
	},
	{
		label = "Ubuntu 24.04",
		args = { "wsl.exe", "--distribution", "Ubuntu-24.04", "--exec", "/bin/zsh", "-l" },
	},
}

return config
