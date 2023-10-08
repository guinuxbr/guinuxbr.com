---
title: "Archlinux Install Btrfs Encryption"
date: 2023-09-16T18:52:06+01:00
draft: true
---

Arch Linux is an excellent Linux for a hands-on, daily use system when you are curious and motivated - practically required - to dig into the nitty gritty.

In this article, I'll describe the steps for a minimal Arch Linux installation using LUKS for disk encryption (excluding `/boot`, more on that later) and using BTRFS as main filesystem.

Some relevant details about the environment:

- the laptop boots to UEFI only
- wired network connection
- Arch Linux is the only OS on a dual disk laptop
- GPT partition table with two partitions:
  - unencryted `/boot` and EFI system partition (ESP)
  - LUKS encrypted `/` partition
- BTRFS as main filesystem with multiple subvolumes
- unlock system at boot with single passphrase
- GRUB as bootloader

## Installation

### Prepare USB install media

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

To see the Arch Linux option in Ventoy's boot menu, just copy the downloaded iso `archlinux-YYYY.MM.DD-x86_64.iso` to the USB drive in the same directory of other ISO images and reboot. Ventoy should generate a menu entry for Arch Linux automatically.

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

#### Setting the keyboard layout

The default console keymap is `us`. It is a good idea to match the keyboard layout with the one used in the installation. This will prevent errors when creating the needed passwords.

List available layouts:

```bash
localectl list-keymaps
```

Load the appropriate keymap:

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

The ethernet adapter will be configured automatically using DHCP.

