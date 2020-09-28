#!/usr/bin/env bash

function reposaur {
    yay -S --noconfirm chaotic-mirrorlist
    yay -S --noconfirm chaotic-keyring
    echo '' | sudo tee -a /etc/pacman.conf
    echo '[andontie-aur]' | sudo tee -a /etc/pacman.conf
    echo 'SigLevel = Never' | sudo tee -a /etc/pacman.conf
    echo 'Server = https://aur.andontie.net/$arch' | sudo tee -a /etc/pacman.conf
    echo '' | sudo tee -a /etc/pacman.conf
    echo '[chaotic-aur]' | sudo tee -a /etc/pacman.conf
    echo 'SigLevel = Never' | sudo tee -a /etc/pacman.conf
    echo 'Include = /etc/pacman.d/chaotic-mirrorlist' | sudo tee -a /etc/pacman.conf
    echo '' | sudo tee -a /etc/pacman.conf
    sudo pacman -Syy
}
