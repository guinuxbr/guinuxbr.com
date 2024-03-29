---
title: "LOAD SSH KEYS VIA KDE PLASMA KWALLET"
subtitle: "Automatically add SSH keys after login"
date: 2022-07-03T14:12:33+01:00
lastmod: 2024-02-07T22:35:00+00:00
draft: false
tags: ["Linux", "KDE", "openSUSE"]
categories: ["tutorials"]
align: left
featuredImage: banner.en.png
---

This quick tip was tested on openSUSE Tumbleweed. However, it will probably work for other Linux distributions running KDE Plasma.

## Install ksshaskpass5

Using Zypper, install `ksshaskpass5`

```shell
sudo zypper in --details ksshaskpass5
```

## Create the configuration files

Create the `.desktop` file that will be automatically parsed at KDE Plasma start-up. Add all the needed keys using `ssh-add -q`. The "q" here stands for quiet.

```shell
vim ~/.config/autostart/ssh-add.desktop
```

```shell
[Desktop Entry]
Exec=ssh-add -q /home/user_name/.ssh/key1 /home/user_name/.ssh/key2 < /dev/null
Icon=dialog-scripts
Name=ssh-add.sh
Type=Application
X-KDE-AutostartScript=true
```

For the `Exec` command, I've used the `/home/user_name/` path because `~` or `$HOME` did not work as expected.

Create another script in `~/.config/plasma-workspace/env/` to set the environment variable `SSH_ASKPASS` to use **ksshaskpass**.

```shell
vim ~/.config/plasma-workspace/env/ksshaskpass.sh
```

```shell
#!/bin/sh
export SSH_ASKPASS='/usr/libexec/ssh/ksshaskpass'
[ -n "$SSH_AGENT_PID" ] || eval "$(ssh-agent -s)"
```

## Reboot to test

Now reboot the machine. In the next login, a dialogue window asking for your SSH key password will appear for each added key.  
Ensure to mark the option "Remember password".  

![ksshaskpass](./ksshaskpass.png)
