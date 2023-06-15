-- i know this is the worst thing ever.
-- but i couldn't think of any other way for now :skull:
-- it should work... right...?
--------------------------------------------------------
-- Copyleft © 2022 Saimoomedits

local awful = require("awful")

local volume_muted = false

function update_value_of_volume_mute()
	awful.spawn.easy_async_with_shell(
		"amixer -D pipewire get Master | tail -n 1 | awk '{print $6}' | tr -d '[%]'",
		function(stdout)
			if stdout == "on\n" then
				volume_muted = false
				require("layout.ding.extra.short")("󰕾", "Volume unmuted")
			elseif stdout == "off\n" then
				volume_muted = true
				require("layout.ding.extra.short")("󰸈", "Volume muted")
			end
			awesome.emit_signal("volume::muted", volume_muted)
		end
	)
end

function update_value_of_volume()
	awful.spawn.easy_async_with_shell(
		"amixer -D pipewire get Master | tail -n 1 | awk '{print $5}' | tr -d '[%]\n'",
		function(stdout)
			local value = tonumber(stdout)
			awesome.emit_signal("volume::value", value)
		end
	)
end

update_value_of_volume()
update_value_of_volume_mute()

function updateAllVolumeSignals()
	update_value_of_volume()
	update_value_of_volume_mute()
end
