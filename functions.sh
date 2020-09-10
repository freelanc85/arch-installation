#!/usr/bin/env bash

# Run logged as root
function preInstallSetup {
    # set keyboard
    loadkeys $KEYBOARD

    # enable ntp
    timedatectl set-ntp true

    echo "-------------------------------------------------"
    echo "Setting up mirrors for optimal download \n"
    echo "-------------------------------------------------"
    reflector --latest 25 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    pacman -Syy

    # disk prep
    cfdisk $DISK

    # make filesystems
    echo "\nCreating Filesystems...\n"
    mkfs.ext4 -L "BOOT" "${DISK}1"
    mkfs.btrfs -f -L "ROOT" "${DISK}2"

    # mount target
    mount "${DISK}2" /mnt
    btrfs su cr /mnt/@
    btrfs su cr /mnt/@home
    btrfs su cr /mnt/@var
    btrfs su cr /mnt/@srv
    btrfs su cr /mnt/@opt
    btrfs su cr /mnt/@tmp
    btrfs su cr /mnt/@swap
    btrfs su cr /mnt/@.snapshots
    umount /mnt
    mount -o noatime,compress=lzo,space_cache,subvol=@ "${DISK}2" /mnt
    mkdir /mnt/{boot,home,var,srv,opt,tmp,swap,.snapshots}
    mount -o noatime,compress=lzo,space_cache,subvol=@home "${DISK}2" /mnt/home
    mount -o noatime,compress=lzo,space_cache,subvol=@srv "${DISK}2" /mnt/srv
    mount -o noatime,compress=lzo,space_cache,subvol=@tmp "${DISK}2" /mnt/tmp
    mount -o noatime,compress=lzo,space_cache,subvol=@opt "${DISK}2" /mnt/opt
    mount -o noatime,compress=lzo,space_cache,subvol=@.snapshots "${DISK}2" /mnt/.snapshots

    # swap
    mount -o nodatacow,subvol=@swap "${DISK}2" /mnt/swap
    mount -o nodatacow,subvol=@var "${DISK}2" /mnt/var
    mount "${DISK}1" /mnt/boot

    echo "--------------------------------------"
    echo "----- Arch Install on Main Drive -----"
    echo "--------------------------------------"
    pacstrap /mnt base base-devel linux linux-firmware --noconfirm --needed
    genfstab -U /mnt >> /mnt/etc/fstab
}

# Run logged as root
function preInstall {
    echo "--------------------------------------"
    echo "-- Swapfile  --"
    echo "--------------------------------------"
    truncate -s 0 /swap/swapfile
    chattr +C /swap/swapfile
    btrfs property set /swap/swapfile compression none
    dd if=/dev/zero of=/swap/swapfile bs=1G count=2 status=progress
    chmod 600 /swap/swapfile
    mkswap /swap/swapfile
    swapon /swap/swapfile
    echo '/swap/swapfile none swap defaults 0 0' >> /etc/fstab

    # enable multilib
    sed -i 's/^\(#\[multilib\]\)/\[multilib\]/' /etc/pacman.conf
    sed -i '/^\[multilib\]/{n;s/^#//}' /etc/pacman.conf
    pacman -Syy

    # Base pkgs
    pacman -S nano sudo amd-ucode btrfs-progs wget curl git grub grub-btrfs networkmanager dhclient --noconfirm --needed
    pacman -S network-manager-applet dialog os-prober mtools linux-headers reflector xdg-utils xdg-user-dirs --noconfirm --needed

    echo "--------------------------------------"
    echo "-- Bootloader Setup  --"
    echo "--------------------------------------"
    sed -i 's/MODULES=()/MODULES=(btrfs)/g' /etc/mkinitcpio.conf
    mkinitcpio -p linux
    grub-install --target=i386-pc ${DISK}
    grub-mkconfig -o /boot/grub/grub.cfg

    echo "--------------------------------------"
    echo "--          Network Setup           --"
    echo "--------------------------------------"
    systemctl enable --now NetworkManager

    echo "--------------------------------------"
    echo "--      Set Password for Root       --"
    echo "--------------------------------------"
    echo "Enter password for root user: "
    passwd root

    echo "--------------------------------------"
    echo "--   Set Password for Normal User   --"
    echo "--------------------------------------"
    echo "Enter password for normal user: "
    useradd -mG audio,video,wheel,storage,network,rfkill -s /bin/bash $USER
    passwd $USER

    umount -R /mnt

    echo "--------------------------------------"
    echo "--   SYSTEM READY FOR FIRST REBOOT    --"
    echo "Don’t forget to take out the live USB before powering on the system again."
    echo "--------------------------------------"
    exit
}

