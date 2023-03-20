local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = require("beautiful").xresources.apply_dpi
local volume = require("themes.linear.modules.volume")
-- Window control
minimize = wibox.widget {
	image = beautiful.minimize,
	widget = wibox.widget.imagebox
}
minimize:connect_signal("button::press", function() 
	if client.focus then
		client.focus.minimized = true 
	end
end)

maximize = wibox.widget {
	image = beautiful.maximize,
	widget = wibox.widget.imagebox
}
maximize:connect_signal("button::press", function() 
	if client.focus then
		client.focus.maximized = not client.focus.maximized
	end
end)

close = wibox.widget {
	image = beautiful.close,
	widget = wibox.widget.imagebox
}
close:connect_signal("button::press", function() 
	if client.focus then
		client.focus:kill() 
	end
end)

-- Launcher
launcher = wibox.widget {
	buttons = {
		awful.button({}, 1, function()
			awesome.emit_signal('widget::launcher')
		end) 
	},
	image = beautiful.awesome_icon,
	widget = wibox.widget.imagebox
}

-- Systray
systray = wibox.widget {
	buttons = {
		awful.button({}, 1, function()
			awesome.emit_signal('widget::systray')
		end) 
	},
	image = beautiful.systray,
	widget = wibox.widget.imagebox
}

-- Clock
textclock = wibox.widget.textclock('%I:%M %p')

-- Tags
screen.connect_signal("request::desktop_decoration", function(s)
    -- Layout Widget
    s.layoutbox = awful.widget.layoutbox {
        screen  = s,
        buttons = {
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
        }
    }

	-- Taglist Widget
	s.taglist = awful.widget.taglist {
		screen = s,
		filter = awful.widget.taglist.filter.all,
    forced_width = dpi(240),
		buttons = {
			awful.button({ }, 1, function(t) t:view_only() end)
		}
	}

	-- Tasklist widget
  s.tasklist = awful.widget.tasklist {
    screen  = s,
    filter  = awful.widget.tasklist.filter.currenttags,
    widget_template = {
      {
        {
          id     = "text_role",
          forced_height = dpi(20),
          widget = wibox.widget.textbox,
        },
        position = "center",
        valign = "center",
        halign = "center",
        widget = wibox.container.place,
      },
      id     = "background_role",
      widget = wibox.container.background,
    },
    buttons = {
      awful.button({ }, 1, function (c)
        c:activate { context = "tasklist", action = "toggle_minimization" }
      end),
    }
  }

    -- Wibox
  s.wibox = awful.wibar {
    border_width = dpi(5),
    border_color = beautiful.tasklist_bg_focus,
    position = "bottom",
    height = dpi(35),
    bg = beautiful.tasklist_bg_focus,
    fg = beautiful.fg_focus,
    screen   = s,
    widget   = {
      layout = wibox.layout.align.horizontal,
      { -- Left
        layout = wibox.layout.fixed.horizontal,
        spacing = dpi(20),
        {
          launcher,
          top = dpi(8),
          bottom = dpi(8),
          left = dpi(8),
          widget = wibox.container.margin
        },
        {
          s.taglist,
          right = dpi(95),
          widget = wibox.container.margin
        }
      },
      -- Middle
      s.tasklist,
      { -- Right
        layout = wibox.layout.fixed.horizontal,
        spacing = dpi(23),
        volume,
        textclock,
        {
          systray,
          top = dpi(12),
          bottom = dpi(11),
          left = dpi(11),
          widget = wibox.container.margin
        },
        {
          s.layoutbox,
          right = dpi(7),
          top = dpi(7),
          bottom = dpi(7),
          widget = wibox.container.margin
        },
      },
    }
  }
end)
