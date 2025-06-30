# printmanager-raspberrypi
**Project**: EE491 Bachelor's Thesis  **University**: İzmir Institute of Technology (IYTE)
# 🖨️ PrintManager: Automated Configuration and Wireless Sharing for USB Printers

**Author:** Ecem Naz Fidan  
**Supervisor:** Prof. Dr. Bilge Karaçalı  
**Project Type:** EE491 Undergraduate Thesis  
**Institution:** İzmir Institute of Technology (İYTE)  
**Date:** February 2025

---

## 📌 Introduction

The rapid advancement of networked environments has made **Wi-Fi connectivity a standard requirement** for modern printers. However, a vast number of older yet fully functional **USB-connected printers** remain in use today — and most of them lack native wireless support or modern driver compatibility. As a result, many such devices are prematurely discarded, not because they are broken, but because they are **incompatible with today’s wireless workflows**.

This mismatch between legacy hardware and current network demands leads to an increasing volume of **electronic waste (e-waste)**, as users are often forced to replace reliable devices simply to gain network printing capability.

**PrintManager** was designed to directly address this issue. Built on a **Raspberry Pi**, the system provides a compact, low-cost, and sustainable platform that:
- Automatically detects and configures USB printers,
- Matches drivers using open-source databases (e.g., Foomatic),
- Shares printers wirelessly over the network using **AirPrint** and **mDNS discovery**.

By combining open-source software with modular automation scripts, PrintManager revives and reuses legacy hardware in a modern context. The project not only improves **accessibility and user convenience** but also promotes **environmental responsibility** by extending the lifespan of existing devices.

This plug-and-play solution is especially valuable in home, academic, and small office environments where cost, ease of use, and sustainability are key priorities.

---

## 🎯 Problem Definition

### Key Issues:

- ❌ **Limited Connectivity**: Older USB printers cannot connect to wireless networks.
- ⚙️ **Complex Manual Configuration**: Traditional methods require manual driver installation, URI parsing, and system integration.
- 💸 **Cost and E-Waste**: Replacing functional printers for modern alternatives leads to high expenses and environmental harm.

### Problem Statement

This project automates the integration of legacy printers into modern network systems. A Raspberry Pi serves as the central controller, detecting connected USB printers, resolving their manufacturer and model info, and configuring them automatically on the CUPS server.

It also establishes a local hotspot and enables **AirPrint support** via Avahi, allowing wireless printing from smartphones and tablets.

---

## 🧠 Proposed Solution

PrintManager offers a **two-part automation system**:

1. **Automatic USB Printer Configuration**
   - Detects printer connection
   - Extracts model/manufacturer info from URI
   - Matches against known CUPS drivers (Foomatic-supported)
   - Adds to system and sets as default printer

2. **Wireless Printing with AirPrint**
   - Sets up a Wi-Fi access point on Raspberry Pi
   - Broadcasts printer via mDNS (Avahi)
   - Enables wireless discovery from modern devices

---

## 🧱 System Architecture

### 🔌 Hardware Components
- **Raspberry Pi** – Main controller
- **LCD Display** – Displays system status and printer messages
- **USB Ports** – Accepts printer input
- **Button** – Enables/disables AirPrint mode

### 🧰 Software Stack
- **CUPS** – Handles printer setup and management
- **Avahi-daemon** – Enables wireless discovery via mDNS
- **udev** – Detects USB plug-in/plug-out events
- **systemd** – Controls AirPrint activation services
- **cron** – Initializes the system on boot
- **Custom Bash/Python Scripts** – Implement automation logic

---

## ⚙️ How It Works

### 1. Printer Detection
- On boot, `list_printer.sh` lists registered printers via cron.
- Displays printer name or informs user if none found.

### 2. Driver Matching
- `add_usb_printer.sh` is triggered by `udev` when a printer is connected.
- Extracts manufacturer/model from URI.
- Matches against driver database (`lpinfo -m`).
- Includes **Foomatic** and open-source driver support.
- Warns user if no compatible driver is found.

### 3. Printer Integration
- Successfully matched printers are added to CUPS using `lpadmin`.
- Sets the added printer as default.
- Status is shown on the LCD.

### 4. USB Removal
- `remove_usb_printer.sh` removes printers from CUPS on unplug.
- Prevents duplicate or outdated entries.

