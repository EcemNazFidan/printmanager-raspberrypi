#!/bin/bash

LCD_SCRIPT="/home/pi/lcd_display.py"

lcd_message() {
    python3 "$LCD_SCRIPT" "$1" "$2"
}

lcd_message "Deactivating" "AirPrint"

# Stop sharing printers and AirPrint functionality (remove AirPrint Avahi services)
echo "Stopping AirPrint mode..."

# Disable printer sharing
cupsctl --no-share-printers

# Stop hotspot services
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq

# Set wlan0 to managed mode and bring it up
sudo iw dev wlan0 set type managed
sudo ip link set wlan0 up

# Start wpa_supplicant and NetworkManager to connect to Wi-Fi
sudo systemctl unmask wpa_supplicant
sudo systemctl start wpa_supplicant
sudo systemctl restart NetworkManager

lcd_message "Wi-Fi" "Reconnected"

# Optional: Stop Avahi if desired (usually kept running for Wi-Fi AirPrint)
#if systemctl is-active --quiet avahi-daemon; then
#    echo "Stopping Avahi service..."
#    sudo systemctl stop avahi-daemon
#fi

lcd_message "Deactivation" "Successful"
