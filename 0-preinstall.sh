#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo "-------------------------------------------------"
echo "Setting up mirrors for optimal download - BR Only"
echo "-------------------------------------------------"
timedatectl set-ntp true
pacman -S --noconfirm pacman-contrib
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
#curl -s "https://www.archlinux.org/mirrorlist/?country=US&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 - > /etc/pacman.d/mirrorlist
reflector --latest 200 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

#echo -e "\nInstalling prereqs...\n$HR"
#pacman -S --noconfirm btrfs-progs

echo "-------------------------------------------------"
echo "-------select your disk to format----------------"
echo "-------------------------------------------------"
lsblk
echo "Please enter disk: (example /dev/sda)"
read DISK
echo "--------------------------------------"
echo -e "\nFormatting disk...\n$HR"
echo "--------------------------------------"

# disk prep
wget https://raw.githubusercontent.com/fsimchen/ArchMatic/master/sfdisk.layout
sfdisk /dev/sda < sfdisk.layout

# make filesystems
echo -e "\nCreating Filesystems...\n$HR"

mkfs.ext4 -L "BOOT" "${DISK}1"
mkfs.btrfs -L "ROOT" "${DISK}2"

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

mount -o nodatacow,subvol=@swap "${DISK}2" /mnt/swap
mount -o nodatacow,subvol=@var "${DISK}2" /mnt/var
mount "${DISK}1" /mnt/boot

echo "--------------------------------------"
echo "-- Arch Install on Main Drive       --"
echo "--------------------------------------"
pacstrap /mnt base base-devel linux linux-firmware vim nano sudo --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab
