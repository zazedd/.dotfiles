local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Mouse 
awful.mouse.append_global_mousebindings({
	awful.button({ }, 1, function () rootmenu:hide() end),
    awful.button({ }, 3, function () rootmenu:toggle() end),
})

-- General keys
awful.keyboard.append_global_keybindings({

    awful.key(
		{ modkey }, "Return", function () awful.spawn.with_shell(terminal) end,
        { description = "open a terminal", group = "awesome" }
	),
	awful.key(
		{ modkey }, "s", function() hotkeys_popup.show_help() end,
		{ description = "show keybindings", group = "awesome" }
	),
	awful.key(
		{ modkey }, "0", function() awesome.emit_signal("widget::power") end,
		{ description = "show power menu", group = "awesome" }
	),
	awful.key(
		{ modkey, "Shift" }, "r", awesome.restart,
		{ description = "reload awesome", group = "awesome" }
	),
	awful.key(
		{ modkey }, "z", function () awful.layout.inc(1) end,
 		{ description = "next layout", group = "awesome" }
	),
    awful.key(
		{ modkey }, "r", function () awful.spawn.with_shell("rofi -show run") end,
        { description = "run prompt", group = "launcher" }
  ),
    awful.key(
		{ modkey }, "b", function () awful.spawn("firefox") end,
        { description = "run firefox", group = "launcher" }
	),
    awful.key(
		{ modkey }, "t", function () awful.util.spawn_with_shell("neovide") end,
        { description = "run neovide", group = "launcher" }
	),
	awful.key(
		{ modkey }, "d", function () require("themes/linear/menu").open() end,
        { description = "run prompt", group = "launcher" }
	),
    awful.key(
		{ modkey }, "e", function () awful.spawn.with_shell("~/.config/awesome/bin/kaomoji") end,
        { description = "kaomoji menu", group = "launcher" }
	),
    awful.key(
		{ modkey, "Shift" }, "d", function () awful.spawn.with_shell("~/.config/awesome/themes/colors/scripts/rofi.sh") end,
        { description = "desktop menu", group = "launcher" }
	),
	awful.key(
		{ modkey }, "Delete", function () awful.spawn.with_shell("~/.config/awesome/bin/screenshot full") end,
        { description = "full screen", group = "screenshot" }
	),
	awful.key(
		{ modkey, "Shift" }, "Delete", function () awful.spawn.with_shell("~/.config/awesome/bin/screenshot part") end,
        { description = "part screen", group = "screenshot" }
	),
    awful.key(
		{ modkey, }, "F1", function () 
			awful.spawn.with_shell("pactl set-sink-mute @DEFAULT_SINK@ toggle")
			awesome.emit_signal("widget::volume")
		end,
        { description = "mute volume", group = "volume" }
	),
	awful.key(
		{ modkey }, "F6", function () 
			awful.spawn.with_shell("light -A 5")
			awesome.emit_signal("widget::brightness")
		end,
        { description = "raise brightness", group = "brightness" }
	),
	awful.key(
		{ modkey }, "F5", function () 
			awful.spawn.with_shell("light -U 5")
			awesome.emit_signal("widget::brightness")
		end,
        { description = "lower brightness", group = "brightness" }
	),
})

awful.keyboard.append_global_keybindings({
    awful.key(
		{ alt }, "Tab", function () awful.client.focus.byidx(1) end,
        { description = "focus next by index", group = "client" }
    ),
  awful.key({ modkey,           }, "l",
    function ()
      awful.client.focus.byidx( 1)
    end,
    {description = "focus next by index", group = "client"}
  ),
  awful.key({ modkey,           }, "h",
    function ()
      awful.client.focus.byidx(-1)
    end,
    {description = "focus previous by index", group = "client"}
  ),
  awful.key({ alt,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
    {description = "increase window width factor", group = "layout"}),
  awful.key({ alt,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
    {description = "decrease window width factor", group = "layout"}),
  awful.key({ alt,           }, "j",     function () awful.client.incwfact(0.05)          end,
    {description = "increase window gap factor", group = "layout"}),
  awful.key({ alt,           }, "k",     function () awful.client.incwfact(-0.05)          end,
    {description = "decrease window gap factor", group = "layout"}),
  awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
    {description = "increase the number of master clients", group = "layout"}),
  awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
    {description = "decrease the number of master clients", group = "layout"}),
  awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
    {description = "increase the number of columns", group = "layout"}),
  awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
    {description = "decrease the number of columns", group = "layout"}),
  awful.key({ modkey, "Shift" }, "n",
    function ()
      local c = awful.client.restore()
      -- Focus restored client
      if c then
        c:emit_signal(
          "request::activate", "key.unminimize", {raise = true}
        )
      end
    end,
    {description = "restore minimized", group = "client"}),
  awful.key(
    { modkey, "Shift" }, "Tab", function () awful.client.focus.byidx(-1) end,
    { description = "focus previous by index", group = "client" }
  ),
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numrow",
        description = "only view tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
        end,
    },
    awful.key {
        modifiers = { modkey, "Shift" },
        keygroup    = "numrow",
        description = "move focused client to tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
					tag:view_only()
                end
            end
        end,
    }
})

client.connect_signal("request::default_mousebindings", function()
  awful.mouse.append_client_mousebindings({
    -- Focus
    awful.button({ }, 1, function (c)
      c:activate { context = "mouse_click" }
    end),
    -- Move
    awful.button({ modkey }, 1, function (c)
      c:activate { context = "mouse_click", action = "mouse_move"  }
    end),
    -- Resize
    awful.button({ modkey }, 3, function (c)
      c:activate { context = "mouse_click", action = "mouse_resize"}
    end),
  })
end)

client.connect_signal("request::default_keybindings", function()
  awful.keyboard.append_client_keybindings({
    awful.key(
      { modkey }, "f",
      function (c)
        c.fullscreen = not c.fullscreen
        c:raise()
      end,
      { description = "toggle fullscreen", group = "client" }
    ),
    awful.key({ modkey,           }, "n",
      function (c)
        -- The client currently has the input focus, so it cannot be
        -- minimized, since minimized clients can't have the focus.
        c.minimized = true
      end ,
      {description = "minimize", group = "client"}),
    awful.key(
      { modkey }, "f",
      function(c)
        c.floating = not c.floating
        c:raise()
      end,
      { description = "toggle floating", group = "client" }
    ),
    awful.key(
      { modkey }, "m",
      function(c)
        c.maximized = not c.maximized
        c:raise()
      end,
      { description = "toggle maximize", group = "client" }
    ),
    awful.key(
      { modkey }, "q", function (c) c:kill() end,
      { description = "close", group = "client" }
    ),
  })
end)
