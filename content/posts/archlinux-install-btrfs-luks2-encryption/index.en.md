---
title: "ARCH LINUX BTRFS INSTALL WITH LUKS2 ENCRYPTION"
date: 2024-05-13T10:00:00+01:00
draft: true
tags: ["Arch Linux", "LUKS", "BTRFS"]
categories: ["tutorials", "tips"]
align: left
featuredImage: banner.en.png
---

Embrace the DIY spirit with Arch Linux! This guide walks you through a minimal installation with LUKS encryption and BTRFS, perfect for crafting your personalized daily powerhouse.

Some relevant details about the environment:

- the laptop boots to UEFI only
- wired network connection
- Arch Linux is the only OS on a dual disk laptop
- GPT partition table with two partitions:
  - unencrypted `/efi` EFI system partition (ESP)
  - LUKS encrypted `/` partition
- BTRFS as main file system with multiple sub volumes
- unlock system at boot with single passphrase
- GRUB as bootloader

## Installation

### Preparing the USB install media

Download the latest ISO image from <https://archlinux.org/download/>. The needed ISO file name have the format `archlinux-YYYY.MM.DD-x86_64.iso`.

It is recommended to verify the checksum of the ISO before preparing the USB flash drive. To do this, also download the file `sha256sums.txt` to the same directory as the ISO image and run the command below.

```shell
sha256sum -c sha256sums.txt
```

The output should be similar to:

```shell
archlinux-2023.09.01-x86_64.iso: OK
sha256sum: archlinux-x86_64.iso: No such file or directory
archlinux-x86_64.iso: FAILED open or read
sha256sum: archlinux-bootstrap-2023.09.01-x86_64.tar.gz: No such file or directory
archlinux-bootstrap-2023.09.01-x86_64.tar.gz: FAILED open or read
sha256sum: archlinux-bootstrap-x86_64.tar.gz: No such file or directory
archlinux-bootstrap-x86_64.tar.gz: FAILED open or read
sha256sum: WARNING: 3 listed files could not be read
```

The important line to check is the one which contains the same name of the downloaded image: `archlinux-2023.09.01-x86_64.iso: OK`. The warning about three files that could not be read is expected since only one ISO file was downloaded.

There are different methods to "burn" the ISO to the USB drive, I'll list only two methods in this article.

#### Using `Ventoy`

