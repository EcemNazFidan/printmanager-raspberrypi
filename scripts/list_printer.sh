#!/bin/bash

sleep 3
LCD_SCRIPT="/home/pi/lcd_display.py"

lcd_message() {
    python3 "$LCD_SCRIPT" "$1" "$2"
}

lcd_message "Script started" "$(date)"
sleep 2

# Wait for network to be ready
lcd_message "waiting" "to be ready"
sleep 2

# Check if CUPS is ready
if systemctl is-active --quiet cups; then
    lcd_message "Cups is" "active"
else
    lcd_message "Starting Cups" "service..."
    sudo systemctl start cups
fi
sleep 2

# Get the list of all printers in CUPS
USB_PRINTERS=$(lpstat -v | grep -i "usb" | awk '{print $3}' | sed 's/:$//')

if [ -z "$USB_PRINTERS" ]; then
    lcd_message "No printer" "found."
    sleep 2
else
    lcd_message "Printers:" "Listing..."
    sleep 2

    # Display all connected printers
    for printer in $USB_PRINTERS; do
        PRINTER_NAME=$(lpstat -l -p "$printer" | awk -F'Description: ' '/Description/ {print $2}' | xargs)
        lcd_message "Printer:" "$PRINTER_NAME"
        sleep 2
    done

    # Set the first printer as default
    FIRST_PRINTER=$(echo "$USB_PRINTERS" | head -n 1 | awk '{print $1}')
    sudo lpadmin -d "$FIRST_PRINTER"
fi

sleep 2