### 5. AirPrint Mode Activation
- Button press triggers `airprint_mode.py`.
- `activate_airprint.sh` stops client Wi-Fi, starts hotspot with `hostapd`/`dnsmasq`.
- Avahi announces printers for Apple/Bonjour compatibility.

### 6. AirPrint Mode Deactivation
- Button press again triggers `deactivate_airprint.sh`.
- Reverts to regular Wi-Fi and disables hotspot mode.
- Avahi can continue running to allow discovery on home networks.

---

## 📂 Scripts Overview

| Script Name             | Function                                                                 |
|------------------------|--------------------------------------------------------------------------|
| `list_printer.sh`       | Lists all printers in CUPS at boot and sends info to LCD                 |
| `add_usb_printer.sh`    | Auto-detects and adds USB printers with CUPS + driver assignment         |
| `remove_usb_printer.sh` | Removes printer from CUPS on disconnection                               |
| `airprint_mode.py`      | Toggles wireless mode via button (activates/deactivates AirPrint)        |
| `activate_airprint.sh`  | Sets up Wi-Fi AP and AirPrint services                                   |
| `deactivate_airprint.sh`| Reverts to normal Wi-Fi and deactivates AirPrint                         |

---

## 🧪 Results and Testing

- ✅ Automatically recognized and configured 3 different printer models
- ✅ Enabled zero-configuration printing from smartphones
- ✅ Displayed meaningful status updates to user via LCD
- ✅ Verified hot-plug support and stable Wi-Fi reconfiguration
- ✅ Demonstrated end-to-end wireless printing without manual effort

### Screenshots (see `images/` folder):
- Printer added successfully
- AirPrint activated/deactivated
- LCD showing detection, progress, and errors

---

## 📏 Standards and Design Constraints

- **CUPS (IPP)** – Cross-platform print compatibility (RFC 8011)
- **Avahi (mDNS)** – Multicast DNS support for device discovery
- **IEEE 802.11** – Wireless network compliance for AP mode
- **USB 2.0/3.0** – Legacy printer communication
- **POSIX** – Script and system service compatibility

### Design Constraints:
- Limited RAM and USB ports on Raspberry Pi
- Dependency on driver availability for older models
- URI mismatches due to inconsistent device strings
- Sustainability considerations to avoid hardware waste

---

## ⚠️ Known Limitations

- Some legacy models require manual driver installation
- URI parsing can mislabel printer names (resolved partially)
- Only one printer can be handled at a time (due to USB port limits)

---

## 🔗 References

1. IOGEAR. Universal Ethernet to Wi-Fi Adapter – GWU637  
2. EasyTopTen. Best Wireless Printer Adapters  
3. Google. Google Cloud Print (Deprecated)  
4. [CUPS Documentation](https://www.cups.org/documentation.html)  
5. [Avahi Project](https://www.avahi.org/)  
6. S. K. Sood & S. K. Gupta, *"Turning Wired Printers Wireless with Raspberry Pi"*  
7. M. Conti et al., *"Amazon Echo Dot or the Reverberating Secrets of IoT Devices"*  
8. [RFC 8011 – IPP Protocol](https://www.ietf.org/rfc/rfc8011.txt)  
9. [Apple Bonjour Protocol](https://developer.apple.com/bonjour/)  
10. [IEEE 802.11](https://standards.ieee.org/)  
11. [USB.org Specification 2.0](https://www.usb.org/documents)  
12. [IEEE POSIX 1003.1](https://standards.ieee.org/)

---

---

## 📄 License

This project is **not licensed for public use**.  
All content is © 2025 Ecem Naz Fidan.  
**Unauthorized use, copying, or distribution is prohibited.**  
For academic citation or usage requests, please contact the author directly.


## 🙋‍♀️ Contact

For academic use, improvements, or collaborations:  
**Ecem Naz Fidan** – [LinkedIn](www.linkedin.com/in/ecem-naz-fidan) | [GitHub](https://github.com/EcemNazFidan) | [Email](ecemnazfidan2002@gmail.com) 
                   – www.linkedin.com/in/ecem-naz-fidan             | https://github.com/EcemNazFidan           | ecemnazfidan2002@gmail.com
