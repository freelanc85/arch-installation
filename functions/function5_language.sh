#!/usr/bin/env bash

function language {
    ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    hwclock --systohc
    sed -i "s/^#${LOCALE}/${LOCALE}/" /etc/locale.gen
    locale-gen
    echo LANG=$LANG >> /etc/locale.conf
    echo -e "KEYMAP=${KEYMAP}\nFONT=ter-v32b\n" >> /etc/vconsole.conf
    systemctl enable systemd-timesyncd
    timedatectl --no-ask-password set-ntp 1
    localectl --no-ask-password set-locale LANG="${LANG}" LC_TIME="${LANG}"
}