If you already use [Ventoy](https://www.ventoy.net/en/index.html), this is the easiest way. The Ventoy setup and usage is out of scope for this article.

To see the Arch Linux option in Ventoy's boot menu, just copy the downloaded ISO `archlinux-YYYY.MM.DD-x86_64.iso` to the USB drive in the same directory of other ISO images and reboot. Ventoy should generate a menu entry for Arch Linux automatically.

#### Using `dd`

`dd` is a well-known command-line utility available on all Linux distributions, its primary purpose is to convert and copy files.

Using `dd`, we can write the ISO image to an unmounted USB drive.

{{< admonition type=warning title="WARNING" open=true >}}
Using `dd` will wipe all data on the chosen device. Be careful!
{{< /admonition >}}

On Linux, USB drives usually appears as `sdx1`, `sdbx1`, etc. Remember to remove the partition number from the `dd` command.

```shell
sudo dd if=archlinux-RELEASE_VERSION-x86_64.iso of=/dev/sdx bs=4M status=progress oflag=sync
```

### Booting the installer

Insert USB device with the installer and set your device to boot from it. The installer will auto-login as `root`.

### Preparing the system for the installation

#### Setting the keyboard layout

The default console key map is `us`. It is a good idea to match the keyboard layout with the one used in the installation. This will prevent errors when creating the needed passwords.

List available layouts:

```shell
localectl list-keymaps
```

Load the appropriate key map:

```shell
loadkeys uk
```

#### Setting the font

The default font can be small if you are using a high-resolution display. Check `/usr/share/kbd/consolefonts` for other fonts.

You can check some previews [here](https://adeverteuil.github.io/linux-console-fonts-screenshots/). Then, set the font.

```shell
setfont ter-v24n
```

#### Checking the boot mode

The installer should boot Arch in UEFI mode if the system is configured accordingly. It is worth to check though.

```shell
ls /sys/firmware/efi/efivars
```

If the directory does not exist, the system did not boot in UEFI mode. Reboot the machine and check the configuration.

{{< admonition type=note title="NOTE:" open=true >}}
Although it is possible to use this guide to install Arch in a BIOS system, all steps were tested in my UEFI based laptop. Pay special attention about the drive partitioning steps.
{{< /admonition >}}

#### Connect to internet

The Ethernet adapter will be configured automatically using DHCP.

For wireless connection behind WPA2 (most common scenario), `iwd` can be used. The instructions below can be used as a reference. More details can be found at the Arch Wiki article [iwd](https://wiki.archlinux.org/title/iwd)

{{< admonition type=tip title="TIP:" open=true >}}

- In the `iwctl` prompt, commands and devices can be auto-completed by hitting `Tab`.
- To exit the interactive prompt, send EOF by pressing `Ctrl+d`.
- You can use all commands as command line arguments without entering an interactive prompt. For example: `iwctl device wlan0 show`.
{{< /admonition >}}

```shell
iwctl
```

The interactive prompt is then displayed with a prefix of `[iwd]#`.

| `iw` command                                     | Description                           |
| ------------------------------------------------ | ------------------------------------- |
| `device list`                                    | Get the wireless interface name.      |
| `device <device_name> set-property Powered on`   | Turn the device on.                   |
| `adapter <adapter_name> set-property Powered on` | Turn the adapter on.                  |
| `station <device_name> scan`                     | Scanning for available access points. |
| `station <device_name> get-networks`             | List all available networks.          |
| `station device connect <SSID>`                  | Connect to a network.                 |

#### Configuring the system clock

Enable the Network Time Protocol.

```shell
timedatectl set-ntp true
```

Check the available time zones.

```shell
timedatectl list-timezones
```

Set the desired time zone; in my case, `Europe/London`.

```shell
timedatectl set-timezone Europe/London
```

Check the time status.

```shell
timedatectl status
```

It should show something similar to:

```shell
Local time: Sun 2023-10-08 18:35:20 BST
Universal time: Sun 2023-10-08 17:35:20 UTC
RTC time: Sun 2023-10-08 17:35:20
Time zone: Europe/London (BST, +0100)
System clock synchronized: yes
NTP service: active
RTC in local TZ: no
```

### Configuring the disk

Check what is the device name where the system will be installed with `lsblk -f`.

In my case I have two potential devices `nvme0n1` and `nvme1n1`. On Linux, devices are located in `/dev`, therefore, my devices are `/dev/nvme0n1` and `/dev/nvme1n1`.

In this guide I'll use `/dev/nvme0n1`

Now create a variable for the chosen disk:

```shell
export MAIN_DISK=/dev/nvme0n1
```

#### Deleting old partition layout

{{< admonition type=warning title="WARNING" open=true >}}
The following commands perform destructive operations, you must proceed with care!
{{< /admonition >}}

```shell
wipefs -af ${MAIN_DISK}
```

```shell
sgdisk --zap-all --clear ${MAIN_DISK}
```

```shell
partprobe ${MAIN_DISK}
```

#### Partitioning the drive

Use `sgdisk` to list the partition type and its codes.

```shell
sgdisk --list-types
```

I'll use a simple layout for a single drive with a GPT (not the Chat one :D) partition table containing two partitions:

- EFI partition (ESP)
  - size: 512 MiB
  - code `EF00`
- Encrypted partition (LINUX)
  - size: the rest of space in the drive
  - code `8300`

```shell
sgdisk -n1::+512M -t1:EF00 -c1:'ESP' ${MAIN_DISK}
```

```shell
sgdisk -n2:: -t2:8300 -c2:'LINUX' ${MAIN_DISK}
```

```shell
partprobe ${MAIN_DISK}
```

Display the new partition table.

```shell
sgdisk -p ${MAIN_DISK}
```

Regarding the Swap file/partition, I'll use [zram-generator](https://github.com/systemd/zram-generator), to create a swap device compressed in the RAM.

## Encrypting the partition

At the time of this writing GRUB 2.06 has limited support for LUKS2 `Argon2i`. [See GRUB bug #55093](https://savannah.gnu.org/bugs/?55093). As `pbkdf2` is completely supported, it will be used in this guide.

Configure the encrypted partition.

```shell
cryptsetup luksFormat ${MAIN_DISK}p2 \
  --type luks2 \
  --cipher aes-xts-plain64 \
  --pbkdf pbkdf2 \
  --pbkdf-force-iterations 500000 \
  --use-random \
  --verify-passphrase  
```

Here is a brief explanation of the command options used:

`luksFormat`: format the specified device with LUKS encryption.

`--type luks2`: use LUKS2 as the encryption method.

`--cipher aes-xts-plain64`: specifies the encryption cipher to be used. `AES-XTS` is a strong and secure encryption algorithm.

`--pbkdf pbkdf2`: due to GRUB still not fully support LUKS2 `Argon2i`, we will use `pbkdf2`.

`--pbkdf-force-iterations`: set the iteration count to 500000. Lowering the iterations reduces security. It is recommended to use a stronger passphrase with higher entropy (entropy > 60 bits).

`--use-random`: tells `cryptsetup` to use random data for key generation. This is important for security, as it makes the encryption keys more difficult to guess.

`--verify-passphrase`: tells `cryptsetup` to prompt the user to enter the passphrase twice, to ensure that it is entered correctly.

{{< admonition type=info title="Important" open=true >}}
Before booting, the default keyboard layout `us` is the only one available, therefore, you must pay attention to this detail when you generate the password when using a keyboard with a different layout.
{{< /admonition >}}

### Formatting the partitions

The ESP partition is formatted with the `vfat` file system, and the Linux `root` partition uses `btrfs`.

```shell
cryptsetup open ${MAIN_DISK}p2 cryptoarch
```

```shell
mkfs.vfat -F32 -n ESP ${MAIN_DISK}p1
```

```shell
mkfs.btrfs -L ARCHLINUX /dev/mapper/cryptoarch
```

Running `lsblk -f` should present something like:

```shell
NAME           FSTYPE      FSVER            LABEL       UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
loop0          squashfs    4.0                                                                     0   100% /run/archiso/airootfs
sr0            iso9660     Joliet Extension ARCH_202405 2024-05-01-17-04-31-00                     0   100% /run/archiso/bootmnt
sr1                                                                                                         
vda                                                                                                         
├─vda1         vfat        FAT32            ESP         85A9-9309                                           
└─vda2         crypto_LUKS 2                            d80c797a-42f3-4a01-98cb-8aa49935fa97                
  └─cryptoarch btrfs                        ARCHLINUX   9700f1f4-c935-47ba-8544-0e000223837a
```

### Mounting the root device

```shell
mount /dev/mapper/cryptoarch /mnt
```

### Creating BTRFS sub volumes

Every BTRFS file system has a primary sub-volume with the identifier "ID=5". A sub-volume is a self-contained section of the file system with its own independent data.

Creating sub-volumes within a BTRFS file system enables data segmentation. This is especially beneficial when creating backup snapshots of the system. Consider a situation where you want to revert a system after a faulty upgrade, but any modifications made in a user's `/home` directory should be preserved.

To simplify sub-volume layout modifications, avoid mounting the top-level sub-volume as `/` (the default). Instead, create a sub-volume to hold the actual data and mount it to `/`.

I named the new sub-volume "@" as it is the default for [Snapper](https://github.com/openSUSE/snapper), a tool for creating backup snapshots which I will speak more later.

```shell
btrfs subvolume create /mnt/@
```

It is nice to have additional sub-volumes to better control over rolling back the system to a previous state, while preserving the current state of other directories. These sub-volumes will be excluded from any root sub-volume snapshots. There are an unlimited way to configure the sub-volumes, it will depend on the user needs. Here is the structure used in this guide:

| sub-volume | mount point                                                                   |
| ---------- | ----------------------------------------------------------------------------- |
| @home      | /home (preserve user data)                                                    |
| @snapshots | /.snapshots                                                                   |
| @cache     | /var/cache                                                                    |
| @libvirt   | /var/lib/libvirt (virtual machine images)                                     |
| @log       | /var/log (excluding log files makes troubleshooting easier after reverting /) |
| @tmp       | /var/tmp                                                                      |

The reasoning behind not excluding the entire /var out of the root snapshot is that `/var/lib/pacman` database in particular should mirror the rolled back state of installed packages.

To create the sub-volumes, `btrfs` provides the sub-command `subvolume` with the option `create`.

```shell
btrfs subvolume create /mnt/@home
```

```shell
btrfs subvolume create /mnt/@snapshots
```

```shell
btrfs subvolume create /mnt/@var_cache
```

```shell
btrfs subvolume create /mnt/@var_libvirt
```

```shell
btrfs subvolume create /mnt/@var_logs
```

```shell
btrfs subvolume create /mnt/@var_tmp
```

### Mounting the BTRFS sub volumes

Unmount the `root` partition to be able to mount the sub-volumes.

```shell
umount /mnt
```

Mount the new BTRFS root sub-volume with `subvol=@`.

```shell
mount -o noatime,compress=zstd:1,ssd,space_cache=v2,discard=async,subvol=@ /dev/mapper/cryptoarch /mnt
```

Create mount points for the additional sub volumes.

```shell
mkdir -pv /mnt/{home,.snapshots,var/cache,var/lib/libvirt,var/log,var/tmp}
```

Mount each sub-volume using the mount options. After typing the first command, use the up arrow key (⬆️) to repeat the previous command and adjust the options `subvol=@` and `/mnt/` to point to the correct sub-volume name and mount point.

```shell
mount -o noatime,compress=zstd:1,ssd,space_cache=v2,discard=async,subvol=@home /dev/mapper/cryptoarch /mnt/home
```

```shell
mount -o noatime,compress=zstd:1,ssd,space_cache=v2,discard=async,subvol=@snapshots /dev/mapper/cryptoarch /mnt/.snapshots
```

```shell
mount -o noatime,compress=zstd:1,ssd,space_cache=v2,discard=async,subvol=@var_cache /dev/mapper/cryptoarch /mnt/var/cache
```

```shell
mount -o noatime,compress=zstd:1,ssd,space_cache=v2,discard=async,subvol=@var_libvirt /dev/mapper/cryptoarch /mnt/var/lib/libvirt
```

```shell
mount -o noatime,compress=zstd:1,ssd,space_cache=v2,discard=async,subvol=@var_logs /dev/mapper/cryptoarch /mnt/var/log
```

```shell
mount -o noatime,compress=zstd:1,ssd,space_cache=v2,discard=async,subvol=@var_tmp /dev/mapper/cryptoarch /mnt/var/tmp
```

BTRFS supports several mount options. Here is a brief explanation of the command options used:

`noatime`: disables the updating of file access timestamps (`atime`) when files are read. This can improve performance by reducing the amount of disk I/O required.

`compress=zstd:1`: configures BTRFS to compress all files using the `zstd` compression algorithm with a compression level of 1. This will save disk space and improve performance, especially for files that are not frequently accessed.

`ssd`: enables SSD-specific optimizations in BTRFS. This can improve performance by reducing the amount of unnecessary disk I/O.

`space_cache=v2`: enables the use of the v2 space cache algorithm. This can improve performance by reducing the amount of time required to find free space on the disk.

`discard=async`: enables asynchronous discard of unused blocks. This can improve performance by reducing the amount of unnecessary disk I/O.

Detailed information can be found in [BTRFS documentation](https://btrfs.readthedocs.io/en/latest/btrfs-man5.html)

### Disable CoW for /var/lib/libvirt

BTRFS copy-on-write (CoW) can cause performance issues when virtual machines are created or deleted. This is because each time a file or directory is modified, a new version of it is created, and the previous version is kept until it is no longer needed. This can lead to a lot of disk space being used even when there are no actual changes. For this reason, it is recommended to disable CoW for the `/var/lib/libvirt` directory:

```shell
chattr -VR +C /mnt/var/lib/libvirt
```

### Mounting the ESP partition

```shell
mkdir -pv /mnt/efi
```

```shell
mount ${MAIN_DISK}p1 /mnt/efi
```

### Selecting package mirrors

Choose the faster mirrors to perform the package installation can drastically improve the installation speed.

```shell
pacman -Syy
```

Use [reflector](https://xyne.dev/projects/reflector) to generate a new set of mirrors to be used by `pacstrap`.

```shell
reflector --verbose --protocol https --latest 10 --sort rate --country GB --country IR --save /etc/pacman.d/mirrorlist
```

This will get the most recently synchronized 10 mirrors hosted in the UK or Ireland which uses `https` and sort them by speed. The result will be saved to `/etc/pacman.d/mirrorlist` which is the default location where `pacman` will search for mirrors definition.

## Installing base system

The package selection here depends on user needs. From the packages below, `vim` and `zsh` are optional, but recommended.

```shell
pacstrap /mnt base base-devel git dracut intel-ucode btrfs-progs networkmanager cryptsetup vim sudo zsh reflector
```

### Configuring the /etc/fstab

```shell
genfstab -U -p /mnt >> /mnt/etc/fstab
```

### Start configuring the base system

Now that the base system is installed, we can use `arch-chroot` to mount it and start the configuration.

```shell
arch-chroot /mnt /bin/bash
```

### Defining the `root` user password

```shell
passwd
```

Choose a strong password and type it twice. You can use [Bitwarden](https://bitwarden.com/password-generator/) in another device if you are out of ideas.

### Adding a standard user

Create a standard user and add it to the `wheel` group.

```shell
useradd -m -G wheel -s $(command -v zsh) kermit
```

Define the password for the newly created user.

```shell
passwd kermit
```

### Configuring `sudo` privileges

Enable the members of the `wheel` group to type all commands with `sudo`.

{{< admonition type=warning title="WARNING" open=true >}}
This gives `root` powers to users who are members of `wheel` group. While it is fine for single user PC/laptop, it can be dangerous in most situations. On production systems, prefer to create a file under `/etc/sudoers.d` and define granular `sudo` permissions for each user or even use a centralized system to control the permissions each user can have. Always remember of the [Principle of Least Privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege)
{{< /admonition >}}

We can use [sed](https://www.gnu.org/software/sed/) to replace `# %wheel ALL=(ALL:ALL) ALL` with `%wheel ALL=(ALL:ALL) ALL`

```shell
sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers
```

### Enabling the dracut-hook

Become the recently created non-root user.

```shell
su - kermit
```

Press `q` to ignore the Zsh shell configuration for now.

Get the `dracut-hook` repository source code.

```shell
git clone https://aur.archlinux.org/dracut-hook.git
```

Enter the cloned directory.

```shell
cd dracut-hook
```

Build and install the package.

```shell
makepkg -si
```

{{< admonition type=info title="Important" open=true >}}
After the installation finishes, press `CTRL+d` to return to the `root` prompt.
{{< /admonition >}}

### Configuring Dracut custom options

Create the file `/etc/dracut.conf.d/10-custom.conf`.

```shell
cat <<EOF > /etc/dracut.conf.d/10-custom.conf
omit_dracutmodules+=" network cifs nfs brltty "
hostonly="yes"
hostonly_cmdline="yes"
compress="zstd -3 -T0 -q"
EOF
```

Check if the file was created correctly.

```shell
cat /etc/dracut.conf.d/10-custom.conf
```

Further we will configure some other options and generate the `initramfs`.

### Configuring the time zone

Configure the system time zone and the system clock.

List the available time zones based on your continent.

```shell
ls -lha /usr/share/zoneinfo/Europe
```

Link the chosen time zone to `/etc/localtime`

```shell
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
```

Set the system time to the hardware clock.

```shell
hwclock --systohc
```

### Configuring the hostname

Configure the system hostname.

```shell
echo "archer" > /etc/hostname
```

Add the entries to `/etc/hosts`

```shell
cat <<EOF > /etc/hosts 
127.0.0.1   localhost
::1         localhost
127.0.1.1   archer.localdomain archer
EOF
```

### Configuring the system locale(s)

Configure the system locales.

Use `sed` to edit `/etc/locale.gen` and uncomment your preferred locale. In my case it is `en_GB.UTF-8 UTF-8`.

```shell
sed -i "s|#en_GB.UTF-8 UTF-8|en_GB.UTF-8 UTF-8|" /etc/locale.gen
```

Add the preferred locale in `/etc/locale.conf`

```shell
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
```

Finally, generate the locales.

```shell
locale-gen
```

### Configuring the system font and key map

Configure the font to be used in the console.

```shell
echo "FONT=ter-v24n" > /etc/vconsole.conf
```

Now, configure the keyboard layout.

```shell
echo "KEYMAP=uk" >> /etc/vconsole.conf
```

### Setting the default editor

Configure the default system editor.

```shell
echo "EDITOR=vim" > /etc/environment && echo "VISUAL=vim" >> /etc/environment
```

### Configuring the system network

There are different Linux packages that can be used to control the system network. I choose to use `NetworkManager` because it is simple and works out of the box.

Enable `NetworkManager` to start during system boot.

```shell
systemctl enable NetworkManager
```

The wired network connection will be configured via `DHCP` by default. In case you need to configure a wireless connection, `nmtui` can be used.

### Installing the kernel

Use [reflector](https://xyne.dev/projects/reflector) to generate a new set of mirrors to be used by `pacman`.

```shell
reflector --verbose --protocol https --latest 10 --sort rate --country GB --country IR --save /etc/pacman.d/mirrorlist
```

Finally, install the desired kernel, the kernel headers and the package `linux-firmware`.

```shell
pacman -S linux linux-lts linux-headers linux-lts-headers linux-firmware intel-ucode
```

If everything went fine, `dracut-hook` will detect a newly installed kernel and will build the `initrams` using the custom configurations created previously.

### Installing and configuring the GRUB bootloader

Install the needed packages.

```shell
pacman -S grub efibootmgr
```

Check the `UUID` of the encrypted `root` partition.

```shell
export LUKS_UUID=$(blkid -s UUID -o value ${MAIN_DISK}p2)
```

```shell
sed -i "s|GRUB_CMDLINE_LINUX=\"\"|GRUB_CMDLINE_LINUX=\"rd.luks.name=${LUKS_UUID}=cryptoarch root=/dev/mapper/cryptoarch rd.luks.allow-discards rd.lvm=0 rd.md=0 rd.dm=0\"|" /etc/default/grub
```

In this case, the `GRUB` options `rd.lvm=0`, `rd.md=0`, and `rd.dm=0` disable the automatic assembly of Logical Volume Management (LVM), multi-disk arrays (MD RAID), and device mapper (DM RAID) volumes, respectively. This can improve boot times by preventing Dracut from searching for and assembling these types of volumes if they are not present on the system.

Now, add `luks` to `GRUB_PRELOAD_MODULES`

```shell
sed -i "s|GRUB_PRELOAD_MODULES=\"part_gpt part_msdos\"|GRUB_PRELOAD_MODULES=\"part_gpt part_msdos luks\"|" /etc/default/grub
```

Set `GRUB_ENABLE_CRYPTODISK` to `y`

```shell
sed -i "s|#GRUB_ENABLE_CRYPTODISK=y|GRUB_ENABLE_CRYPTODISK=y|" /etc/default/grub
```

Now, install the bootloader

```shell
grub-install --target=x86_64-efi --efi-directory=/efi --boot-directory=/efi --bootloader-id=GRUB
```

The `--bootloader-id=` sets how the entry will appear in the UEFI system menu.

If nothing wrong happens during the installation, check if the entry "GRUB" created above is listed in the system UEFI.

```shell
efibootmgr
```

Now, generate the `GRUB` configuration file.

```shell
grub-mkconfig -o /boot/grub/grub.cfg
```

Check if `grub.cfg` has entries for `insmod cryptodisk` and `insmod luks`.

```shell
grep 'cryptodisk\|luks' /boot/grub/grub.cfg
```

### Exiting `chroot` and rebooting the system

```shell
exit
```

```shell
umount -R /mnt
```

```shell
systemctl reboot
```

If everything worked as intended, the prompt to type the LUKS password should appear even before the GRUB screen.

{{< admonition type=info title="Important" open=false >}}
It can take a half-minute or more for the partition to be decrypted. This delay can be shortened by setting a lower `--iter-time` when running `cryptsetup luksAddkey`, however, the downside is a reduction in the security.
{{< /admonition >}}

If the password is correct, the `GRUB` menu will appear, and you can choose your fresh Arch Linux installation

## Configuring the installed system

Now that Arch Linux is installed, the base system is running, but no UI is available. As much as we love the console interface, let's configure the system, add a DE (Desktop Environment) and some useful packages.

### Configuring `pacman` package manager

The file `/etc/pacman.conf` is responsible to configure the options for the Arch Linux package manager [pacman](https://wiki.archlinux.org/title/pacman). Observe the comments for each option.

```shell
# Misc options
#UseSyslog # Log action messages through syslog(). This will insert log entries into /var/log/messages or equivalent.
Color # Automatically enable colors only when pacman’s output is on a tty.
#NoProgressBar #Disables progress bars. This is useful for terminals which do not support escape characters.
CheckSpace # Enable space-checking functionality for all packages.
VerbosePkgLists # See old and new versions of available packages when pacman -Syu is invoked.
ParallelDownloads = 8 # Enable parallel connections to speed up downloads.
ILoveCandy # Add a Pac-Man style to pacman.
```

### Updating the system

```shell
sudo pacman -Syu
```

### Swap on RAM

Instead of having a file or partition based `swap`, we will use a compressed device stored in RAM.

Install the package [zram-generator](https://github.com/systemd/zram-generator).

```shell
sudo pacman -S zram-generator
```

Copy the sample configuration file.

```shell
sudo cp /usr/share/doc/zram-generator/zram-generator.conf.example /etc/systemd/zram-generator.conf
```

Check the online documentation and modify the file as needed.

```shell
# This file is part of the zram-generator project
# https://github.com/systemd/zram-generator

[zram0]
# This section describes the settings for /dev/zram0.
#
# The maximum amount of memory (in MiB). If the machine has more RAM
# than this, zram device will not be created.
#
# "host-memory-limit = none" may be used to disable this limit. This
# is also the default.
host-memory-limit = none

# The size of the zram device, as a function of MemTotal, both in MB.
# For example, if the machine has 1 GiB, and zram-size=ram/4,
# then the zram device will have 256 MiB.
# Fractions in the range 0.1–0.5 are recommended.
#
# The default is "min(ram / 2, 4096)".
zram-size = ram / 4

# The compression algorithm to use for the zram device,
# or leave unspecified to keep the kernel default.
compression-algorithm = zstd

# By default, file systems and swap areas are trimmed on-the-go
# by setting "discard".
# Setting this to the empty string clears the option.
options =

# Write incompressible pages to this device,
# as there's no gain from keeping them in RAM
#writeback-device = /dev/zvol/tarta-zoot/swap-writeback

# The following options are deprecated, and override zram-size.
# These values would be equivalent to the zram-size setting above.
#zram-fraction = 0.10
#max-zram-size = 2048
```

### Using a key file to unlock the system

To avoid the need to type the LUKS password twice, one to decrypt `/boot` to reach `/bbot/efi` and another to decrypt the root partition `/`, we can use a key file embedded in the `initramfs`.

Create hidden key file `.crypto_keyfile.bin` under `/`.

```shell
dd bs=512 count=4 iflag=fullblock if=/dev/random of=/.crypto_keyfile.bin
```

Adjust the permissions to allow only `root` to have access to the file.

```shell
chmod 600 /.crypto_keyfile.bin
```

### Configuring Dracut encryption options

Create the file `/etc/dracut.conf.d/20-encryption.conf`.

```shell
vim etc/dracut.conf.d/20-encryption.conf
```

And add the content below.

```shell
install_items+=" /etc/crypttab /.crypto_keyfile.bin "
```

Now it is a good time to reboot the system again and check if everything is working properly.

### Install a 'locate' command

[plocate](https://plocate.sesse.net/) is a modern version of `locate`, a member of the GNU suite [findutils](https://www.gnu.org/software/findutils/). It uses an index to speed up the searches, and it is very fast.

```shell
sudo pacman -S plocate
```

Update the file database.

```shell
sudo updatedb
```

The package `plocate` provides a `Systemd` timer that will periodically scan the system and keep the file database updated.

To enable the timer.

```shell
sudo systemctl enable --now plocate-updatedb.timer
```

### Enabling SSD TRIM

Periodic [TRIM](https://wiki.archlinux.org/title/Solid_state_drive#TRIM) optimizes performance on SSD storage.

Using BTRFS, asynchronous discard is [enabled](https://wiki.archlinux.org/title/Btrfs#SSD_TRIM) by default since kernel 6.2.

By enabling `fstrim.timer` the system will perform a periodic TRIM and span the SSD device life.

```shell
sudo systemctl enable --now fstrim.timer
```

### Enabling 'command-not-found'

When a command is typed, but not found in the system, the `command-not-found` functionality provided by the `pkgfile` package, will suggest an option based on the available packages in the Arch Linux repositories.

Install the package.

```shell
sudo pacman -S pkgfile
```

Update the package's database.

```shell
sudo pkgfile --update
```

Configure the shell to load the `command-no-found` rules. Edit the file `~/.zshrc` and add `command-not-found.zsh` to it.

```shell
if [[ -f /usr/share/doc/pkgfile/command-not-found.zsh ]]; then
    . /usr/share/doc/pkgfile/command-not-found.zsh
fi
```

### Installing the sound server

Some modern Linux distribution are using [pipewire](https://pipewire.org/) as sound server.

Installing the needed packages.

```shell
sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber alsa-utils sof-firmware
```

The package `sof-firmware` was required for my laptop, but may be not required for all systems.

### Installing an AUR helper

[Arch User Repository (AUR)](https://aur.archlinux.org/) is a community-driven repository for Arch users. It is one of the best things about Arch Linux. You can find almost every package available for Linux there.

{{< admonition type=warning title="Warning" open=true >}}
AUR packages are user produced content. Any use of the provided files is at your own risk.
{{< /admonition >}}

To be able to interact with AUR in a straightforward manner, an [AUR helper](https://wiki.archlinux.org/title/AUR_helpers) is needed. I like the use [paru](https://github.com/morganamilo/paru).

```shell
sudo pacman -S --needed base-devel
```

```shell
git clone https://aur.archlinux.org/paru-bin.git
```

```shell
cd paru-bin
```

```shell
makepkg -si
```

Generate the devel database for tracking *-git packages. This is only needed when you initially start using `paru`.

```shell
paru --gendb
```

Consult the [paru's](https://github.com/morganamilo/paru) documentation to learn how to use it.

### Desktop Environment

There are several choices for Linux Desktops Environments, my preferred one is, by far, [KDE Plasma](https://kde.org/).

You can install the full KDE Plasma with the majority of the applications that are part of the project. However, I prefer a more minimal KDE Plasma installation.

Install the following packages to have a minimal, but functional, KDE Plasma installation.

```shell
sudo pacman -S plasma-desktop konsole dolphin kscreen kate plasma-pa plasma-nm sddm 
```

Enable `sddm` to start during boot and become the default login screen.

```shell
sudo systemctl enable sddm
```

Reboot the system, then enjoy your Arch Linux fresh installation.

### Enabling system snapshots

One of the main advantages of using the BTRFS file system is the possibility to have snapshots and system rollbacks. To achieve this, we can use a combination of `snapper`, `snap-pac` and `grub-btrfs`.

- [snapper](https://github.com/openSUSE/snapper): Manage filesystem snapshots and allow undoing of system modifications
- [snap-pac](https://github.com/wesbarnett/snap-pac): Arch Linux `pacman` hooks that use snapper to create pre/post BTRFS snapshots like [openSUSE's YaST](https://github.com/yast/)
- [grub-btrfs](https://github.com/Antynea/grub-btrfs): Include BTRFS snapshots at boot options. (Grub menu)

Install all needed packages.

```shell
sudo pacman -S snapper snap-pac grub-btrfs
```

#### Creating `snapper` configuration for root sub volume

The first step is to get rid of the existing `/.snapshots` directory, because `snapper` will create it when we create the configuration.

```shell
sudo umount /.snapshots
```

```shell
sudo rm -rf /.snapshots
```

Now we can create the `snapper` configuration. `root` is only the configuration name, you can change it as you see fit.

```shell
sudo snapper -c root create-config /
```

The above command generates:

- A configuration file named `root` in `/etc/snapper/configs`
- Add the `root` entry to the `SNAPPER_CONFIGS` field in `/etc/conf.d/snapper`
- The sub volume `.snapshots` where future snapshots for this configuration will be stored.

#### Configuring the snapshots

Because we used `@` to identify all other sub volumes, we will remove the sub volume `.snapshots` automatically created by `snapper`.

```shell
sudo btrfs subvolume delete .snapshots
```

Now, re-create and mount the directory `./snapshots`

```shell
sudo mkdir /.snapshots
```

```shell
sudo mount -a
```

Configure the permissions for `./snapshots`. The directory owner must be `root`, and members of the `wheel` group will have read and execute permissions which will allow then to browse into the directory.

```shell
sudo chmod 750 /.snapshots
```

```shell
sudo chown :wheel /.snapshots
```

#### Configuring `grub-btrfs`

In order to automatically update `grub` configuration upon snapshot creation or deletion, start and enable the `grub-btrfsd` service.

```shell
sudo systemctl enable --now grub-btrfsd
```

#### Configuring automatic snapshots

The configuration of the `root` configuration created above is controlled by the file `/etc/snapper/configs/root`.

In the below example, I followed the [ArchWiki recommendation](https://wiki.archlinux.org/title/snapper#Set_snapshot_limits) for the limits and added the user to `ALLOW_USERS`

```shell
# subvolume to snapshot
SUBVOLUME="/"

# filesystem type
FSTYPE="btrfs"

# btrfs qgroup for space aware cleanup algorithms
QGROUP=""

# fraction or absolute size of the filesystems space the snapshots may use
SPACE_LIMIT="0.5"

# fraction or absolute size of the filesystems space that should be free
FREE_LIMIT="0.2"

# users and groups allowed to work with config
ALLOW_USERS="kermit"
ALLOW_GROUPS=""

# sync users and groups from ALLOW_USERS and ALLOW_GROUPS to .snapshots
# directory
SYNC_ACL="no"

# start comparing pre- and post-snapshot in background after creating
# post-snapshot
BACKGROUND_COMPARISON="yes"

# run daily number cleanup
NUMBER_CLEANUP="yes"

# limit for number cleanup
NUMBER_MIN_AGE="1800"
NUMBER_LIMIT="50"
NUMBER_LIMIT_IMPORTANT="10"

# create hourly snapshots
TIMELINE_CREATE="yes"

# cleanup hourly snapshots after some time
TIMELINE_CLEANUP="yes"

# limits for timeline cleanup
TIMELINE_MIN_AGE="1800"
TIMELINE_LIMIT_HOURLY="5"
TIMELINE_LIMIT_DAILY="7"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="0"
TIMELINE_LIMIT_YEARLY="0"

# cleanup empty pre-post-pairs
EMPTY_PRE_POST_CLEANUP="yes"

# limits for empty pre-post-pair cleanup
EMPTY_PRE_POST_MIN_AGE="1800"
```

Start and enable `snapper-timeline.timer` to launch the automatic snapshot timeline, and `snapper-cleanup.timer` to periodically clean up older snapshots.

```shell
sudo systemctl enable --now snapper-timeline.timer
```

```shell
sudo systemctl enable --now snapper-cleanup.timer
```

## References

- [ArchWiki](https://wiki.archlinux.org/title/Main_page)
- [A(rch) to Z(ram): Install Arch Linux with (almost) full disk encryption and BTRFS](https://www.dwarmstrong.org/archlinux-install/)
- [Ventoy](https://www.ventoy.net/en/doc_news.html)
