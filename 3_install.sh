#!/usr/bin/env bash
source ./autoload.sh

echo "Setting language and locale . . ."
language

echo "Setting Hostname . . ."
sudo hostnamectl --no-ask-password set-hostname $HOSTNAME
echo -e "127.0.0.1 localhost\n::1 localhost\n127.0.0.1 ${HOSTNAME}.localdomain ${HOSTNAME}\n" | sudo tee /etc/hosts

echo "Installing desktop and user packages: $(printf "%s " "${DESKTOPPKGS[@]} ${USERPKGS[@]}")"
sudo pacman -S $(printf "%s " "${DESKTOPPKGS[@]} ${USERPKGS[@]}") --noconfirm --needed

echo "Installing YAY ..."
installyay

echo "Setting AUR repository mirrorlist . . ."
reposaur

echo "Dependency fix for ttf-google-fonts-git . . ."
sudo pacman -Rdd adobe-source-code-pro-fonts

echo "Installing AUR packages: $(printf "%s " "${AURPKGS[@]}")"
for PKG in "${AURPKGS[@]}"; do
    echo "Installing AUR package: $PKG"
    yay -S --noconfirm $PKG
done

echo "Disabling buggy cursor inheritance . . ."
# When you boot with multiple monitors the cursor can look huge. This fixes it.
echo '[Icon Theme]' | sudo tee /usr/share/icons/default/index.theme
echo '#Inherits=Theme' | sudo tee -a /usr/share/icons/default/index.theme

echo "Increasing file watcher count . . ."
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
mkdir $HOME/.local/
mkdir $HOME/.local/share/
mkdir $HOME/.local/share/applications/
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
sudo systemctl start snapper-timeline.timer
sudo systemctl enable snapper-timeline.timer
sudo systemctl start snapper-cleanup.timer
sudo systemctl enable snapper-cleanup.timer

# Starting and enabling the grub-btrfs service:
sudo systemctl start grub-btrfs.path
sudo systemctl enable grub-btrfs.path

if [ $BOOTTYPE == 'BIOS' ]
then
    sudo sed -i 's|#GRUB_BTRFS_OVERRIDE_BOOT_PARTITION_DETECTION="false"|GRUB_BTRFS_OVERRIDE_BOOT_PARTITION_DETECTION="true"|g' /etc/default/grub-btrfs/config
fi

# Wine
sudo pacman -S wine-staging winetricks giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm --needed

# DXVK dependencies / Vulkan API
sudo pacman -S lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader lib32-gnutls lib32-libldap lib32-libgpg-error lib32-sqlite lib32-libpulse vulkan-tools vkd3d lib32-vkd3d lib32-vulkan-mesa-layers vulkan-mesa-layers lib32-alsa-plugins --noconfirm --needed

# Lutris
sudo pacman -S lutris --noconfirm --needed

# Theming
git clone --depth 1 https://github.com/afraidofmusic/materia-theme-dracula.git
cd materia-theme-dracula
sudo ./install.sh
cp /opt/arch/configs/.gtkrc-2.0 $HOME/.gtkrc-2.0
mkdir $HOME/.config/gtk-3.0
cp /opt/arch/configs/.gtk-3.0_settings.ini $HOME/.config/gtk-3.0/settings.ini
gsettings set org.gnome.desktop.interface gtk-theme Materia-dark

echo "Remove no password sudo rights . . ."
sudo sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

echo -e "\nInstallation Complete!"
