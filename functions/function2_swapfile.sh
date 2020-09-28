#!/usr/bin/env bash

function swapfile {
    truncate -s 0 /swap/swapfile
    chattr +C /swap/swapfile
    btrfs property set /swap/swapfile compression none
    dd if=/dev/zero of=/swap/swapfile bs=1G count=4 status=progress
    chmod 600 /swap/swapfile
    mkswap /swap/swapfile
    swapon /swap/swapfile
    echo '/swap/swapfile none swap defaults 0 0' >> /etc/fstab
}
