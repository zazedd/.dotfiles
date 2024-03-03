-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Fullscreen on startup
wezterm.on("gui-startup", function()
	local _, _, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

-- General configurations
config.window_decorations = "RESIZE"
config.tab_bar_at_bottom = true
config.font_size = 14.6
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }
config.color_scheme = "GruvboxDarkHard"
config.colors = {
	background = "black",
}
config.font = wezterm.font_with_fallback({
	"Iosevka Nerd Font",
	{ family = "Symbols Nerd Font Mono", scale = 0.73 },
})
config.window_background_opacity = 0.85
config.macos_window_background_blur = 10
config.window_close_confirmation = "AlwaysPrompt"
config.scrollback_lines = 3000
config.default_workspace = "home"

config.inactive_pane_hsb = {
	saturation = 0.24,
	brightness = 0.5,
}

config.window_padding = {
	left = 10,
	right = 0,
	top = 0,
	bottom = 0,
}

-- Keybinds
config.keys = {
	{ key = "|", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

	{ key = "n", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
	{ key = "o", mods = "LEADER", action = act.RotatePanes("Clockwise") },

	{ key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },

	{ key = "q", mods = "LEADER", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
}
for i = 1, 8 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = act.ActivateTab(i - 1),
	})
end

-- tab bar
config.use_fancy_tab_bar = false
config.status_update_interval = 1000

config.window_frame = {
	font = wezterm.font_with_fallback({
		"Iosevka Nerd Font",
		weight = "Bold",
		{ family = "Symbols Nerd Font Mono", scale = 0.5 },
	}),
	font_size = 10.0,
	active_titlebar_bg = "#333333",
	inactive_titlebar_bg = "#333333",
}

local basename = function(s)
	-- Nothing a little regex can't fix
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

wezterm.on("update-right-status", function(window, pane)
	-- workspace name
	local ws = window:active_workspace()
	if window:active_key_table() then
		ws = window:active_key_table()
	end
	if window:leader_is_active() then
		ws = "LDR"
	end

	-- cwd
	local cwd = basename(pane:get_current_working_dir().file_path)
	local cmd = basename(pane:get_foreground_process_name())

	local time = wezterm.strftime("%H:%M")
	window:set_right_status(wezterm.format({
		{ Foreground = { Color = "2BB8BD" } },
		{ Text = wezterm.nerdfonts.oct_table .. " " .. ws },
		"ResetAttributes",
		{ Foreground = { Color = "040404" } },
		{ Text = " 󰅁 " },
		{ Foreground = { Color = "2AA7BD" } },
		{ Text = wezterm.nerdfonts.md_folder .. " " .. cwd },
		"ResetAttributes",
		{ Foreground = { Color = "040404" } },
		{ Text = " 󰅁 " },
		{ Foreground = { Color = "2A91BD" } },
		{ Text = wezterm.nerdfonts.fa_code .. " " .. cmd },
		"ResetAttributes",
		{ Foreground = { Color = "040404" } },
		{ Text = " 󰅁 " },
		{ Foreground = { Color = "257EC2" } },
		{ Text = time },
		"ResetAttributes",
		{ Text = " " },
	}))
end)

-- individual tabs

local tab_title = function(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return basename(tab_info.active_pane.title)
end

local tab_num = function(tab_info)
	local num = tab_info.tab_index
	return tostring(num + 1)
end

wezterm.on("format-tab-title", function(t, tabs, panes, cfg, hover, max_width)
	local number = tab_num(t)
	local title = tab_title(t)

	-- ensure that the titles fit in the available space,
	-- and that we have room for the edges.
	title = wezterm.truncate_right(title, max_width)

	return {
		{ Text = " " .. number },
		{ Text = " -> " },
		{ Text = title },
		{ Text = " " },
	}
end)

return config
