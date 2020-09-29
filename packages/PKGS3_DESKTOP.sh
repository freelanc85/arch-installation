#!/usr/bin/env bash

DESKTOPPKGS=(
    # --- XORG Display Rendering
    'xorg'                  # Base Package
    'xorg-drivers'          # Display Drivers 
    'xterm'                 # Terminal for TTY
    'xorg-server'           # XOrg server
    'xorg-apps'             # XOrg apps group
    'xorg-xinit'            # XOrg init
    'xorg-xinput'           # Xorg xinput
    'mesa'                  # Open source version of OpenGL

    # --- Setup Desktop
    'awesome'               # Awesome Desktop
    'xfce4-power-manager'   # Power Manager 
    'rofi'                  # Menu System
    'picom'                 # Translucent Windows
    'xclip'                 # System Clipboard
    'polkit-gnome'          # Elevate Applications
    'gnome-keyring'         # Elevate Applications
    'lxappearance'          # Set System Themes

    # --- Login Display Manager
    'lightdm'                   # Base Login Manager
    'lightdm-gtk-greeter'
    'lightdm-gtk-greeter-settings'

    # --- Networking Setup
    'wpa_supplicant'            # Key negotiation for WPA wireless networks
    'openvpn'                   # Open VPN support
    'networkmanager-openvpn'    # Open VPN plugin for NM
    'libsecret'                 # Library for storing passwords

    # --- Audio
    'alsa-utils'        # Advanced Linux Sound Architecture (ALSA) Components https://alsa.opensrc.org/
    'alsa-plugins'      # ALSA plugins
    'pulseaudio'        # Pulse Audio sound components
    'pulseaudio-alsa'   # ALSA configuration for pulse audio
    'pavucontrol'       # Pulse Audio volume control

    # --- Bluetooth
    'bluez'                 # Daemons for the bluetooth protocol stack
    'bluez-utils'           # Bluetooth development and debugging utilities
    'blueberry'             # Bluetooth configuration tool
    'pulseaudio-bluetooth'  # Bluetooth support for PulseAudio

    # --- Printers
    'cups'                  # Open source printer drivers
    'cups-pdf'              # PDF support for cups
    'ghostscript'           # PostScript interpreter
    'gsfonts'               # Adobe Postscript replacement fonts
    'hplip'                 # HP Drivers
    'system-config-printer' # Printer setup  utility

    # CUSTOM --------------------------------------------------------------
    'gtk-engine-murrine'
    'gtk-engines'
    'ttf-roboto'
    'noto-fonts-emoji'
    'qbittorrent'
    #'gnome-shell'
    'sassc'
    'dbeaver'
    'exa'
    'docker'
    'docker-compose'
    'gnome-themes-extra'
)
