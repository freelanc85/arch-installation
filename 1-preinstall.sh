#!/usr/bin/env bash
#
echo "Please enter disk: (example /dev/sda)"
read DISK
echo "--------------------------------------"
echo "-- swapfile  --"
echo "--------------------------------------"
truncate -s 0 /swap/swapfile
chattr +C /swap/swapfile
btrfs property set swap/swapfile compression none
dd if=/dev/zero of=/swap/swapfile bs=1G count=2 status=progress
chmod 600 /swap/swapfile
mkswap /swap/swapfile
swapon /swap/swapfile
echo '/swap/swapfile none swap defaults 0 0' >> /etc/fstab

echo "--------------------------------------"
echo "-- Bootloader Installation  --"
echo "--------------------------------------"
pacman -S grub grub-btrfs --noconfirm --needed

sed -i 's/MODULES=()/MODULES=(btrfs)/g' /etc/mkinitcpio.conf

mkinitcpio -p linux
grub-install --target=i386-pc ${DISK}
grub-mkconfig -o /boot/grub/grub.cfg

echo "--------------------------------------"
echo "--          Network Setup           --"
echo "--------------------------------------"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager

echo "--------------------------------------"
echo "--      Set Password for Root       --"
echo "--------------------------------------"
echo "Enter password for root user: "
passwd root

exit
umount -R /mnt

echo "--------------------------------------"
echo "--   SYSTEM READY FOR FIRST BOOT    --"
echo "--------------------------------------"
