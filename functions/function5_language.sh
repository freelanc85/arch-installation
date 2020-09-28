#!/usr/bin/env bash

function language {
    sudo ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    sudo hwclock --systohc
    sudo sed -i "s/^#${LOCALE}/${LOCALE}/" /etc/locale.gen
    sudo locale-gen
    echo LANG=$LANG | sudo tee /etc/locale.conf
    echo -e "KEYMAP=${KEYMAP}\nFONT=ter-v32b\n" | sudo tee /etc/vconsole.conf
    sudo systemctl enable systemd-timesyncd
    sudo timedatectl --no-ask-password set-ntp 1
    sudo localectl --no-ask-password set-locale LANG="${LANG}" LC_TIME="${LANG}"
}
