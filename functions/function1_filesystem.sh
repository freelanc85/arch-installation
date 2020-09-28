#!/usr/bin/env bash

function filesystem {

    if [ $BOOTTYPE == 'BIOS' ]
    then
        cfdisk $DISK
        ROOTPARTITION=1
    else
        echo 'Command: n'
        echo 'Last sector: +200M'
        echo 'Hex code: ef00'
        echo ''
        echo 'Command: n'
        echo ''
        echo 'Command: w'
        echo 'Y'
        echo ''
        gdisk /dev/sda
        mkfs.fat32 -F32 -L "BOOT" "${DISK}1"
        ROOTPARTITION=2
    fi
    
    mkfs.btrfs -f -L "ROOT" "${DISK}${ROOTPARTITION}"

    echo "Setting btrfs subvolumes..."
    mount "${DISK}${ROOTPARTITION}" /mnt

    btrfs su cr /mnt/@
    
    if [ $BOOTTYPE == 'BIOS' ]
    then
        btrfs su cr /mnt/@grub
    fi

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
    mount -o noatime,compress=lzo,space_cache,subvol=@ "${DISK}${ROOTPARTITION}" /mnt

    # Create dirs for subvolumes
    mkdir /mnt/{boot,srv,home,.snapshots,tmp,var,swap}
    if [ $BOOTTYPE == 'BIOS' ]
    then
        mkdir /mnt/boot/grub
    fi
    
    # Mount subvolumes
    mount -o noatime,compress=lzo,space_cache,subvol=@home "${DISK}${ROOTPARTITION}" /mnt/home
    if [ $BOOTTYPE == 'BIOS' ]
    then
        mount -o noatime,compress=lzo,space_cache,subvol=@grub "${DISK}${ROOTPARTITION}" /mnt/boot/grub
    fi
    mount -o noatime,compress=lzo,space_cache,subvol=@srv "${DISK}${ROOTPARTITION}" /mnt/srv
    mount -o noatime,compress=lzo,space_cache,subvol=@.snapshots "${DISK}${ROOTPARTITION}" /mnt/.snapshots
    mount -o nodatacow,subvol=@tmp "${DISK}${ROOTPARTITION}" /mnt/tmp
    mount -o nodatacow,subvol=@var "${DISK}${ROOTPARTITION}" /mnt/var
    mount -o nodatacow,subvol=@swap "${DISK}${ROOTPARTITION}" /mnt/swap

    if [ $BOOTTYPE == 'EFI' ]
    then
        mount "${DISK}1" /mnt/boot
    fi

    chattr +C /mnt/tmp/
    chattr +C /mnt/var/

    echo "pacstrap..."
    pacstrap /mnt $(printf "%s " "${PACSTRAPPKGS[@]}") --noconfirm --needed
    genfstab -U /mnt >> /mnt/etc/fstab
}
