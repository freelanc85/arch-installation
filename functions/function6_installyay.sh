#!/usr/bin/env bash

function installyay {
    echo "Installing YAY ..."
    cd "${HOME}"
    git clone "https://aur.archlinux.org/yay.git"
    cd ${HOME}/yay
    makepkg -si --noconfirm
}
