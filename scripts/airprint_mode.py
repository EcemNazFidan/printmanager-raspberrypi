from gpiozero import Button
import os
from time import sleep, time
import sys

button = Button(17)

AIRPRINT_ACTIVATE_SCRIPT = "/home/pi/activate_airprint.sh"
AIRPRINT_DEACTIVATE_SCRIPT = "/home/pi/deactivate_airprint.sh"

last_press_time = 0
deactivate_flag = False

def activate_airprint():
    """Run the bash script to activate AirPrint mode."""
    os.system(f"bash {AIRPRINT_ACTIVATE_SCRIPT}")

def deactivate_airprint():
    os.system(f"bash {AIRPRINT_DEACTIVATE_SCRIPT}")

def restart_listprinter():
    os.system("bash LIST_PRINTER_SCRIPT")  # Replace LIST_PRINTER_SCRIPT with actual path if needed

print("Waiting for button press to activate AirPrint mode...")

while True:
    if button.is_pressed:
        current_time = time()
        if current_time - last_press_time > 1:

            if not deactivate_flag:
                print("Activating AirPrint mode...")
                activate_airprint()
                deactivate_flag = True
                print("AirPrint mode activated.")
            else:
                print("Deactivating AirPrint mode...")
                deactivate_airprint()
                deactivate_flag = False
                print("AirPrint mode deactivated.")

            last_press_time = current_time

        sleep(1)
    else:
        sleep(0.05)
