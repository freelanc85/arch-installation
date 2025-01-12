#!/usr/bin/env bash
source ./autoload.sh

echo "Setting NTP . . ."
timedatectl set-ntp true

echo "Setting pacman mirrorlist . . ."
reflector -c "Australia" -f 10 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syy

echo "Installing git and btrfs-progs . . ."
pacman -S git btrfs-progs --noconfirm --needed

echo "Setting filesystem . . ."
filesystem

echo "Copy scripts to /opt/arch for reuse later . . ."
cp -R $HOME/arch /mnt/opt/
chmod -R 777 /mnt/opt/arch