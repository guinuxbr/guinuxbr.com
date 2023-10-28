---
title: "Archlinux Install BTRFS Encryption"
date: 2023-09-16T18:52:06+01:00
draft: true
---

Arch Linux is an excellent Linux for a hands-on, daily use system when you are curious and motivated - practically required - to dig into the nitty-gritty.

In this article, I'll describe the steps for a minimal Arch Linux installation using LUKS for disk encryption (excluding `/boot/efi`, more on that later) and using BTRFS as main file system.

Some relevant details about the environment:

- the laptop boots to UEFI only
- wired network connection
- Arch Linux is the only OS on a dual disk laptop
- GPT partition table with two partitions:
  - unencrypted `/boot/efi` EFI system partition (ESP)
  - LUKS encrypted `/` partition
- BTRFS as main file system with multiple sub volumes
- unlock system at boot with single passphrase
- GRUB as bootloader

## Installation

### Preparing the USB install media

Download the latest ISO image from <https://archlinux.org/download/>. The needed ISO file name have the format `archlinux-YYYY.MM.DD-x86_64.iso`.

It is recommended to verify the checksum of the ISO before preparing the USB flash drive. To do this, also download the file `sha256sums.txt` to the same directory as the ISO image and run the command below.

```bash
sha256sum -c sha256sums.txt
```

The output should be similar to:

```bash
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

```bash
sudo dd if=archlinux-RELEASE_VERSION-x86_64.iso of=/dev/sdx bs=4M status=progress oflag=sync
```

### Booting the installer

Insert USB device with the installer and set your device to boot from it. The installer will auto-login as `root`.

### Preparing the system for the installation

#### Setting the keyboard layout

The default console key map is `us`. It is a good idea to match the keyboard layout with the one used in the installation. This will prevent errors when creating the needed passwords.

List available layouts:

```bash
localectl list-keymaps
```

Load the appropriate key map:

```bash
loadkeys uk
```

#### Setting the font

The default font can be small if you are using a high-resolution display. Check `/usr/share/kbd/consolefonts` for other fonts.

You can check some previews [here](https://adeverteuil.github.io/linux-console-fonts-screenshots/). Then, set the font.

```bash
setfont ter-v24n
```

#### Checking the boot mode

The installer should boot Arch in UEFI mode if the system is configured accordingly. It is worth to check though.

```bash
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

```bash
iwctl
```

The interactive prompt is then displayed with a prefix of `[iwd]#`.

| iw command | Description |
|----------|----------|
| device list | Get the wireless interface name.  |
| device <device_name> set-property Powered on | Turn the device on. |
| adapter <adapter_name> set-property Powered on | Turn the adapter on. |
| station <device_name> scan | Scanning for available access points. |
| station <device_name> get-networks | List all available networks. |
| station device connect SSID | Connect to a network. |

#### Configuring the system clock

Enable the Network Time Protocol.

```bash
timedatectl set-ntp true
```

Check the available time zones.

```bash
timedatectl list-timezones
```

Set the desired time zone.

```bash
timedatectl set-timezone Europe/London
```

Check the time status.

```bash
timedatectl status
```

It should show something similar to:

