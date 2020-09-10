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

sh 1_preInstallSetup.sh

arch-chroot /mnt

pacman -Syy git
git clone https://github.com/fsimchen/ArchMatic
cd ArchMatic

sh 2_preInstall.sh
reboot

# Log in as root
git clone https://github.com/fsimchen/ArchMatic
cd ArchMatic
sh 3_installSetup.sh
exit

# Log in as normal user now
git clone https://github.com/fsimchen/ArchMatic
cd ArchMatic
sh 4_installBase.sh
sh 5_installSoftware.sh
sh 6_installSoftwareAur.sh
sh 7_finalSetup.sh
```

### Don't just run these scripts. Examine them. Customize them. Create your own versions.

---

### System Description
This runs Awesome Window Manager with the base configuration from the Material-Awesome project <https://github.com/ChrisTitusTech/material-awesome>.

#### No Wifi

```bash
sudo wifi-menu
```
