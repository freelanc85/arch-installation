# Modified version of Titus ArchMatic Installer Script

<img src="https://i.imgur.com/Yn29sze.png" />

This README contains the steps I do to install and configure a fully-functional Arch Linux installation containing a desktop environment, all the support packages (network, bluetooth, audio, printers, etc.), along with all my preferred applications and utilities. The shell scripts in this repo allow the entire process to be automated.)

---

## Setup Boot and Arch ISO on USB key

First, setup the boot USB and boot arch live iso. 

### Arch Live ISO (Pre-Install)

This step installs arch to your hard drive. *IT WILL FORMAT THE DISK*

Edit the variables.sh file with your data for the scripts use.

```bash
pacman -Syy git

git clone https://github.com/fsimchen/ArchMatic
cd ArchMatic

sh 1-script.sh

arch-chroot /mnt

git clone https://github.com/fsimchen/ArchMatic
cd ArchMatic

sh 2-script.sh

sh 3-script.sh

sh 4-script.sh

sh 5-script.sh

sh 6-script.sh

sh 7-script.sh
```

### Don't just run these scripts. Examine them. Customize them. Create your own versions.

---

### System Description
This runs Awesome Window Manager with the base configuration from the Material-Awesome project <https://github.com/ChrisTitusTech/material-awesome>.

To boot I use `systemd` because it's minimalist, comes built-in, and since the Linux kernel has an EFI image, all we need is a way to execute it.

I also install the LTS Kernel along side the rolling one, and configure my bootloader to offer both as a choice during startup. This enables me to switch kernels in the event of a problem with the rolling one.

### Troubleshooting Arch Linux

__[Arch Linux Installation Guide](https://github.com/rickellis/Arch-Linux-Install-Guide)__

#### No Wifi

```bash
sudo wifi-menu`
```

#### to be edited:

Eliminate Tearing
edit: /usr/share/X11/xorg.conf.d/10-amdgpu.conf
add: Option "TearFree" "on"

more do add
add polkit-gnome arandr corectrl pamac-aur-git firefox
