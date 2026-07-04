-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.color_scheme = "Solarized Light (Gogh)"

config.hide_tab_bar_if_only_one_tab = true

local act = wezterm.action

config.keys = {
	-- 1. Rename the CURRENT workspace (give it a memorable name)
	{
		key = "$",
		mods = "CTRL|SHIFT",
		action = act.PromptInputLine({
			description = "Enter new name for workspace",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					wezterm.mux.rename_workspace(window:mux_window():get_workspace(), line)
				end
			end),
		}),
	},

	-- 2. Fuzzy switch by workspace name
	{
		key = "s",
		mods = "CTRL|SHIFT",
		action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
	},

	-- 3. Create a new named workspace on the spot
	{
		key = "n",
		mods = "CTRL|SHIFT",
		action = act.PromptInputLine({
			description = "Enter name for new workspace",
			action = wezterm.action_callback(function(_, _, line)
				if line and line ~= "" then
					wezterm.mux.spawn_window({ workspace = line })
					wezterm.mux.set_active_workspace(line)
				end
			end),
		}),
	},
}

-- Always show the tab bar, even with one tab
config.hide_tab_bar_if_only_one_tab = false
config.show_tab_index_in_tab_bar = true

-- Keep it at the top (default, but explicit doesn't hurt)
config.tab_bar_at_bottom = false

-- Show the bar even in fullscreen / native macOS fullscreen
config.show_tabs_in_tab_bar = true
config.enable_tab_bar = true

-- Optional: the "retro" bar is more compact and shows custom content better
-- than the fancy bar. Pick one.
config.use_fancy_tab_bar = false

-- Put the workspace name on the left side of the tab bar
wezterm.on("update-status", function(window, _)
	local workspace = window:active_workspace()
	window:set_left_status(wezterm.format({
		{ Foreground = { AnsiColor = "Fuchsia" } },
		{ Text = " 󱂬 " .. workspace .. " " },
	}))
end)

-- Optional: format each tab nicely with its index + title
wezterm.on("format-tab-title", function(tab)
	local title = tab.tab_title
	if not title or #title == 0 then
		title = tab.active_pane.title
	end
	return string.format(" %d: %s ", tab.tab_index + 1, title)
end)

-- to allow ctrl+\ inside pi
config.enable_kitty_keyboard = true
-- config.enable_csi_u_key_encoding = true

-- and finally, return the configuration to wezterm
return config
