local wezterm = require("wezterm")

local act = wezterm.action

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Window configuration
config.window_decorations = "TITLE | RESIZE"

-- Color scheme
config.color_scheme = "rose-pine"

-- Background configuration
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
		-- TODO: rose pine colors, figure out a better way
		source = { Color = "rgba(25, 23, 36, 0.85)" },
		height = "100%",
		width = "100%",
	},
}

-- Enable Acrylic effect for better blending
config.win32_system_backdrop = "Acrylic"
config.window_background_opacity = 0.95

-- Font configuration
config.font = wezterm.font_with_fallback({
	"DroidSansM Nerd Font Propo",
	"Cambria Math",
	"STIX Two Math",
})
config.font_size = 12.0

-- Tab bar
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

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
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},
	-- Copy to clipboard
	{ key = "c", mods = "CTRL", action = act.CopyTo("ClipboardAndPrimarySelection") },
	-- Paste from clipboard
	{ key = "v", mods = "CTRL", action = act.PasteFrom("Clipboard") },
	-- Pane Navigation
	{ key = 'h', mods = 'CTRL', action = act.ActivatePaneDirection 'Left' },
	{ key = 'j', mods = 'CTRL', action = act.ActivatePaneDirection 'Down' },
	{ key = 'k', mods = 'CTRL', action = act.ActivatePaneDirection 'Up' },
	{ key = 'l', mods = 'CTRL', action = act.ActivatePaneDirection 'Right' },
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
