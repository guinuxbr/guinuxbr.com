---
title: "Run Debian in Windows 10 with WSL 2"
subtitle: "Useful and cool"
date: 2020-07-24T21:15:00-03:00
draft: false
tags: ["Linux", "WSL", "WSL2", "Windows"]
categories: ["tutorials"]
align: left
featuredImage: wsl2.png
---

Hello and welcome to my blog.

We use Windows in our workstations at my current job (it was not my choice 🙊), but there are a lot of tasks that are easier to do in a Linux environment. Some days ago I needed to manipulate a huge CSV and just thought: "This would be a lot simple with cat, grep, sort, etc.".

So, I remember that I have read something about running Linux inside Windows using WSL and, well, why not give it a try?

## Setting up the environment

Some considerations:

* WSL 2 is only available in Windows 10, Version 2004, Build 19041 or higher. Check your Windows version by selecting the Windows logo key + R, typing `winver`, and click OK.
* All Windows commands should be typed in a PowerShell session with administrative privileges unless otherwise specified (right-click on the PowerShell icon and choose "Run as administrator").

Here we go! Since I'm a command-line lover and do not have a Microsoft account to access Microsoft Store, I'll do this from there as much as possible. First, let's install a decent terminal emulator, Microsoft is doing a good job with [Windows Terminal](https://github.com/microsoft/terminal). I have downloaded v1.1.2021.0 and renamed it to **WindowsTerminal.msixbundle**. This is the latest version at the time of writing. The installation is pretty straightforward, just open a PowerShell instance, navigate to the directory where the executable was downloaded and type:

```powershell
.\WindowsTerminal.msixbundle
```

Now, click on Instal and wait a few seconds for the windows of Windows Terminal to show up. Close this window, for now, we need to open it as Administrator soon.

The next step is to enable WSL. Use the same method stated at the top of the article to launch an instance of Windows Terminal with administrative privileges (damn, I wish that there was a "`sudo`" for this. Maybe Microsoft can launch an "`addo`" 🙃). Observe that should have a "PS" before your prompt, this indicates that you are in a PowerShell session. Now type:

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```

The 'Virtual Machine Platform' is needed to run WSL 2. To enable it, just type:

```powershell
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

You should see "_The operation completed successfully._" for both commands. Now reboot your computer.

Once rebooted, open Windows Terminal again and set WSL2 as default:

```powershell
wsl --set-default-version
```

If you already have a distribution installed and like to convert it to use WSL2, this is possible. First, check the current status.

```powershell
wsl --list --verbose
```

The above command will show a list of installed distributions separated by NAME, STATE, and VERSION. For instance, if you have an Ubuntu installation that is running at version 1 you can type:

```powershell
wsl --set-version Ubuntu 2
```

You also can revert it to WSL 1 if you are not satisfied with the result, just change the version number.

## Download and installation

Now it is time to download the distribution that you wish to install. I chose Debian because it is very light and stable. Since Windows 10 Spring 2018 Update, `curl.exe` is present, so let's use it.

```powershell
curl.exe -L -o debian.appx https://aka.ms/wsl-debian-gnulinux
```

The installation step is also quite simple.

```powershell
Add-AppxPackage .\debian.appx
```

A strange progress bar will be displayed. Once it disappears, it is done. Now Debian should be available in your applications menu but don't click there, use the Windows Terminal to open a Debian session. On the right side of the tab, there is an arrow that hides all the possible sessions.
Clicking on Debian will lead you to the user configuration screen. Choose your username and password and you are done.

## Configuration

Now, I recommend that you update the installation:

```bash
sudo apt update && sudo apt upgrade
```

Verify the version of Debian that was installed.

```bash
cat /etc/os-release
```

For reasons unknown to me, the downloaded image was still the Stretch version of Debian. No problem, let's update it to Debian Buster. First, make a backup of your _sources.list_ file.

```bash
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
```

Now, replace every "stretch" entry with "buster". You can do this with `nano` or `vi` or directly with `sed`.

```bash
sudo sed -i 's/stretch/buster/g' /etc/apt/sources.list
```

Then update the system again.

```bash
sudo apt update && sudo apt upgrade && sudo apt full-upgrade
```

Now get rid of obsolete packages in your system.

```bash
sudo apt autoremove
```

Close the Debian tab and open another one to check if you have installed Debian Buster with success.

```bash
cat /etc/os-release
```

You should see something like the below:

```bash
PRETTY_NAME="Debian GNU/Linux 10 (buster)"
NAME="Debian GNU/Linux"
VERSION_ID="10"
VERSION="10 (buster)"
VERSION_CODENAME=buster
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
```

## Final considerations

For better file system performance, make sure to store your Linux project files in the Linux file system (not the Windows file system).
It is probable that when you open a Debian session your prompt show something like **_username@hostname:/mnt/c/Users/username$_** This is because WSL exposes the Windows file system through mount points placed in **_/mnt_** like **_/mnt/c_** and **_/mnt/d_** just type `cd ~` to go to your real home.

Not only the file system of Windows is exposed by WSL, but you can use Windows applications too, try to type `explorer.exe`. As you can see, Windows Explorer will open with the files of your current directory loaded.

That is it, everything is set up and ready to use.
