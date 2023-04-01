-- hdd indicator
--------------
-- Copyleft © 2022 Saimoomedits

-- requirements
---------------
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")
local wibox = require("wibox")
local gears = require("gears")

-- widgets
----------

-- percentage text
local perc = wibox.widget({
	widget = wibox.widget.textbox,
	markup = helpers.colorize_text("50%", beautiful.fg_color),
	font = beautiful.font_var .. "12",
	align = "left",
	valign = "bottom",
})

-- progress"bar" - again, more like arc
local progressbar = wibox.widget({
	widget = wibox.container.arcchart,
	max_value = 100,
	min_value = 0,
	value = 50,
	thickness = dpi(4),
	rounded_edge = true,
	bg = beautiful.red_color .. "26",
	colors = { beautiful.red_color },
	start_angle = math.pi + math.pi / 2,
	forced_width = dpi(32),
	forced_height = dpi(32),
})

awful.widget.watch([[bash -c "df -h /home|grep '^/' | awk '{print $5}'"]], 180, function(_, stdout)
	local val = stdout:match("(%d+)")
	perc.markup = helpers.colorize_text(val .. "%", beautiful.text)
	progressbar.value = tonumber(val)
	collectgarbage("collect")
end)

-- finalize
-----------
return wibox.widget({
	{
		{
			{
				{
					widget = wibox.widget.textbox,
					markup = helpers.colorize_text("Disk", beautiful.text .. "4D"),
					font = beautiful.font_var .. "11",
					align = "left",
					valign = "bottom",
				},
				nil,
				{
					perc,
					spacing = dpi(2),
					layout = wibox.layout.fixed.vertical,
				},
				layout = wibox.layout.align.vertical,
				expand = "none",
			},
			nil,
			progressbar,
			layout = wibox.layout.align.horizontal,
			expand = "none",
		},
		margins = dpi(14),
		widget = wibox.container.margin,
	},
	widget = wibox.container.background,
	bg = beautiful.bg_2 .. "B7",
	shape = helpers.rrect(beautiful.rounded),
	forced_height = dpi(70),
	forced_width = dpi(160),
})
-- eof
------