For wireless connection behind WPA2 (most common scenario), `iwd` can be used. The instructions below can be used as a reference. More details can be found at the Arch Wiki article [iwd](https://wiki.archlinux.org/title/iwd)

{{< admonition type=tip title="TIP:" open=true >}}

- In the `iwctl` prompt you can auto-complete commands and device names by hitting `Tab`.
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

Check the avaialble timezones.

```bash
timedatectl list-timezones
```

Seti the desired timezone.

```bash
timedatectl set-timezone Europe/London
```

Check the time status.

```bash
timedatectl status
```

It should shouw something similar to:

```bash
Local time: Sun 2023-10-08 18:35:20 BST
Universal time: Sun 2023-10-08 17:35:20 UTC
RTC time: Sun 2023-10-08 17:35:20
Time zone: Europe/London (BST, +0100)
System clock synchronized: yes
NTP service: active
RTC in local TZ: no
```

#### Configuring the disk

Identify the internal storage device where Arch Linux will be installed by running lsblk -f.

Set a disk variable for use in installation commands.

Example: In this HOWTO I'm installing to my internal storage device identified as nvme0n1 ...

export disk="/dev/nvme0n1"

1.8 Delete old partition layout

wipefs -af $disk
sgdisk --zap-all --clear $disk
partprobe $disk

1.8.1 Optional: Fill disk with random data

Plain dm-crypt is used for a very fast wipe with randomness.

Create a temporary crypt device (example: target) ...

cryptsetup open --type plain -d /dev/urandom $disk target

This maps the container under /dev/mapper/target with a random password.

Fill the container with a stream of zeros using dd ...

dd if=/dev/zero of=/dev/mapper/target bs=1M status=progress oflag=direct

Using if=/dev/urandom is not required as the dm-crypt cipher is used for randomness.

When dd is finished, remove the mapping ...

cryptsetup close target

Links: ArchWiki: Dm-crypt drive preparation and Cryptsetup FAQ
1.9 Partition disk

Use sgdisk to create partitions.

List partition type codes ...

sgdisk --list-types

I use a layout for a single SSD with a GPT partition table that contains two partitions:

    Partition 1 - EFI partition (ESP) - size 512MiB, code ef00
    Partition 2 - encrypted partition (LUKS) - remaining storage, code 8309

sgdisk -n 0:0:+512MiB -t 0:ef00 -c 0:esp $disk
sgdisk -n 0:0:0 -t 0:8309 -c 0:luks $disk
partprobe $disk

Print the new partition table...

sgdisk -p $disk

In lieu of using a swapfile or dedicated swap partition as system swap, I create a swap device in RAM after the install is complete and I've rebooted into my new Arch environment.

Link: Managing partitions with sgdisk
1.10 Encrypt partition

Latest GRUB (2.06) has added limited support for LUKS2. Note, however, that when /boot is placed on a LUKS2 partition and using GRUB as the boot loader ...

    [O]nly the PBKDF2 key derival function is supported. This can mostly attributed to the fact that the libgcrypt library currently has no support for either Argon2i or Argon2id, which are the remaining KDFs supported by LUKS2.

In all circumstances, LUKS1 is successful. So that is what I use.

If the disk variable created earlier was set as a nvme-type storage device (as in this HOWTO), then the LUKS partition will be ${disk}p2. Otherwise, it will be ${disk}2 (drop the p).

Initialize the encrypted partition (partition #2) ...

cryptsetup --type luks1 -v -y luksFormat ${disk}p2

1.11 Format partitions

ESP partition (partition #1) is formatted with the vfat filesystem, and the Linux root partition (partition #2) uses btrfs ...

cryptsetup open ${disk}p2 cryptdev
mkfs.vfat -F32 -n ESP ${disk}p1
mkfs.btrfs -L archlinux /dev/mapper/cryptdev

1.12 Mount root device

mount /dev/mapper/cryptdev /mnt

1.13 Create BTRFS subvolumes

Each BTRFS filesystem has a top-level subvolume with ID=5. A subvolume is a part of the filesystem with its own independent data.

Creating subvolumes on a BTRFS filesystem allows the separation of data. This is particularly useful when creating backup snapshots of the system. An example scenario might be where its desirable to rollback a system after a broken upgrade, but any changes made in a user's /home directory should be left alone.

Changing subvolume layouts is made simpler by not mounting the top-level subvolume as / (the default). Instead, create a subvolume that contains the actual data, and mount that to /.

Use @ for the name of this new subvolume (which is the default for Snapper, a tool for making backup snapshots) ...

btrfs subvolume create /mnt/@

I create additional subvolumes for more fine-grained control over rolling back the system to a previous state, while preserving the current state of other directories. These subvolumes will be excluded from any root subvolume snapshots:

Subvolume -- Mountpoint

    @home -- /home (preserve user data)
    @snapshots -- /.snapshots
    @cache -- /var/cache
    @libvirt -- /var/lib/libvirt (virtual machine images)
    @log -- /var/log (excluding log files makes troubleshooting easier after reverting /)
    @tmp -- /var/tmp

The reasoning behind not excluding the entire /var out of the root snapshot is that /var/lib/pacman database in particular should mirror the rolled back state of installed packages.

Create the subvolumes ...

btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@libvirt
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@tmp

1.14 Mount subvolumes

Unmount the root partition ...

umount /mnt

Set mount options for the subvolumes ...

export sv_opts="rw,noatime,compress-force=zstd:1,space_cache=v2"

Options:

    noatime increases performance and reduces SSD writes.
    compress-force=zstd:1 is optimal for NVME devices. Omit the :1 to use the default level of 3. Zstd accepts a value range of 1-15, with higher levels trading speed and memory for higher compression ratios.
    space_cache=v2 creates cache in memory for greatly improved performance.

Mount the new BTRFS root subvolume with subvol=@ ...

mount -o ${sv_opts},subvol=@ /dev/mapper/cryptdev /mnt

Create mountpoints for the additional subvolumes ...

mkdir -p /mnt/{home,.snapshots,var/cache,var/lib/libvirt,var/log,var/tmp}

Mount the additional subvolumes ...

mount -o ${sv_opts},subvol=@home /dev/mapper/cryptdev /mnt/home
mount -o ${sv_opts},subvol=@snapshots /dev/mapper/cryptdev /mnt/.snapshots
mount -o ${sv_opts},subvol=@cache /dev/mapper/cryptdev /mnt/var/cache
mount -o ${sv_opts},subvol=@libvirt /dev/mapper/cryptdev /mnt/var/lib/libvirt
mount -o ${sv_opts},subvol=@log /dev/mapper/cryptdev /mnt/var/log
mount -o ${sv_opts},subvol=@tmp /dev/mapper/cryptdev /mnt/var/tmp

Links: What BTRFS subvolume mount options should I use? and btrfs-man5(5)
1.15 Mount ESP partition

mkdir /mnt/efi
mount ${disk}p1 /mnt/efi

1.16 Select package mirrors

Synchronize package databases ...

pacman -Syy

Generate a new mirror selection using reflector.

Example: Verbosely select the 5 most recently synchronized HTTPS mirrors located in either Canada or Germany, sort them by download speed, and overwrite mirrorlist ...

reflector --verbose --protocol https --latest 5 --sort rate --country Canada --country Germany --save /etc/pacman.d/mirrorlist

1.17 Install base system

Select an appropriate microcode package to load updates and security fixes from processor vendors.

View cpuinfo ...

grep vendor_id /proc/cpuinfo

Depending on the processor, set microcode for Intel ...

export microcode="intel-ucode"

For AMD ...

export microcode="amd-ucode"

Install the base system ...

pacstrap /mnt base base-devel ${microcode} btrfs-progs linux linux-firmware bash-completion cryptsetup htop man-db mlocate neovim networkmanager openssh pacman-contrib pkgfile reflector sudo terminus-font tmux

1.18 Fstab

genfstab -U -p /mnt >> /mnt/etc/fstab

1. Configure

Chroot into the base system to configure ...

arch-chroot /mnt /bin/bash

2.1 Timezone

Set desired timezone (example: America/Toronto) and update the system clock ...

ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime
hwclock --systohc

2.2 Hostname

Assign a hostname (example: foobox) ...

echo "foobox" > /etc/hostname

Add matching entries to /etc/hosts ...

cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   foobox.localdomain foobox
EOF

2.3 Locale

Set locale (example: en_CA.UTF-8) ...

export locale="en_CA.UTF-8"
sed -i "s/^#\(${locale}\)/\1/" /etc/locale.gen
echo "LANG=${locale}" > /etc/locale.conf
locale-gen

2.4 Font and keymap

Set a console font (example: terminus ter-224n) ...

echo "FONT=ter-v24n" > /etc/vconsole.conf

Set a keyboard layout choice (example: colemak) ...

echo "KEYMAP=colemak" >> /etc/vconsole.conf

2.5 Editor

Set a system-wide default editor (example: neovim) ...

echo "EDITOR=nvim" > /etc/environment && echo "VISUAL=nvim" >> /etc/environment

2.6 Root password

Assign password to root ...

passwd

2.7 Add user

Create a user account (example: foo) with superuser privileges ...

useradd -m -G wheel -s /bin/bash foo
passwd foo

Activate wheel group access for sudo ...

sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers

2.8 NetworkManager

Enable NetworkManager to start at boot ...

systemctl enable NetworkManager

Wired network connection is activated by default. Run nmtui in the console and choose Activate a connection to setup a wireless connection.
2.9 SSH

Enable sshd server ...

systemctl enable sshd.service

After the install is complete and system has rebooted, secure remote access using SSH keys.
2.10 Keyfile

Keeping /boot on the encrypted partition results in being prompted twice for the LUKS passphrase: first instance, for GRUB to unlock and access /boot in the early stage of the boot process; second instance, to unlock the root filesystem itself as implemented in the initramfs.

To unlock system at boot by entering the passphrase a single time:

    Create a keyfile that will be embedded in the initramfs
    Add keyfile and encrypt hook to configure initramfs to auto-unlock encrypted root

Create keyfile crypto_keyfile.bin and restrict access to root ...

dd bs=512 count=4 iflag=fullblock if=/dev/random of=/crypto_keyfile.bin
chmod 600 /crypto_keyfile.bin

Add this keyfile to LUKS ...

cryptsetup luksAddKey ${disk}p2 /crypto_keyfile.bin

Initramfs generated by mkinitcpio uses permission 600 by default, so regular users are not able to read the keyfile.

In the next step, include keyfile in the FILES array and encrypt in HOOKS inside mkinitcpio.conf.
2.11 Mkinitcpio

Set necessary FILES and MODULES and HOOKS in /etc/mkinitcpio.conf:

FILES

Add the keyfile ...

FILES=(/crypto_keyfile.bin)

MODULES

Add btrfs support to mount the root filesystem ...

MODULES=(btrfs)

HOOKS

Set hooks ...

HOOKS=(base udev keyboard autodetect keymap consolefont modconf block encrypt filesystems fsck)

Order of the hooks matters:

    base sets up all initial directories and installs base utilities and libraries.
    udev starts the udev daemon and processes uevents from the kernel; creating device nodes.
    keyboard should be placed before autodetect to include all keyboard drivers in initramfs. Systems that boot with different hardware configurations (example: laptops used both with USB external and built-in keyboards) require this at boot to unlock the encrypted device.
    keymap and consolefont loads the specified keymap and font from /etc/vconsole.conf
    modconf includes modprobe configuration files.
    block adds all block device modules.
    encrypt is required to detect and unlock an encrypted root partition. This must be placed before filesystems.

Recreate the initramfs image ...

mkinitcpio -P

2.12 Boot loader: GRUB

Install ...

pacman -S grub efibootmgr

Determine the UUID of the encrypted partition ...

blkid -s UUID -o value ${disk}p2

This string of characters is used in the GRUB_CMDLINE_LINUX_DEFAULT variable.

Open /etc/default/grub for editing:

GRUB_CMDLINE_LINUX_DEFAULT

Set ...

GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet cryptdevice=UUID=UUID_OF_ENCRYPTED_PARTITION:cryptdev"

Example: If the UUID of the encrypted partition was 180901b5-151a-45e3-ba87-28f02b124666, then ...

GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet cryptdevice=UUID=180901b5-151a-45e3-ba87-28f02b124666:cryptdev"

GRUB_PRELOAD_MODULES

Include the luks module ...

GRUB_PRELOAD_MODULES="part_gpt part_msdos luks"

GRUB_ENABLE_CRYPTODISK

Uncomment to enable ...

GRUB_ENABLE_CRYPTODISK=y

2.13 Install boot loader

Install GRUB in the ESP ...

grub-install --target=x86_64-efi --efi-directory=/efi --boot-directory=/efi --bootloader-id=GRUB

Verify that a GRUB entry has been added to the UEFI bootloader by running ...

efibootmgr

Generate the GRUB configuration file ...

grub-mkconfig -o /efi/grub/grub.cfg

Verify that grub.cfg has entries for insmod cryptodisk and insmod luks by running ...

grep 'cryptodisk\|luks' /efi/grub/grub.cfg

2.14 Reboot

Exit chroot and reboot ...

exit
umount -R /mnt
reboot

GRUB boot menu appears if configured to be displayed (default).

Important: In this early stage of boot GRUB is using the us keyboard, not any alternative keymap that might be set in vconsole.conf.

GRUB prompts for the LUKS passphrase to unlock the system ...

Enter passphrase for hd0,gpt2 (uuid_long_string_of_characters):

Under normal circumstance, it can take upwards of a half-minute or more for the passphrase to be processed. This delay can be shortened by setting a lower --iter-time when running cryptsetup luksAddkey, though with a corresponding reduction in security.

Then ... Voila!

archlinux login:

3. After the install

Arch Linux is installed. Yes!

These are a few things I like to do next ...
3.1 Check for errors

Failed systemd services ...

$ systemctl --failed

High priority errors in the systemd journal ...

$ journalctl -p 3 -xb

3.2 Sudo

Allow a user (example: foo) to execute superuser commands using sudo without being prompted for a password.

Create the file /etc/sudoers.d/sudoer_foo with ...

echo "foo ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudoer_foo

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