# Log in as root
function installSetup {
    echo "-------------------------------------------------"
    echo "       Setup Language to US and set locale       "
    echo "-------------------------------------------------"
    ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    hwclock --systohc
    sed -i "s/^#${LOCALE}/${LOCALE}/" /etc/locale.gen
    locale-gen
    echo LANG=$LANG >> /etc/locale.conf
    printf "KEYMAP=${KEYMAP}\nFONT=ter-v32b\n" > /etc/vconsole.conf

    systemctl enable systemd-timesyncd
    timedatectl --no-ask-password set-ntp 1
    localectl --no-ask-password set-locale LANG="${LANG}" LC_TIME="${LANG}"

    # Hostname
    hostnamectl --no-ask-password set-hostname $HOSTNAME
    printf "127.0.0.1 localhost\n::1 localhost\n127.0.0.1 ${HOSTNAME}.localdomain arch\n" > /etc/hosts

    echo "-------------------------------------------------"
    echo "Setting up mirrors for optimal download"
    echo "-------------------------------------------------"
    reflector --latest 25 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

    # Add sudo rights
    sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

    # Add sudo no password rights
    sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

}

# Run logged as normal user
function installBase {
    echo -e "\nInstalling Base System\n"

    PKGS=(

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
            'arandr'

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
            'pnmixer'           # System tray volume control

        # --- Bluetooth
            'bluez'                 # Daemons for the bluetooth protocol stack
            'bluez-utils'           # Bluetooth development and debugging utilities
            'bluez-firmware'        # Firmwares for Broadcom BCM203x and STLC2300 Bluetooth chips
            'blueberry'             # Bluetooth configuration tool
            'pulseaudio-bluetooth'  # Bluetooth support for PulseAudio
        
        # --- Printers
            'cups'                  # Open source printer drivers
            'cups-pdf'              # PDF support for cups
            'ghostscript'           # PostScript interpreter
            'gsfonts'               # Adobe Postscript replacement fonts
            'hplip'                 # HP Drivers
            'system-config-printer' # Printer setup  utility
    )

    for PKG in "${PKGS[@]}"; do
        echo "INSTALLING: ${PKG}"
        sudo pacman -S "$PKG" --noconfirm --needed
    done

    echo -e "\nDone!\n"
}

# Run logged as normal user
function installSoftware {
    echo -e "\nINSTALLING SOFTWARE\n"

    PKGS=(

        # SYSTEM --------------------------------------------------------------

        'linux-lts'             # Long term support kernel
        'virtualbox'
        'virtualbox-host-modules-arch'
        'qt5-x11extras'
        'qt5ct'

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
        'krita'                 
        'ristretto'             # Multi image viewer

        # PRODUCTIVITY --------------------------------------------------------

        'hunspell'              # Spellcheck libraries
        'hunspell-en'           # English spellcheck library
        'xpdf'                  # PDF viewer

    )

    for PKG in "${PKGS[@]}"; do
        echo "INSTALLING: ${PKG}"
        sudo pacman -S "$PKG" --noconfirm --needed
    done

    echo -e "\nDone!\n"
}

