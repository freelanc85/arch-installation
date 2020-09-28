#!/usr/bin/env bash

function bootloader {
    if [ $BOOTTYPE == 'EFI' ]
    then
        pacman -S efibootmgr mtools dosfstools --noconfirm --needed
    fi

    sed -i 's/MODULES=()/MODULES=(btrfs)/g' /etc/mkinitcpio.conf
    mkinitcpio -p linux

    if [ $BOOTTYPE == 'BIOS' ]
    then
        grub-install --target=i386-pc ${DISK}
        
        # Activate grub flag to boot on btrf subvolume
        sed -i 's|GRUB_CMDLINE_LINUX_DEFAULT="|GRUB_CMDLINE_LINUX_DEFAULT="subvol=btrfs-root |g' /etc/default/grub
    else
        grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    fi

    grub-mkconfig -o /boot/grub/grub.cfg
}
