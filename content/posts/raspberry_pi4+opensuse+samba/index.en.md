---
title: "Raspberry Pi4 + openSUSE + Samba"
subtitle: "Sharing files within your LAN"
date: 2022-03-04T23:00:11Z
draft: false
tags: ["Linux", "Raspberry Pi", "openSUSE", "ARM", "Samba"]
categories: ["tutorials"]
align: left
---

## Introduction

Hello, in this article, I'll explain how to install openSUSE Tumbleweed (however, these instructions would probably work in openSUSE Leap) in Raspberry Pi 4, plus install and configure a basic Samba server to share files from an external HDD.

The first thing to do is install the openSUSE Tumbleweed image on your Raspberry Pi 4. Go to the [openSUSE Wiki page for Raspberry Pi 4](https://en.opensuse.org/HCL:Raspberry_Pi4) and download the image that you like to use.

There are six images available. Download the image you want (Leap is stable, and Tumbleweed is rolling) from here. Choose your desktop type:

* JeOS - Just enough Operating System - a very basic system, no graphical desktop
* E20 - Enlightenment desktop
* XFCE - XFCE desktop
* KDE - KDE desktop
* LXQT - LXQT desktop
* X11 - basic X11 system

The direct links did not work for me, so I went to the [general download directory](http://download.opensuse.org/ports/aarch64/tumbleweed/appliances/) and downloaded the latest JeOS image named [openSUSE-Tumbleweed-ARM-JeOS-raspberrypi.aarch64.raw.xz](https://download.opensuse.org/ports/aarch64/tumbleweed/appliances/openSUSE-Tumbleweed-ARM-JeOS-raspberrypi.aarch64.raw.xz)

## Preparing the media

As **root** extract the image onto your SD card or USB device(replace sdX with the device name of your SD card).

If possible, it is better to use a decent USB 3 device as the read and write speeds are greater than SD cards. I'll use the USB device as the media used to install the image from now on.

{{< admonition type=warning title="WARNING" open=true >}}
This is a destructive operation. All existing data on the device will be lost. Check first if the device you have selected is your target device!
{{< /admonition >}}

```shell
xzcat openSUSE-Tumbleweed-ARM-JeOS-raspberrypi.aarch64.raw.xz | dd bs=4M of=/dev/sdX iflag=fullblock oflag=direct status=progress; sync
```

After the image is extracted to the USB device, you can insert it into your Raspberry Pi 4 and turn it on.

You will need to discover the IP address of your Raspberry Pi 4. This can be done in a hundred different ways. For example, you can look at your router DHCP table for a MAC address that belongs to "Raspberry Pi Trading Ltd".

## Logging into the system

Wait 5 minutes before the first login as the OS will perform some tasks at the first boot, like resizing the ext4 filesystem to the entire disk.

SSH is enabled by default in openSUSE images so that you can log in as root with:

```shell
ssh root@raspberry_pi_ip_address
```

The default password is "linux".

## Configuring the system

Find your keyboard layout and load it. To search your keyboard, type:

```shell
localectl list-keymaps
```

In my case, I use a Brazilian keyboard layout called "br-abnt2". Load your keyboard layout with:

```shell
loadkeys br-abnt2
```

For security reasons, change the default **root** password.

```shell
passwd
```

Type once and then confirm your new password.

Check for available system updates.

```shell
zypper dup --details
```

Install `vim` and `vim-data` to have a better editing experience. You can use the editor that you prefer.

```shell
zypper in --details --no-recommends vim vim-data
```

Change the hostname as you like.

```shell
hostnamectl hostname your_hostname
```

Create your user account.

```shell
useradd -m -s $(which bash) your_username
```

Configure the **sudo** commands allowed for your account.

```shell
visudo -f /etc/sudoers.d/your_username
```

Add `your_username ALL=(ALL) ALL` to the file and save it.

As the server administrator, I'll give my user account the right to run all commands as root.

Now configure sudo to ask for your password instead of the root password.

```shell
visudo
```

Comment out the following lines:

```shell
Defaults targetpw   # ask for the password of the target user i.e. root
ALL   ALL=(ALL) ALL   # WARNING! Only use this together with 'Defaults targetpw'!
```

Check if is everything correct with your sudo-related files.

```shell
visudo -c
```

If there is some problem, you can fix it by editing the file.

Set a password for your user account.

```shell
passwd your_username
```

Reboot the system to be able to SSH with your user account instead of the root account.

```shell
systemctl reboot
```

Log in with your user account.

```shell
ssh your_username@raspberry_pi_ip_address
```

## Dealing with the external HDD

Now we will mount the external HDD to `/mnt/external-hdd/`.  

First, we discover the UUID for the external HDD.

```shell
lsblk --fs --output UUID,TYPE,FSTYPE,LABEL,MOUNTPOINT
```

```shell
UUID                                 TYPE FSTYPE LABEL            MOUNTPOINT
                                     disk                         
30e471a2-263e-48c2-9d57-d32445b7038a part ext4   external-hdd      
                                     disk                         
8511-418f                            part vfat   EFI              /boot/efi
d1ed4b63-3e1a-4aa6-9e26-1e19fe9a77b0 part swap   SWAP             
fd388969-253a-4709-8e23-5243f0eeb33d part ext4   ROOT             /
                                     disk                         [SWAP]                                     
```

Create the mount point.

```shell
mkdir -p /mnt/external-hdd
```

Edit the `/etc/fstab` file and add the line for the external HDD.
Observe that in this case, the external HDD is formatted as ext4. Adjust according to your needs.

```shell
# System mount point
UUID=fd388969-253a-4709-8e23-5243f0eeb33d / ext4 noatime,nobarrier 0 1
# EFI partition mount point
UUID=1845-7210 /boot/efi vfat defaults 0 0
# External HDD mount point
UUID=30e471a2-263e-48c2-9d57-d32445b7038a /mnt/external-hdd ext4 noatime,nobarrier 0 2
```

Test the mount point.

```shell
mount -a
```

If everything worked correctly, you should see no output.

## Configuring the Samba Server

Now you can install the Samba server.

```shell
sudo zypper in --details --no-recommends samba samba-doc
```

Back up the original Samba configuration file.

```shell
sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.bkp
```

To better understand the options, copy a fully commented example file from the Samba documentation.

```shell
sudo cp /usr/share/doc/packages/samba/examples/smb.conf.default /etc/samba/smb.conf
```

In this article, other than users, I'll use a group to control access to the shared folders.

Add a group called `smbusers` or whatever you like.

```shell
sudo groupadd smbusers
```

Create a Samba password for the user that will have access to the shares. This password can be different from the user account password.

```shell
sudo smbpasswd -a your_username
```

Edit the Samba configuration file. For simplicity, I'll omit some comments, but I strongly recommend reading the Samba documentation to properly understand the options.

```shell
sudo vim /etc/samba/smb.conf
```

Some considerations:

* All shares will require the Samba password.
* I'll use `your_username` to illustrate a real user; replace it with a proper user name.

```shell
# Global Settings
[global]

# workgroup = NT-Domain-Name or Workgroup-Name, eg: MIDEARTH
    workgroup = YOUR_WORKGROUP_NAME 

# server string is the equivalent of the NT Description field
    server string = Some string to identify your server

# Server role. 
    server role = standalone server

# Restrict access to your LAN network, and the "loopback" interface
    hosts allow = 192.168.0. 127.

# Use a separate log file for each machine that connects
    log file = /var/log/samba/log.%m

# Put a capping on the size of the log files (in Kb).
    max log size = 50

# Backend to store user information.
   passdb backend = tdbsam

# DNS Proxy - tells Samba whether or not to try to resolve NetBIOS names via DNS nslookups. The default is NO.
   dns proxy = no 

# This one is useful for people to share files
[tmp]
    comment = Temporary file space
    path = /mnt/external-hdd/tmp
    read only = no
    public = yes
    browsable = yes
    writable = yes

# A private directory, usable only by your_username. Note that your_username requires write access to the directory.
[username]
    comment = Private stuff for your_username
    path = /mnt/external-hdd/your_username
    valid users = your_username
    public = no
    writable = yes
    printable = no
    create mask = 0700
    directory mask = 0700

# Custom shares

# A share for pictures, accessible only by members of the group "smbusers"
[pictures]
    comment = Pictures
    path = /mnt/external-hdd/pictures
    public = no
    browsable = yes
    writable = yes
    valid users = @smbusers
```

Test the Samba configuration file.

```shell
testparm
```

## Configuring the firewall

This final part enables the Firewall and allows the Samba ports through it.

```shell
sudo systemctl enable --now firewalld.service
```

In this case, we are using the "home" firewall zone and the interface "eth0".

```shell
sudo firewall-cmd --set-default-zone=home  
sudo firewall-cmd --zone=home --change-interface=eth0
```

Allow the Samba service through the Firewall.

```shell
sudo firewall-cmd --zone=home --permanent --add-service=samba
```

Reload the firewall configuration.

```shell
sudo firewall-cmd --reload
```

Enable and start the `smb` and `nmb` services.

```shell
sudo systemctl enable --now smb.service
sudo systemctl enable --now nmb.service
```

## Rebooting and testing

Reboot your Raspberry Pi, and you should have a working Samba server sharing your external HDD.

```shell
sudo systemctl reboot
```
