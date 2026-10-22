-- Kanagawa, pinned on every OS.
--
-- This used to defer to an external theme switcher when its symlink existed.
-- That is gone, and the coordinated-theme-everywhere idea went with it.
return {
	{
		"rebelot/kanagawa.nvim",
		opts = {
			overrides = function(colors)
				return {
					-- kanagawa themes dashboard-nvim's groups but not snacks' dashboard.
					-- Link snacks' groups to kanagawa's so the splash keeps its colors.
					SnacksDashboardHeader = { link = "DashboardHeader" },
					SnacksDashboardDesc = { link = "DashboardDesc" },
					SnacksDashboardIcon = { link = "DashboardIcon" },
					SnacksDashboardKey = { link = "DashboardKey" },
					SnacksDashboardFooter = { link = "DashboardFooter" },
					-- lualine forces laststatus=3 after snacks sets it to 0, so the
					-- dashboard shows an empty statusline row. Lualine paints its own
					-- theme groups, so StatusLine's bg only shows there; make it Normal.
					StatusLine = { bg = colors.theme.ui.bg },
				}
			end,
		},
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "kanagawa",
		},
	},
}