```bash
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

#### Deleting old partition layout

{{< admonition type=warning title="WARNING" open=true >}}
The following commands perform destructive operations, you must proceed with care!
{{< /admonition >}}

```bash
wipefs -af /dev/nvme0n1
```

```bash
sgdisk --zap-all --clear /dev/nvme0n1
```

```bash
partprobe /dev/nvme0n1
```

#### Partitioning the drive

Use `sgdisk` to list the partition type and its codes.

```bash
sgdisk --list-types
```

I'll use a simple layout for a single drive with a GPT (not the Chat one :D) partition table containing two partitions:

- EFI partition (ESP)
  - size: 512 MiB
  - code `ef00`
- Encrypted partition (LUKS)
  - size: the rest of space in the drive
  - code `8309`

```bash
sgdisk -n 0:0:+512MiB -t 0:ef00 -c 0:esp /dev/nvme0n1
```

```bash
sgdisk -n 0:0:0 -t 0:8309 -c 0:luks /dev/nvme0n1
```

```bash
partprobe /dev/nvme0n1
```

Display the new partition table.

```bash
sgdisk -p /dev/nvme0n1
```

Regarding the Swap file/partition, I'll use [zram-generator](https://github.com/systemd/zram-generator), to create a swap device compressed in the RAM.

## Encrypting the partition

At the time of this writing GRUB 2.06 has limited support for LUKS2. [See GRUB bug #55093](https://savannah.gnu.org/bugs/?55093). As LUKS1 is completely supported, it will be used in this guide.

Configure the encrypted partition.

```bash
cryptsetup --type luks1 --cipher aes-xts-plain64 --hash sha512 --use-random --verify-passphrase luksFormat /dev/nvme0n1p2
```

Here is a brief explanation of the command options used:

`--type luks1`: as mentioned above, due to GRUB still not fully support LUKS2, version 1 will be used. LUKS1 is the older version of the LUKS standard, but it is still widely supported.

`--cipher aes-xts-plain64`: specifies the encryption cipher to be used. `AES-XTS` is a strong and secure encryption algorithm.

`--hash sha512`: specifies the hash algorithm to be used for key derivation. SHA-512 is a fast and secure hash algorithm which works very well with x64 CPUs.

`--use-random`: tells `cryptsetup` to use random data for key generation. This is important for security, as it makes the encryption keys more difficult to guess.

`--verify-passphrase`: tells `cryptsetup` to prompt the user to enter the passphrase twice, to ensure that it is entered correctly.

`luksFormat`: format the specified device with LUKS encryption.

{{< admonition type=info title="Important" open=true >}}
Before the boot, the default keyboard layout `us` is the only one available, therefore, you must pay attention to this detail when you generate the password when using a keyboard with a different layout.
{{< /admonition >}}

### Formatting the partitions

The ESP partition is formatted with the `vfat` file system, and the Linux `root` partition uses `btrfs`.

```bash
cryptsetup open /dev/nvme0n1p2 cryptoarch
```

```bash
mkfs.vfat -F32 -n ESP /dev/nvme0n1p1
```

```bash
mkfs.btrfs -L ArchLinux /dev/mapper/cryptoarch
```

### Mounting the root device

```bash
mount /dev/mapper/cryptoarch /mnt
```

### Creating BTRFS sub volumes

Every BTRFS file system has a primary sub-volume with the identifier "ID=5". A sub-volume is a self-contained section of the file system with its own independent data.

Creating sub-volumes within a BTRFS file system enables data segmentation. This is especially beneficial when creating backup snapshots of the system. Consider a situation where you want to revert a system after a faulty upgrade, but any modifications made in a user's `/home` directory should be preserved.

To simplify sub-volume layout modifications, avoid mounting the top-level sub-volume as `/` (the default). Instead, create a sub-volume to hold the actual data and mount it to `/`.

I named the new sub-volume "@" as it is the default for [Snapper](https://github.com/openSUSE/snapper), a tool for creating backup snapshots which I will speak more later.

```bash
btrfs sub volume create /mnt/@
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

To create the sub-volumes, `btrfs` provides the sub-command `sub-volume` with the option `create`.

```bash
btrfs sub-volume create /mnt/@home
```

```bash
btrfs sub-volume create /mnt/@snapshots
```

```bash
btrfs sub-volume create /mnt/@cache
```

```bash
btrfs sub-volume create /mnt/@libvirt
```

```bash
btrfs sub-volume create /mnt/@log
```

```bash
btrfs sub-volume create /mnt/@tmp
```

### Mounting the BTRFS sub volumes

Unmount the `root` partition to be able to mount the sub-volumes.

```bash
umount /mnt
```

Mount the new BTRFS root sub-volume with `subvol=@`.

```bash
mount -o noatime,compress-force=zstd:1,ssd,space_cache=v2,subvol=@ /dev/mapper/cryptoarch /mnt
```

Create mount points for the additional sub volumes.

```bash
mkdir -p /mnt/{home,.snapshots,var/cache,var/lib/libvirt,var/log,var/tmp}
```

Mount each sub-volume using the mount options. After typing the first command, use the up arrow key (⬆️) to repeat the previous command and adjust the options `subvol=@` and `/mnt/` to point to the correct sub-volume name and mount point.

```bash
mount -o noatime,compress-force=zstd:1,ssd,space_cache=v2,subvol=@home /dev/mapper/cryptoarch /mnt/home
```

```bash
mount -o noatime,compress-force=zstd:1,ssd,space_cache=v2,subvol=@snapshots /dev/mapper/cryptoarch /mnt/.snapshots
```

```bash
mount -o noatime,compress-force=zstd:1,ssd,space_cache=v2,subvol=@cache /dev/mapper/cryptoarch /mnt/var/cache
```

```bash
mount -o noatime,compress-force=zstd:1,ssd,space_cache=v2,subvol=@libvirt /dev/mapper/cryptoarch /mnt/var/lib/libvirt
```

```bash
mount -o noatime,compress-force=zstd:1,ssd,space_cache=v2,subvol=@log /dev/mapper/cryptoarch /mnt/var/log
```

