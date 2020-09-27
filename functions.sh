#!/usr/bin/env bash

# Run logged as root
function preInstallSetup {

    echo "Setting NTP..."
    timedatectl set-ntp true

    echo "Setting pacman mirrorlist..."
    reflector -c "United States" -f 25 --sort rate --save /etc/pacman.d/mirrorlist
    pacman -Syy

    echo "Setting disk partitions..."
    cfdisk $DISK

    echo "Setting filesystem..."
    #mkfs.fat32 -L "BOOT" "${DISK}1"
    mkfs.btrfs -f -L "ROOT" "${DISK}1"

    echo "Setting btrfs subvolumes..."
    mount "${DISK}1" /mnt

    btrfs su cr /mnt/@
    btrfs su cr /mnt/@grub
    btrfs su cr /mnt/@srv
    btrfs su cr /mnt/@home
    btrfs su cr /mnt/@var
    btrfs su cr /mnt/@tmp
    btrfs su cr /mnt/@swap
    btrfs su cr /mnt/@.snapshots

    umount /mnt

    #read -s -n 1 -p "Press any key to continue . . ."
    #echo ""
    
    # Mount root subvolume
    mount -o noatime,compress=lzo,space_cache,subvol=@ "${DISK}1" /mnt

    # Create dirs for subvolumes
    mkdir /mnt/{boot,srv,home,.snapshots,tmp,var,swap}
    mkdir /mnt/boot/grub
    
    # Mount subvolumes
    mount -o noatime,compress=lzo,space_cache,subvol=@home "${DISK}1" /mnt/home
    mount -o noatime,compress=lzo,space_cache,subvol=@grub "${DISK}1" /mnt/boot/grub
    mount -o noatime,compress=lzo,space_cache,subvol=@srv "${DISK}1" /mnt/srv
    mount -o noatime,compress=lzo,space_cache,subvol=@.snapshots "${DISK}1" /mnt/.snapshots
    mount -o nodatacow,subvol=@tmp "${DISK}1" /mnt/tmp
    mount -o nodatacow,subvol=@var "${DISK}1" /mnt/var
    mount -o nodatacow,subvol=@swap "${DISK}1" /mnt/swap

    chattr +C /mnt/tmp/
    chattr +C /mnt/var/

    echo "Installing base packages ..."
    pacstrap /mnt base base-devel linux linux-firmware --noconfirm --needed
    genfstab -U /mnt >> /mnt/etc/fstab
}

# Run logged as root
function preInstall {
    echo "Setting swapfile  ..."
    truncate -s 0 /swap/swapfile
    chattr +C /swap/swapfile
    btrfs property set /swap/swapfile compression none
    dd if=/dev/zero of=/swap/swapfile bs=1G count=2 status=progress
    chmod 600 /swap/swapfile
    mkswap /swap/swapfile
    swapon /swap/swapfile
    echo '/swap/swapfile none swap defaults 0 0' >> /etc/fstab

    echo "Enabling multilib  ..."
    sed -i 's/^\(#\[multilib\]\)/\[multilib\]/' /etc/pacman.conf
    sed -i '/^\[multilib\]/{n;s/^#//}' /etc/pacman.conf
    pacman -Syy

    echo "Installing needed packages ..."
    echo "Packages: $(printf "%s " "${BASEPKGS[@]}")"
    pacman -S $(printf "%s " "${BASEPKGS[@]}") --noconfirm --needed
    #read -s -n 1 -p "Press any key to continue . . ."
    #echo ""

    echo "Setting bootloader ..."
    sed -i 's/MODULES=()/MODULES=(btrfs)/g' /etc/mkinitcpio.conf
    mkinitcpio -p linux
    grub-install --target=i386-pc ${DISK}

    # Activate grub flag to boot on btrf subvolume
    sed -i 's|GRUB_CMDLINE_LINUX_DEFAULT="|GRUB_CMDLINE_LINUX_DEFAULT="subvol=btrfs-root |g' /etc/default/grub
    
    grub-mkconfig -o /boot/grub/grub.cfg

    echo "Setting network ..."
    systemctl enable --now NetworkManager

    echo -e "${PASSWORD}\n${PASSWORD}" | passwd root

    useradd -mG audio,video,wheel,storage,network,rfkill -s /bin/bash $USER
    echo -e "${PASSWORD}\n${PASSWORD}" | passwd $USER

    echo  -e "\nSYSTEM READY FOR FIRST REBOOT"
    echo "Don’t forget to take out the live USB before powering on the system again."
    exit
}

