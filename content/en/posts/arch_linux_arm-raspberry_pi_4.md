---
title: "Arch linux ARM on Raspberry Pi 4"
subtitle: "Keeping the things simple!"
date: 2020-05-08T22:54:24-03:00
draft: false
tags: ["linux", "raspberrypi", "arm", "archlinux"]
categories: ["tutorials"]
align: justify
---

Hello, welcome to my blog!

In this article, I will show you how to run Arch Linux ARM on the Raspberry Pi 4.

I think everyone already knows the Raspberry Pi, but if you haven't heard about it, [click here](https://www.raspberrypi.org/).

Now that you know what it is about, let's get down to business.
It is worth mentioning that a good part of this guide is found in the instructions on the project's own page, available [here](https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4).

The first thing to do is to format your MicroSD card. I recommend a good Class 10 card or better.

The choice of the partitioning tool is up to you. I will use _fdisk_ which is available by default on most Linux distributions.

1. First, we start microSD with fdisk. You need to use _sudo_ or perform the process as _root_.
    >fdisk / dev / sdX

Replace "X" with your MicroSD identifier.

2. At the first prompt, delete (!!!) the partitions and create a new one:

* Press **o** and **ENTER**. This will clear the current partitions.

* Press **p** to list the partitions. There should be none listed.

* Press **n** and **ENTER** for a new partition and **p** to choose the "Primary" type. Now **1** for the first partition and **ENTER** to accept the default value for the first sector. Now type **+ 100M** for the last sector.

* Press **t** and then **c** to configure the first partition with type **W95 FAT32 (LBA)**

* Now press **n** for a new partition and **p** again for "Primary". Then **2** for the second partition on the card and press **ENTER** twice to accept the default values ​​for the first and last sectors of the second partition.

* Press **w** to write the partition table and exit.

This way you guarantee the rest of the card to the system. We will talk about this later.

3. Create and mount the FAT file system that will be filled by the _boot_ files:
    >mkfs.vfat / dev / sdX1
    >mkdir boot
    >mount / dev / sdX1 boot

4. Create and mount the EXT4 file system that will be filled by the system files:
    >mkfs.ext4 / dev / sdX2
    >mkdir root
    >mount / dev / sdX2 root

5. Download and extract the root filesystem. The parameters of the _bsdtar_ command are: **x** to extract, **p** to restore permissions, and **f** indicates the input file. The *C* after the input file indicates the directory to which we must change before extracting the files, in this case, the _root_ directory we have created.
This part MUST be done as the root user:
    >wget <http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-4-latest.tar.gz>
    >bsdtar -xpf ArchLinuxARM-rpi-4-latest.tar.gz -C root
    >sync

Here's a tip: the URL reported in the documentation had an error the day I tried to download it. I went straight to the mirror in Brazil and found it was out of date, took advantage, and reported on IRC # archlinux-arm. I managed to download the latest version using the Danish mirror directly. A list of mirrors is available at <https://archlinuxarm.org/about/mirrors>

6. Move the boot files to the first partition:
    >mv root/boot/* boot

7. Unmount the two partitions:
    >umount boot root

8. Insert the card into the Raspberry Pi, connect the ethernet cable and the power supply.

9. If you do not use the Raspberry Pi connected directly to a video, keyboard, and mouse, you can connect via SSH. Check the IP assigned by your router's DHCP, for example.
    * Log in with the standard user _alarm_ and password _alarm_.
    * The default root password is _root_.

10. Last, but not least: Start the Pacman keychain and populate it with the Arch Linux ARM keys.
    >pacman-key -\- init
    >pacman-key -\- populate archlinuxarm

Ready, Arch Linux ARM is ready to be used for the project you want. I recommend updating the system and restarting to start the game.

> pacman -Syu
> systemctl reboot

In the next posts, we will talk more about configurations and the use of the system. See you.
