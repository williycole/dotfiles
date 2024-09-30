local wezterm = require("wezterm")

local config = {}

-- Set the default domain to your WSL distribution
config.default_domain = "WSL:Ubuntu"

-- Optionally, configure the WSL domain explicitly
config.wsl_domains = {
	{
		name = "WSL:Ubuntu",
		distribution = "Ubuntu",
		default_cwd = "~",
	},
}

return config
