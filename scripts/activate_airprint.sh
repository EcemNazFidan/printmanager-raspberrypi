#!/bin/bash

LCD_SCRIPT="/home/pi/lcd_display.py"

lcd_message() {
    python3 "$LCD_SCRIPT" "$1" "$2"
}

lcd_message "AirPrint Mode" "Activating..."

# Stop wpa_supplicant to prepare for hotspot mode
sudo systemctl stop NetworkManager
sudo systemctl mask wpa_supplicant
sudo systemctl stop wpa_supplicant || { echo "Failed to stop wpa_supplicant"; exit 1; }

# Assign static IP to wlan0 for hotspot
sudo ifconfig wlan0 10.0.0.1 netmask 255.255.255.0
sudo ip link set wlan0 up

# Restart network stack
sudo systemctl restart networking || { echo "Failed to restart networking"; exit 1; }

# Restart hotspot services
sudo systemctl restart dnsmasq || { echo "Failed to restart dnsmasq"; exit 1; }
sudo systemctl restart hostapd || { echo "Failed to restart hostapd"; exit 1; }

# Enable printer sharing and AirPrint
cupsctl --share-printers
cupsctl WebInterface=yes

# Restart Avahi to apply changes and announce the printers
lcd_message "Restarting Avahi" "service to apply changes..."
sudo systemctl restart avahi-daemon

lcd_message "AirPrint Mode" "Activated"
