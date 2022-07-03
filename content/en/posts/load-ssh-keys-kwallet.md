---
title: "Load SSH keys via Kwallet"
subtitle: "Automatically add SSH keys after log in"
date: 2022-07-03T14:12:33+01:00
draft: false
tags: ["linux", "kde", "opensuse"]
categories: ["tutorials"]
align: left
---

This quick tip was tested on openSUSE Tumbleweed. However, it will probably work for other Linux distributions running KDE Plasma.

Install `ksshaskpass5` via Zypper.
> sudo zypper in \-\-details ksshaskpass5

Create the script that will run `ssh-add`.
> vim ~/bin/startup-scripts/ssh-add.sh  

Add all the needed keys using `ssh-add -q`. The "q" here stands for quiet.

```bash
#!/bin/sh
ssh-add -q $HOME/.ssh/key1 $HOME/.ssh/key2 < /dev/null
```

Give execution permission to the script.
> chmod +x ~/bin/startup-scripts/ssh-add.sh

Create the `.desktop` file that will be automatically parsed at KDE Plasma start-up.
> vim .config/autostart/ssh-add.desktop

```bash
[Desktop Entry]
Exec=/home/your_user_name/bin/startup-scripts/ssh-add.sh
Icon=dialog-scripts
Name=ssh-add.sh
Type=Application
X-KDE-AutostartScript=true
```

Create another script in `~/.config/plasma-workspace/env/` to set the environment variable `SSH_ASKPASS` to use **ksshaskpass**.
> vim ~/.config/plasma-workspace/env/ksshaskpass.sh

```bash
#!/bin/sh
export SSH_ASKPASS='/usr/libexec/ssh/ksshaskpass'
```

In the next login, a dialogue window asking for your SSH key password will appear for each added key. Ensure to mark the option "Remember password".
![ksshaskpass](/img/load-ssh-keys-kwallet/ksshaskpass.png)