```bash
mount -o noatime,compress-force=zstd:1,ssd,space_cache=v2,subvol=@tmp /dev/mapper/cryptoarch /mnt/var/tmp
```

BTRFS supports several mount options. Here is a brief explanation of the command options used:

`noatime`: disables the updating of file access timestamps (`atime`) when files are read. This can improve performance by reducing the amount of disk I/O required.

`compress-force=zstd:1`: forces BTRFS to compress all files using the `zstd` compression algorithm with a compression level of 1. This will save disk space and improve performance, especially for files that are not frequently accessed.

`ssd`: enables SSD-specific optimizations in BTRFS. This can improve performance by reducing the amount of unnecessary disk I/O.

`space_cache=v2`: enables the use of the v2 space cache algorithm. This can improve performance by reducing the amount of time required to find free space on the disk.

Detailed information can be found in [BTRFS documentation](https://btrfs.readthedocs.io/en/latest/btrfs-man5.html)

### Mounting the ESP partition

```bash
mkdir -p /mnt/boot/efi
```

```bash
mount /dev/nvme0n1p1 /mnt/boot/efi
```

### Selecting package mirrors

Choose the faster mirrors to perform the package installation can drastically improve the installation speed.

```bash
pacman -Syy
```

Use [reflector](https://xyne.dev/projects/reflector) to generate a new set of mirrors to be user by Arch Linux package manager, `pacman`.

```bash
reflector --verbose --protocol https --latest 10 --sort rate --country GB --country IR --save /etc/pacman.d/mirrorlist
```

This will get the most recently synchronized 10 mirrors hosted in the UK or Ireland which uses `https` and sort them by speed. The result will be saved to `/etc/pacman.d/mirrorlist` which is the default location where `pacman` will search for mirrors definition.

## Installing base system

The package selection here depends on user needs. From the packages below, `vim` and `zsh` are optional, but recommended.

```bash
pacstrap /mnt base base-devel git dracut intel-ucode btrfs-progs networkmanager cryptsetup vim sudo zsh
```

### Configuring the /etc/fstab

```bash
genfstab -U -p /mnt >> /mnt/etc/fstab
```

### Start configuring the base system

Now that the base system is installed, we can use `arch-chroot` to mount it and start the configuration.

```bash
arch-chroot /mnt /bin/bash
```

### Defining the `root` user password

```bash
passwd
```

Choose a strong password and type it twice. You can use [Bitwarden](https://bitwarden.com/password-generator/) in another device if you are out of ideas.

### Adding a standard user

Create a standard user and give it Administrator privileges using `sudo`.

```bash
useradd -m -G wheel -s $(which zsh) kermit
```

Further down I explain
Define the password for the newly created user.

```bash
passwd kermit
```

### Enabling the dracut-hook

Become the recently created non-root user.

```bash
su - guinuxbr
```

Get the `dracut-hook` repository source code.

```bash
git clone https://aur.archlinux.org/dracut-hook.git
```

Enter the cloned directory.

```bash
cd dracut-hook
```

Build and install the package.

```bash
makepkg -si
```

After the installation finishes, press `CTRL+d` to return to the `root` prompt.

### Configuring Dracut custom options

Using [vim](https://github.com/vim/vim), create the file `/etc/dracut.conf.d/10-custom.conf`.

```bash
vim /etc/dracut.conf.d/10-custom.conf
```

And add the content below.

```bash
omit_dracutmodules+=" network cifs nfs brltty "
compress="zstd"
```

Further we will configure some other options and generate the `initramfs`.

### Configuring the time zone

Configure the system time zone and the system clock.

List the available time zones based on your continent.

```bash
ls -lha /usr/share/zoneinfo/Europe
```

Link the chosen time zone to `/etc/localtime`

```bash
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
```

Set the system time to the hardware clock.

```bash
hwclock --systohc
```

### Configuring the hostname

Configure the system hostname.

```bash
echo "archer" > /etc/hostname
```

Add the entries to `/etc/hosts`

```bash
cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   archer.localdomain archer
EOF
```

### Configuring the system locale(s)

Configure the system locales.

Edit `/etc/locale.gen` and uncomment your preferred locale. In my case it is `en_GB.UTF-8 UTF-8`.

```bash
vim /etc/locale.gen
```

Add the preferred locale in `/etc/locale.conf`

```bash
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
```

Finally, generate the locales.

```bash
locale-gen
```

### Configuring the system font and key map

Configure the font to be used in the console.

```bash
echo "FONT=ter-v24n" > /etc/vconsole.conf
```

Now, configure the keyboard layout.

```bash
echo "KEYMAP=uk" >> /etc/vconsole.conf
```

### Setting the default editor

Configure the default system editor.

```bash
echo "EDITOR=nvim" > /etc/environment && echo "VISUAL=vim" >> /etc/environment
```

### Configuring `sudo` privileges

Enable the members of the `wheel` group to type all commands with `sudo`.

{{< admonition type=warning title="WARNING" open=true >}}
This gives `root` powers to users who are members of `wheel` group. While it is fine for single user PC/laptop, it can be dangerous in most situations. On production systems, prefer to create a file under `/etc/sudoers.d` and define granular `sudo` permissions for each user or even use a centralized system to control the permissions each user can have. Always remember of the [Principle of Least Privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege)
{{< /admonition >}}

We can use [sed](https://www.gnu.org/software/sed/) to replace `# %wheel ALL=(ALL:ALL) ALL` with `%wheel ALL=(ALL:ALL) ALL`

```bash
sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers
```

### Configuring the system network

There are different Linux packages that can be used to control the system network. I choose to use `NetworkManager` because it is simple and works out of the box.

Enable `NetworkManager` to start during system boot.

```bash
systemctl enable NetworkManager
```

The wired network connection will be configured via `DHCP` by default. In case you need to configure a wireless connection, `nmtui` can be used.

### Using a key file to unlock the system

To avoid the need to type the LUKS password twice, one to decrypt `/boot` to reach `/bbot/efi` and another to decrypt the root partition `/`, we can use a key file embedded in the `initramfs`.

Create hidden key file `.crypto_keyfile.bin` under `/`.

```bash
dd bs=512 count=4 iflag=fullblock if=/dev/random of=/.crypto_keyfile.bin
```

Adjust the permissions to allow only `root` to have access to the file.

```bash
chmod 600 /.crypto_keyfile.bin
```

### Configuring Dracut encryption options

Create the file `/etc/dracut.conf.d/20-encryption.conf`.

```bash
vim etc/dracut.conf.d/20-encryption.conf
```

And add the content below.

```bash
install_items+=" /etc/crypttab /.crypto_keyfile.bin "
```

### Installing the kernel

Finally, install the desired kernel, the kernel headers and the package `linux-firmware`.

```bash
pacman -S linux linux-lts linux-headers linux-lts-headers linux-firmware
```

If everything went fine, `dracut-hook` will detect a newly installed kernel and will build the `initrams` using the custom configurations created previously.

### Installing and configuring the GRUB bootloader

Install the needed packages.

```bash
pacman -S grub efibootmgr
```

Check the `UUID` of the encrypted `root` partition.

```bash
blkid -s UUID -o value /dev/nvme0n1p2
```

Edit the `GRUB_CMDLINE_LINUX_DEFAULT` entry in `/etc/default/grub` and add the options.

```bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 rd.luks.name=GENERATED_UUID=cryptoarch rd.luks.key=GENERATED_UUID=/.crypto_keyfile.bin rd.lvm=0 rd.md=0 rd.dm=0 nvidia_drm.modeset=1"`
```

In this case, the `GRUB` options `rd.lvm=0`, `rd.md=0`, and `rd.dm=0` disable the automatic assembly of Logical Volume Management (LVM), multi-disk arrays (MD RAID), and device mapper (DM RAID) volumes, respectively. This can improve boot times by preventing Dracut from searching for and assembling these types of volumes if they are not present on the system.

The option `nvidia_drm.modeset=1` enables the NVIDIA Dynamic Resolution Mode Setting (DRMS) kernel module.

Now, add `luks` to `GRUB_PRELOAD_MODULES`

```bash
GRUB_PRELOAD_MODULES="part_gpt part_msdos luks"
```

Set `GRUB_ENABLE_CRYPTODISK` to `y`

```bash
GRUB_ENABLE_CRYPTODISK=y
```

Now, install the bootloader

```bash
grub-install --target=x86_64-efi --efi-directory=/boot/efi --boot-directory=/boot/efi --bootloader-id=GRUB
```

The `--bootloader-id=` sets how the entry will appear in the UEFI system menu.

If nothing wrong happens during the installation, check if the entry "GRUB" created above is listed in the system UEFI.

```bash
efibootmgr
```

Now, generate the `GRUB` configuration file.

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

Check if `grub.cfg` has entries for `insmod cryptodisk` and `insmod luks`.

```bash
grep 'cryptodisk\|luks' /boot/grub/grub.cfg
```

### Exiting `chroot` and rebooting the system

```bash
exit
```

```bash
umount -R /mnt
```

```bash
systemctl reboot
```

If everything worked as intended, the prompt to type the LUKS password should appear even before the GRUB screen.

{{< admonition type=tip title="This is a tip" open=false >}}
It can take a half-minute or more for the partition to be decrypted. This delay can be shortened by setting a lower `--iter-time` when running `cryptsetup luksAddkey`, however, the downside is a reduction in the security.
{{< /admonition >}}

If the password is correct, the `GRUB` menu will appear, and you can choose your fresh Arch Linux installation

## Configuring the installed system

Now that Arch Linux is installed, the base system is running, but no UI is available. As much as we love the console interface, let's configure the system, add a DE (Desktop Environment) and some useful packages.

These are a few things I like to do next ...
3.1 Check for errors

Failed systemd services ...

$ systemctl --failed

High priority errors in the systemd journal ...

$ journalctl -p 3 -xb

3.2 Sudo

Allow a user (example: kermit) to execute superuser commands using sudo without being prompted for a password.

Create the file /etc/sudoers.d/sudoer_kermit with ...

echo "kermit ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudoer_kermit

3.3 Package manager

Bring some color and the spirit of Pacman to pacman with Color and ILoveCandy options.

Modify /etc/pacman.conf ...

# Misc options

Color
ILoveCandy

Update system ...

$ sudo pacman -Syu

3.4 Pinky clean

Part of good system hygiene is keeping the system regularly updated and clearing away cruft. Read more
3.5 SSH keys

Create cryptographic keys and disable password logins to make remote logins more secure. Read more
3.6 Linux LTS kernel

Install the Long-Term Support (LTS) Linux kernel as a fallback option to Arch's default kernel ...

$ sudo pacman -S linux-lts

Register the new kernel in the GRUB boot loader ...

$ sudo grub-mkconfig -o /efi/grub/grub.cfg

Reboot and select LTS kernel to test.

Confirm that running kernel is indeed -lts ...

$ uname -r
5.15.59-2-lts

Optional: If you want to use LTS as the default boot kernel, it is safe to remove Arch's linux kernel ...

$ sudo pacman -R linux

Re-run grub-mkconfig to generate an updated boot config.
3.7 Swap

In lieu of using a swapfile or dedicated swap partition as system swap, I create a swap device in RAM using the Linux kernel module zram. Read more
3.8 Command: 'locate'

Find files by name.

Install and update database ...

$ sudo pacman -S mlocate
$ sudo updatedb

Package mlocate contains an updatedb.timer unit, which invokes a database update each day. The timer is enabled after install.
3.9 TRIM

Periodic TRIM optimizes performance on SSD storage.

Enable a weekly task that discards unused blocks on the drive ...

$ sudo systemctl enable fstrim.timer

3.10 Command-not-found

Automatically search the official repositories when entering an unrecognized command, courtesy of pkgfile ...

$ sudo pacman -S pkgfile
$ sudo pkgfile --update

Edit ~/.bashrc ...

if [[ -f /usr/share/doc/pkgfile/command-not-found.bash ]]; then
    . /usr/share/doc/pkgfile/command-not-found.bash
fi

Source: .bashrc
3.11 Sound

Default Arch installation already includes the kernel sound system (ALSA).

Install pipewire as sound server ...

$ sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber alsa-utils

Reboot.

Test ...

$ pactl info | grep Pipe
Server Name: PulseAudio (on PipeWire 0.3.48)
$ speaker-test -c 2 -t wav -l 1

3.12 AUR

Arch User Repository (AUR) is a community-driven software package repository.

Compile/install/upgrade packages manually or use an AUR helper application.

Example: Install AUR helper yay ...

$ git clone <https://aur.archlinux.org/yay-git.git>
$ cd yay-git
$ makepkg -si

3.13 Snapshots

Create BTRFS snapshots and manage Arch system rollbacks using a combination of Snapper + snap-pac + grub-btrfs. Read more
3.14 Desktop

Many choices! Install a full-featured desktop such as GNOME, or put together a custom desktop built around a lightweight window manager.

I like Openbox. Read more
3.15 Arch news

Keep up-to-date with the latest news from the Arch development team by subscribing to:

    Mail: arch-annouce
    Arch News: RSS

Welcome to Arch!
Thanks for reading! Read other posts?

» Next: BTRFS snapshots and system rollbacks on Arch Linux

« Previous: Keep Arch updated and pinky clean
Home • Mastodon • GitLab • Contact

We are alone in the universe, or we are not. Either way, the implication is staggering. -- Arthur C. Clarke

© 2023 Daniel Wayne Armstrong • Created with ♥ using Zola
