#!/bin/bash

exec > >(tee -a /var/log/remove_usb_printer_debug.log) 2>&1
set -x

LCD_SCRIPT="/home/pi/lcd_display.py"

lcd_message() {
    python3 "$LCD_SCRIPT" "$1" "$2"
}

lcd_message "USB Printer" "removing started"

PRINTER_URI=$(lpinfo -v | grep -i "usb" | awk '{print $2}')
if [ -z "$PRINTER_URI" ]; then
    lcd_message "Printer" "disconnected"
else
    lcd_message "Printer still" "detected"
    exit 0
fi

# Remove from CUPS
ALL_PRINTERS=$(lpstat -p | awk '/printer/ {print $2}')
if [ -n "$ALL_PRINTERS" ]; then
    for PRINTER in $ALL_PRINTERS; do
        sudo lpadmin -x "$PRINTER"
        lcd_message "Printer removed:" "$PRINTER"
        sleep 3
    done
else
    lcd_message "No printer" "removed"
fi

lcd_message "Ports" "cleared."
