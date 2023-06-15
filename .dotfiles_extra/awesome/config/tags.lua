-- tags  / layouts
------------------
-- Copyleft © 2022 Saimoomedits

-- requirements
-- ~~~~~~~~~~~~
local awful = require("awful")
local lmachi = require("mods.layout-machi")
local bling = require("mods.bling")

-- misc/vars
-- ~~~~~~~~~

-- bling layouts
local mstab = bling.layout.mstab
local equal = bling.layout.equalarea
local deck = bling.layout.deck

-- layout machi
lmachi.editor.nested_layouts = {
	["0"] = deck,
	["1"] = awful.layout.suit.spiral,
	["2"] = awful.layout.suit.fair,
	["3"] = awful.layout.suit.fair.horizontal,
	["4"] = awful.layout.suit.tile,
	["5"] = awful.layout.floating,
}

awful.layout.layouts = {
	deck,
	awful.layout.suit.spiral,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	awful.layout.suit.tile,
	awful.layout.suit.floating,
}

-- names/numbers of layouts
local names = { "1", "2", "3", "4", "5", "6" }
local l = awful.layout.suit

-- Configurations
-- **************

-- default tags
tag.connect_signal("request::default_layouts", function()
	awful.layout.append_default_layouts({
		l.tile,
		l.floating,
	})
end)

-- set tags
screen.connect_signal("request::desktop_decoration", function(s)
	screen[s].padding = { left = 0, right = 0, top = 0, bottom = 0 }
	awful.tag(names, s, awful.layout.layouts[5])
end)
