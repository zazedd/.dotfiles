# Disable screen saver and power management
xset s off
xset -dpms
echo "screensaver is off"

# Launch VLC
/usr/bin/vlc "$@"

# Re-enable screen saver and power management
xset s on
xset +dpms
echo "screensaver is on"
