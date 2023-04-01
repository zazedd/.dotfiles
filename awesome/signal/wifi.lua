-- emits wifi status (with nmcli)
-- well, it works for me. so yeah
---------------------------------
-- Copyleft © 2022 Saimoomedits

-- ("signal::wifi"), function(net_status(bool))

-- rquirements
local awful = require("awful")

-- interval (in seconds)
local update_interval = 6

-- import network info
local net_cmd = [[
  bash -c "
  nmcli -t -f WIFI g | cut -d ':' -f 4
  "
]]

awful.widget.watch(net_cmd, update_interval, function(_, stdout)
	local net_ssid = stdout
	local net_status = true

	-- update networks status
	if net_ssid == "disabled\n" then
		net_status = false
	end

	-- emit (true or false)
	awesome.emit_signal("signal::wifi", net_status)
end)