# Run logged as normal user
function installSoftwareAur {
    echo -e "\nINSTALLING AUR SOFTWARE\n"

    cd "${HOME}"

    echo "CLOING: YAY"
    git clone "https://aur.archlinux.org/yay.git"


    PKGS=(

        # UTILITIES -----------------------------------------------------------

        'i3lock-fancy'              # Screen locker
        'freeoffice'                # Office Alternative
        'corectrl'
        'pamac-aur-git'
        'visual-studio-code-bin'
        'virtualbox-ext-oracle'
        
        # MEDIA ---------------------------------------------------------------

        'screenkey'                 # Screencast your keypresses
        'lbry-app-bin'              # LBRY Linux Application

        # COMMUNICATIONS ------------------------------------------------------

        'firefox'

        # THEMES --------------------------------------------------------------

        'materia-gtk-theme'             # Desktop Theme
        'papirus-icon-theme'            # Desktop Icons
        'capitaine-cursors'             # Cursor Themes
        'qt5-styleplugins'
    )


    cd ${HOME}/yay
    makepkg -si

    for PKG in "${PKGS[@]}"; do
        yay -S --noconfirm $PKG
    done

    echo -e "\nDone!\n"
}

# Run logged as normal user
function finalSetup {
    echo -e "\nFINAL SETUP AND CONFIGURATION"
    echo -e "\nDisabling buggy cursor inheritance"

    # When you boot with multiple monitors the cursor can look huge. This fixes it.
    echo '[Icon Theme]' | sudo tee /usr/share/icons/default/index.theme
    echo '#Inherits=Theme' | sudo tee -a /usr/share/icons/default/index.theme

    # ------------------------------------------------------------------------

    echo -e "\nIncreasing file watcher count"

    # This prevents a "too many files" error in Visual Studio Code
    echo fs.inotify.max_user_watches=524288 | sudo tee /etc/sysctl.d/40-max-user-watches.conf && sudo sysctl --system

    # ------------------------------------------------------------------------

    echo -e "\nDisabling Pulse .esd_auth module"

    # Pulse audio loads the `esound-protocol` module, which best I can tell is rarely needed.
    # That module creates a file called `.esd_auth` in the home directory which I'd prefer to not be there. So...
    sudo sed -i 's|load-module module-esound-protocol-unix|#load-module module-esound-protocol-unix|g' /etc/pulse/default.pa

    # ------------------------------------------------------------------------

    echo -e "\nEnabling Login Display Manager"

    sudo systemctl enable lightdm.service

    # ------------------------------------------------------------------------
    echo -e "\nEnabling bluetooth daemon and setting it to auto-start"
    sudo sed -i 's|#AutoEnable=false|AutoEnable=true|g' /etc/bluetooth/main.conf
    sudo systemctl enable --now bluetooth.service
    # ------------------------------------------------------------------------

    echo -e "\nEnabling the cups service daemon so we can print"

    systemctl enable --now org.cups.cupsd.service
    sudo systemctl enable --now ntpd.service
    sudo systemctl enable --now NetworkManager.service

    echo -e "\nSetting keymap on Xorg"
    sudo localectl set-x11-keymap $X11KEYMAP
    
    echo "\n# Final steps..."
    # Remove no password sudo rights
    sudo sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

    # Change the radeon driver with amdgpu for old hardware
    sudo sed -i 's|GRUB_CMDLINE_LINUX_DEFAULT="|GRUB_CMDLINE_LINUX_DEFAULT="radeon.cik_support=0 amdgpu.cik_support=1 radeon.si_support=0 amdgpu.si_support=1 |g' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg

    # Eliminate Tearing
    sudo sed -i 's|EndSection|        Option "TearFree" "on"\nEndSection|g' /usr/share/X11/xorg.conf.d/10-amdgpu.conf

    # VirtualBox Settings
    sudo modprobe vboxdrv
    sudo gpasswd -a $USER vboxusers

    # Set ChrisTitusTech/material-awesome theme for awesome
    git clone https://github.com/ChrisTitusTech/material-awesome.git $HOME/.config/awesome

    # Same theme for Qt/KDE applications and GTK applications, and fix missing indicators
    echo 'XDG_CURRENT_DESKTOP=Unity' | sudo tee -a /etc/environment
    echo 'QT_QPA_PLATFORMTHEME=gtk2' | sudo tee -a /etc/environment

    # VirtualBox theme fix
    sudo sed -i 's|Exec=VirtualBox %U|Exec=VirtualBox -style Fusion %U|g' /usr/share/applications/virtualbox.desktop

    echo "\n
    ###############################################################################
    # Done
    ###############################################################################
    "
}
