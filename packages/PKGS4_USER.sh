#!/usr/bin/env bash

USERPKGS=(
    # SYSTEM --------------------------------------------------------------
    'virtualbox'
    'virtualbox-host-modules-arch'
    'qt5-x11extras'
    'qt5ct'
    'snapper'

    # TERMINAL UTILITIES --------------------------------------------------
    'bash-completion'       # Tab completion for Bash
    'bleachbit'             # File deletion utility
    'cronie'                # cron jobs
    'file-roller'           # Archive utility
    'gtop'                  # System monitoring via terminal
    'gufw'                  # Firewall manager
    'hardinfo'              # Hardware info app
    'htop'                  # Process viewer
    'neofetch'              # Shows system info when you launch terminal
    'ntp'                   # Network Time Protocol to set time via network.
    'numlockx'              # Turns on numlock in X11
    'openssh'               # SSH connectivity tools
    'p7zip'                 # 7z compression program
    'rsync'                 # Remote file sync utility
    'speedtest-cli'         # Internet speed via terminal
    'terminus-font'         # Font package with some bigger fonts for login terminal
    #'tlp'                   # Advanced laptop power management
    'unrar'                 # RAR compression program
    'unzip'                 # Zip compression program
    'terminator'            # Terminal emulator
    'vim'                   # Terminal Editor
    'zenity'                # Display graphical dialog boxes via shell scripts
    'zip'                   # Zip compression program
    'zsh'                   # ZSH shell
    'zsh-completions'       # Tab completion for ZSH

    # DISK UTILITIES ------------------------------------------------------
    'android-tools'         # ADB for Android
    'android-file-transfer' # Android File Transfer
    'autofs'                # Auto-mounter
    'dosfstools'            # DOS Support
    'exfat-utils'           # Mount exFat drives
    'gparted'               # Disk utility
    'parted'                # Disk utility
    'gvfs-mtp'              # Read MTP Connected Systems
    'gvfs-smb'              # More File System Stuff
    'nautilus'              # Filesystem browser
    'nautilus-share'        # File Sharing in Nautilus
    'ntfs-3g'               # Open source implementation of NTFS file system
    'samba'                 # Samba File Sharing
    'smartmontools'         # Disk Monitoring
    'smbclient'             # SMB Connection 
    'xfsprogs'              # XFS Support

    # GENERAL UTILITIES ---------------------------------------------------
    'flameshot'             # Screenshots
    'freerdp'               # RDP Connections
    'libvncserver'          # VNC Connections
    'remmina'               # Remote Connection
    'veracrypt'             # Disc encryption utility
    'variety'               # Wallpaper changer
    'ttf-fira-code'
    'qbittorrent'

    # DEVELOPMENT ---------------------------------------------------------
    'gedit'                 # Text editor
    'meld'                  # File/directory comparison
    'nodejs'                # Javascript runtime environment
    'npm'                   # Node package manager
    'python'                # Scripting language
    'yarn'                  # Dependency management (Hyper needs this)

    # MEDIA ---------------------------------------------------------------
    'celluloid'             # Video player
    'vlc'                   # Video player

    # GRAPHICS AND DESIGN -------------------------------------------------
    'gcolor2'               # Colorpicker
    'gimp'                 
    'ristretto'             # Multi image viewer

    # PRODUCTIVITY --------------------------------------------------------
    'hunspell'              # Spellcheck libraries
    'hunspell-en_US'           # English spellcheck library
    'xpdf'                  # PDF viewer
)