# Log in as root
function installSetup {

    # Add sudo rights
    sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

    # Add sudo no password rights
    sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

    echo "Setting language and locale ..."
    ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    hwclock --systohc
    sed -i "s/^#${LOCALE}/${LOCALE}/" /etc/locale.gen
    locale-gen
    echo LANG=$LANG >> /etc/locale.conf
    echo -e "KEYMAP=${KEYMAP}\nFONT=ter-v32b\n" >> /etc/vconsole.conf

    systemctl enable systemd-timesyncd
    timedatectl --no-ask-password set-ntp 1
    localectl --no-ask-password set-locale LANG="${LANG}" LC_TIME="${LANG}"

    # Hostname
    hostnamectl --no-ask-password set-hostname $HOSTNAME
    echo -e "127.0.0.1 localhost\n::1 localhost\n127.0.0.1 ${HOSTNAME}.localdomain ${HOSTNAME}\n" >> /etc/hosts

    echo "Setting mirrorlist ..."
    reflector -c "United States" -f 25 --sort rate --save /etc/pacman.d/mirrorlist
}

# Run logged as normal user
function installBase {
    echo "Installing desktop packages ..."
    echo "Packages: $(printf "%s " "${DESKTOPPKGS[@]}")"
    sudo pacman -S $(printf "%s " "${DESKTOPPKGS[@]}") --noconfirm --needed
    #read -s -n 1 -p "Press any key to continue . . ."
    #echo ""
}

# Run logged as normal user
function installSoftware {
    echo "Installing user selected packages ..."
    echo "Packages: $(printf "%s " "${USERPKGS[@]}")"
    sudo pacman -S $(printf "%s " "${USERPKGS[@]}") --noconfirm --needed
    #read -s -n 1 -p "Press any key to continue . . ."
    #echo ""
}

# Run logged as normal user
function installSoftwareAur {

    echo '' | sudo tee -a /etc/pacman.conf
    echo '[chaotic-aur]' | sudo tee -a /etc/pacman.conf
    echo '# Brazil' | sudo tee -a /etc/pacman.conf
    echo 'Server = https://lonewolf.pedrohlc.com/$repo/$arch' | sudo tee -a /etc/pacman.conf

    echo '# USA' | sudo tee -a /etc/pacman.conf
    echo 'Server = https://builds.garudalinux.org/repos/$repo/$arch' | sudo tee -a /etc/pacman.conf
    echo 'Server = https://repo.kitsuna.net/$arch' | sudo tee -a /etc/pacman.conf
    
    echo '# Netherlands' | sudo tee -a /etc/pacman.conf
    echo 'Server = https://chaotic.tn.dedyn.io/$arch' | sudo tee -a /etc/pacman.conf
    
    echo '# Germany' | sudo tee -a /etc/pacman.conf
    echo 'Server = http://chaotic.bangl.de/$repo/$arch' | sudo tee -a /etc/pacman.conf
    echo '' | sudo tee -a /etc/pacman.conf

    sudo pacman -Syy

    echo "Installing YAY ..."
    cd "${HOME}"
    git clone "https://aur.archlinux.org/yay.git"
    cd ${HOME}/yay
    makepkg -si --noconfirm

    echo "Installing AUR packages ..."
    echo "Packages: $(printf "%s " "${AURPKGS[@]}")"

    for PKG in "${AURPKGS[@]}"; do
        yay -S --noconfirm $PKG

        read -s -n 1 -p "Press any key to continue . . ."
        echo ""
    done
}

