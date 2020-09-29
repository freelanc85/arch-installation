#!/usr/bin/env bash
source ./autoload.sh

echo "Setting swapfile . . . "
swapfile

echo "Enabling multilib . . ."
multilib

echo "Installing base packages: $(printf "%s " "${BASEPKGS[@]}")"
pacman -S $(printf "%s " "${BASEPKGS[@]}") --noconfirm --needed

echo "Setting bootloader . . ."
bootloader

echo "Setting network . . ."
systemctl enable --now NetworkManager

echo "Setting root passwd . . ."
echo -e "${PASSWORD}\n${PASSWORD}" | passwd root

echo "Adding USER: $NORMALUSER . . ."
useradd -mG audio,video,wheel,storage,network,rfkill -s /bin/bash $NORMALUSER

echo "Setting $NORMALUSER passwd . . ."
echo -e "${PASSWORD}\n${PASSWORD}" | passwd $NORMALUSER

echo "Setting sudo rights . . ."
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

echo "Setting sudo no password rights . . ."
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

echo  -e "\nSYSTEM READY FOR FIRST REBOOT"
echo "Don’t forget to take out the live USB before powering on the system again."
exit
