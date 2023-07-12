# Change this according to your device
################
# Variables
################

# Keyboard input name
keyboard_input_name="1:1:AT_Translated_Set_2_keyboard"

# Date and time
date_and_week=$(date "+%Y/%m/%d (w%-V)")
current_time=$(date "+%H:%M")

#############
# Commands
#############

# Battery or charger
battery0_charge=$(upower --show-info /org/freedesktop/UPower/devices/battery_BAT0 | egrep "percentage" | awk '{print $2}')
battery1_charge=$(upower --show-info /org/freedesktop/UPower/devices/battery_BAT1 | egrep "percentage" | awk '{print $2}')
battery0_status=$(upower --show-info /org/freedesktop/UPower/devices/battery_BAT0 | egrep "state" | awk '{print $2}')
battery1_status=$(upower --show-info /org/freedesktop/UPower/devices/battery_BAT1 | egrep "state" | awk '{print $2}')

# Audio and multimedia
#audio_is_muted=$(pamixer --sink `pactl list sinks short | grep RUNNING | awk '{print $1}'` --get-mute)
audio_volume=$(amixer sget Master | tail -n 1 | grep -iE '[0-9][0-9]%|[0-9]%' | awk -F '[][]' '{print $2}')

# Network
network=$(ip route get 1.1.1.1 | grep -Po '(?<=dev\s)\w+' | cut -f1 -d ' ')
# interface_easyname grabs the "old" interface name before systemd renamed it
interface_easyname=$(nmcli device | grep -w 'connected' | grep -vE 'lo|disconnected' | awk '{print $1}')
ping=$(ping -c 1 www.google.es | tail -1| awk '{print $4}' | cut -d '/' -f 2 | cut -d '.' -f 1)

# Removed weather because we are requesting it too many times to have a proper
# refresh on the bar
#weather=$(curl -Ss 'https://wttr.in/Pontevedra?0&T&Q&format=1')

if [ $battery0_status = "discharging" ];
then
    battery0_pluggedin='󱟥'
elif [ $battery0_status = "pending-charge" ];
then
    battery0_pluggedin='󱧥'
elif [ $battery0_status = "fully-charged" ];
then
    battery0_pluggedin='󰁹'
else
    battery0_pluggedin='󰢟'
fi

if [ $battery1_status = "discharging" ];
then
    battery1_pluggedin='󱟥'
elif [ $battery1_status = "pending-charge" ];
then
    battery1_pluggedin='󱧥'
elif [ $battery1_status = "fully-charged" ];
then
    battery1_pluggedin='󰁹'
else
    battery1_pluggedin='󰢟'
fi

if ! [ $network ]
then
   network_active="⛔"
else
   network_active="⇆"
fi

# if [ $audio_is_muted = "true" ]
# then
#     audio_active='🔇'
# else
    audio_active=''
# fi

echo "$network_active $interface_easyname ($ping ms) | $audio_volume  $audio_active  | BAT0 - $battery0_charge  $battery0_pluggedin  | BAT1 - $battery1_charge  $battery1_pluggedin  | $date_and_week  󰥔  $current_time "