# Run logged as normal user
function finalSetup {
    echo "FINAL SETUP AND CONFIGURATION"
    
    echo -e "\nDisabling buggy cursor inheritance ..."
    # When you boot with multiple monitors the cursor can look huge. This fixes it.
    echo '[Icon Theme]' | sudo tee /usr/share/icons/default/index.theme
    echo '#Inherits=Theme' | sudo tee -a /usr/share/icons/default/index.theme

    echo "Increasing file watcher count ..."
    # This prevents a "too many files" error in Visual Studio Code
    echo fs.inotify.max_user_watches=524288 | sudo tee /etc/sysctl.d/40-max-user-watches.conf && sudo sysctl --system

    echo "Disabling module-esound-protocol-unix ..."
    # Pulse audio loads the `esound-protocol` module, which best I can tell is rarely needed.
    # That module creates a file called `.esd_auth` in the home directory which I'd prefer to not be there. So...
    sudo sed -i 's|load-module module-esound-protocol-unix|#load-module module-esound-protocol-unix|g' /etc/pulse/default.pa

    echo "Setting bluetooth ..."
    sudo sed -i 's|#AutoEnable=false|AutoEnable=true|g' /etc/bluetooth/main.conf

    echo "Enabling systemctl daemons ..."
    sudo systemctl enable lightdm.service
    sudo systemctl enable --now bluetooth.service
    sudo systemctl enable --now org.cups.cupsd.service
    sudo systemctl enable --now ntpd.service
    sudo systemctl enable --now NetworkManager.service

    echo "Setting keymap on Xorg ..."
    sudo localectl set-x11-keymap $X11KEYMAP

    echo "Setting the amdgpu driver on grub..."
    sudo sed -i 's|GRUB_CMDLINE_LINUX_DEFAULT="|GRUB_CMDLINE_LINUX_DEFAULT="radeon.cik_support=0 amdgpu.cik_support=1 radeon.si_support=0 amdgpu.si_support=1 |g' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    sudo sed -i 's|EndSection|        Option "TearFree" "on"\nEndSection|g' /usr/share/X11/xorg.conf.d/10-amdgpu.conf

    echo "Setting VirtualBox ..."
    sudo modprobe vboxdrv
    sudo gpasswd -a $USER vboxusers

    # VirtualBox theme fix
    sudo sed -i 's|Exec=VirtualBox %U|Exec=VirtualBox -style Fusion %U|g' /usr/share/applications/virtualbox.desktop
    sudo mkdir $HOME/.local/share/applications/
    sudo cp /usr/share/applications/virtualbox.desktop $HOME/.local/share/applications/

    echo "Setting theme for AwesomeWM ..."
    git clone https://github.com/fsimchen/material-awesome.git $HOME/.config/awesome

    # Same theme for Qt/KDE applications and GTK applications, and fix missing indicators
    echo -e "XDG_CURRENT_DESKTOP=Unity\nQT_QPA_PLATFORMTHEME=gtk2" | sudo tee -a /etc/environment

    echo "Setting Snapper ..."
    # Unmounting and removing the snapshots directory:
    sudo umount /.snapshots/
    sudo rm -rf /.snapshots/
    
    # /etc/snapper/configs/root
    sudo snapper -c root create-config /
    sudo sed -i 's|ALLOW_USERS=""|ALLOW_USERS="'$USER'"|g' /etc/snapper/configs/root

    # /etc/snapper/configs/home
    sudo snapper -c home create-config /home
    sudo sed -i 's|ALLOW_USERS=""|ALLOW_USERS="'$USER'"|g' /etc/snapper/configs/home

    # /etc/snapper/configs/srv
    sudo snapper -c srv create-config /srv
    sudo sed -i 's|ALLOW_USERS=""|ALLOW_USERS="'$USER'"|g' /etc/snapper/configs/srv

    # /etc/snapper/configs/grub
    sudo snapper -c grub create-config /boot/grub
    sudo sed -i 's|ALLOW_USERS=""|ALLOW_USERS="'$USER'"|g' /etc/snapper/configs/grub

    # Starting and enabling the timers:
    sudo systemctl start snapper-timeline.time
    sudo systemctl enable snapper-timeline.timer
    sudo systemctl start snapper-cleanup.timer
    sudo systemctl enable snapper-cleanup.timer

    # Starting and enabling the grub-btrfs service:
    sudo systemctl start grub-btrfs.path
    sudo systemctl enable grub-btrfs.path

    sudo sed -i 's|#GRUB_BTRFS_OVERRIDE_BOOT_PARTITION_DETECTION="false"|GRUB_BTRFS_OVERRIDE_BOOT_PARTITION_DETECTION="true"|g' /etc/default/grub-btrfs/config

    # Wine
    sudo pacman -S wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm --needed

    # DXVK dependencies / Vulkan API
    sudo pacman -S lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader lib32-gnutls lib32-libldap lib32-libgpg-error lib32-sqlite lib32-libpulse vulkan-tools --noconfirm --needed

    # Lutris
    sudo pacman -S lutris --noconfirm --needed

    echo -e "\nRemove no password sudo rights..."
    sudo sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

    echo -e "\nInstallation Complete!"
}
