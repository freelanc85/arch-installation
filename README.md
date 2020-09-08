# Modified version of Titus ArchMatic Installer Script

<img src="https://i.imgur.com/Yn29sze.png" />

This README contains the steps I do to install and configure a fully-functional Arch Linux installation containing a desktop environment, all the support packages (network, bluetooth, audio, printers, etc.), along with all my preferred applications and utilities. The shell scripts in this repo allow the entire process to be automated.)

---

## Setup Boot and Arch ISO on USB key

First, setup the boot USB, boot arch live iso, and run the `preinstall.sh` from terminal. 

### Arch Live ISO (Pre-Install)

This step installs arch to your hard drive. *IT WILL FORMAT THE DISK*

```bash
pacman -Syy --noconfirm wget
```
```bash
wget https://raw.githubusercontent.com/fsimchen/ArchMatic/master/0-preinstall.sh
sh 0-preinstall.sh
arch-chroot /mnt
wget https://raw.githubusercontent.com/fsimchen/ArchMatic/master/1-preinstall.sh
sh 1-preinstall.sh
reboot
```

### Arch Linux First Boot

```bash
pacman -S --noconfirm git
git clone https://github.com/fsimchen/ArchMatic
cd ArchMatic
./2-setup.sh
./3-base.sh
./4-software-pacman.sh
./5-software-aur.sh
./6-post-setup.sh
```

### Don't just run these scripts. Examine them. Customize them. Create your own versions.

---

### System Description
This runs Awesome Window Manager with the base configuration from the Material-Awesome project <https://github.com/ChrisTitusTech/material-awesome>.

To boot I use `systemd` because it's minimalist, comes built-in, and since the Linux kernel has an EFI image, all we need is a way to execute it.

I also install the LTS Kernel along side the rolling one, and configure my bootloader to offer both as a choice during startup. This enables me to switch kernels in the event of a problem with the rolling one.

### Troubleshooting Arch Linux

__[Arch Linux Installation Gude](https://github.com/rickellis/Arch-Linux-Install-Guide)__

#### No Wifi

```bash
sudo wifi-menu`
```

#### Initialize Xorg:
At the terminal, run:

```bash
xinit
```