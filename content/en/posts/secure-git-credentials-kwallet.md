---
title: "Secure GitHub credentials with KWallet"
subtitle: "Konsole + GitHub + KWallet"
date: 2020-08-21T15:15:00-03:00
draft: false
tags: ["linux", "kde", "opensuse"]
categories: ["tutorials", "tips"]
align: left
---

Hi and welcome to my blog!

KWallet is a KDE Plasma tool to safely store any kind of credentials and secrets. It has an interface called KWallet Manager that allows to easily manage this credentials and secrets.

![kwallet](/img/secure-github-credentials-kwallet/kwallet.png)

In this quick tutorial, I'll show how to configure your KDE to store your GitHub credentials in KWallet. This guide was tested against [openSUSE Tumbleweed](https://www.opensuse.org/) but should work for the most of Linux distributions.

First, make sure to have _ksshaskpass_ installed. _ksshaskpass_ is an ssh-add helper that uses _kwallet_ and _kpassworddialog_ to show a window where you should type your credentials.

Now, create an autostart script file and mark it as executable:

>touch ~/.config/plasma-workspace/env/askpass.sh

Open it for edition.

>nano ~/.config/plasma-workspace/env/askpass.sh

Put the following content in the file:

```bash
#!/bin/sh
export GIT_ASKPASS='/usr/lib/ssh/ksshaskpass'
```

Save and exit. Now make it executable.

>chmod +x ~/.config/plasma-workspace/env/askpass.sh

Next time you log in, open Konsole and try to clone some of your private GitHub repositories.
If your wallet is already open and you will see the _ksshaskpass_ dialogue asking for your user name and then asking for your password. Just make sure to mark "Remember password" in both dialogues to save your credentials safely in your wallet.

![ksshaskpass](/img/secure-github-credentials-kwallet/ksshaskpass.png)