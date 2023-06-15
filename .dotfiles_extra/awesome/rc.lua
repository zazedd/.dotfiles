-- A random rice. i guess.
-- source: https://github.com/saimoomedits/dotfiles |-| Copyleft © 2022 Saimoomedits
------------------------------------------------------------------------------------

pcall(require, "luarocks.loader")
local naughty = require("naughty")

-- home variable 🏠
home_var = os.getenv("HOME")

-- require("awful").spawn.easy_async_with_shell(home_var .. "/.config/awesome/misc/scripts/monitor.sh") -- disable laptop monitor

-- user preferences ⚙️
user_likes = {

	-- aplications
	term = "alacritty",
	editor = "alacritty -e " .. "nvim",
	code = "neovide",
	web = "firefox",
	music = "alacritty --class 'music' --config-file " .. home_var .. "/.config/alacritty/ncmpcpp.yml -e ncmpcpp ",
	files = "nemo",

	-- your profile
	username = os.getenv("USER"),
	userdesc = "i fear no man",
}

-- theme 🖌️
require("theme")

-- configs ⚙️
require("config")

-- miscallenous ✨
require("misc")

-- signals 📶
require("signal")

-- ui elements 💻
require("layout")
