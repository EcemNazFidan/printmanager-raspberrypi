#!/bin/bash

sleep 9
exec > >(tee -a /var/log/add_usb_printer_debug.log) 2>&1
set -x

LCD_SCRIPT="/home/pi/lcd_display.py"

lcd_message() {
    python3 "$LCD_SCRIPT" "$1" "$2"
}

sleep 4
lcd_message "USB Printer Add" "Script started."
sleep 3

# Detect connected USB printer
PRINTER_URI=$(lpinfo -v | grep -i "usb" | awk '{print $2}')
if [ -z "$PRINTER_URI" ]; then
    lcd_message "No USB printer" "Connect a USB printer and try again."
    sleep 3
    exit 0
fi

lcd_message "Detected USB printer:" "$PRINTER_URI"

# Extract printer manufacturer and model from URI
PRINTER_MAKE=$(echo "$PRINTER_URI" | sed -E 's|usb://([^/]+).*/.*|\1|')
PRINTER_MODEL=$(echo "$PRINTER_URI" | sed -E 's|usb://.*/([^?]+).*|\1|' | sed 's/%20/ /g')

# Note: In some cases, the printer model and manufacturer extracted from the URI
# may differ from the official driver naming conventions (e.g., spacing, series names).
# Users are advised to verify and, if necessary, manually adjust the extracted names
# before assigning them to ensure correct driver mapping in CUPS.

# Map SCX-4x21 to SCX-4521F
if [[ "$PRINTER_MODEL" == *"SCX-4x21"* ]]; then
    PRINTER_MODEL="SCX-4521F"
fi

lcd_message "Printer Brand:" "$PRINTER_MAKE"
sleep 4
lcd_message "Printer Model:" "$PRINTER_MODEL"
sleep 3

# Check if the printer is already added in CUPS
EXISTING_PRINTER=$(lpstat -v | grep -i "$PRINTER_MAKE" | grep -i "$PRINTER_MODEL")
if [ -n "$EXISTING_PRINTER" ]; then
    lcd_message "Printer $PRINTER_MAKE $PRINTER_MODEL" "is already in CUPS. Exiting"
    exit 0
fi

lcd_message "Adding new" "printer to CUPS."
sleep 3

# The following line queries the CUPS driver list using model and manufacturer names.
# The system benefits from the extended compatibility provided by the Foomatic database,
# which was downloaded and utilized to support legacy printer models.
DRIVER=$(lpinfo -m | grep -i "$PRINTER_MAKE" | grep -i "$PRINTER_MODEL" | head -n 1 | awk '{print $1}')
if [ -z "$DRIVER" ]; then
    lcd_message "Driver not found" "Install manually."
    exit 1
fi

# Add the printer to CUPS with the selected driver and enable sharing
PRINTER_NAME="${PRINTER_MAKE}_${PRINTER_MODEL}"
sudo lpadmin -p "$PRINTER_NAME" -E -v "$PRINTER_URI" -m "$DRIVER"

# Set the printer as the default if it's successfully added
if lpstat -p | grep -q "^printer $PRINTER_NAME"; then
    sudo lpadmin -d "$PRINTER_NAME"
    lcd_message "Printer $PRINTER_NAME" "added and set as default."
else
    lcd_message "Failed to add printer" "Check CUPS or driver compatibility."
    exit 1
fi

lcd_message "Script complete" "Printer setup finished."
exit 0
