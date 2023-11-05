---
title: "Installing Zsh + Oh-My-Zsh + Starship"
subtitle: "Increasing productivity"
date: 2020-04-03T20:59:05-03:00
lastmod: 2022-03-04T22:30:00-00:00
draft: false
tags: ["Linux", "Shell", "Bash", "Zsh"]
categories: ["tutorials", "productivity"]
align: left
featuredImage: banner.en.png
---

## Introduction

{{< admonition type=info title="Update" open=true >}}
Starship configuration changed in the newer versions. This article was updated and covers version 1.3.0.
{{< /admonition >}}

Hi, welcome to my blog!  

The objective of this article is to share my shell setup with you.
I think that my job and day-to-day tasks became easier and more productive than using the "normal" _bash_. I hope that it helps you.  

You will need the following tools:  

* [Zsh](http://zsh.sourceforge.net/) - The Z shell.  
* [Oh-My-Zsh](https://ohmyz.sh/) - A framework for managing your Zsh configuration.  
* [Starship](https://starship.rs/) - A fast and customizable prompt for any shell!  

I assume that you already have Git installed and have a little knowledge of using it to clone repositories.

## Installing Zsh

First, you need to install Zsh. You can use your distribution package manager to install it easily.

For openSUSE:

```shell
sudo zypper install zsh  
```

For Ubuntu:

```shell
sudo apt install zsh  
```

For Fedora:

```shell
sudo dnf install zsh
```

After this, you should set Zsh as your default shell:

```shell
chsh -s $(which zsh)
```

Now reboot your machine.

## Installing Oh-My-Zsh

After rebooting, open your terminal and you should now be prompted by a Zsh configuration wizard. At this time you can just type **q** and **ENTER** because you will install and configure Oh-My-Zsh and it will install a '.zshrc' template for us:  

* curl or wget should be installed.  
* git should be installed.

```shell
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

If Oh-My-Zsh was successfully installed, you should see that your prompt changes to a green one. The template configuration file is `~/.zshrc and it gives you tons of possibilities to configure your shell behavior, like prompt themes and plugins.

## Loading some plugins

There are a lot of configurations that can be made in Zsh + Oh-My-Zsh, here I'll just talk about a list of cool plugins that I use, but you can dive deeper to discover more possibilities.
Plugins should be placed in the `plugins=(...)` session of the configuration file. I use the following:

| plugin name | brief description |
|:------------------|:-----------------|
| colored-man-pages | adds colors to man pages|
| command-not-found | uses the command-not-found package for Zsh to provide suggested packages |
| docker| adds auto-completion for docker |
| git | provides many aliases and a few useful functions |
| npm | provides completion as well as adding many useful aliases |
| pep8 | adds completion for pep8 |
| pip | adds completion for pip |
| pyenv | loads pyenv and pyenv-virtualenv |
| python | adds several aliases for useful python commands |
| sudo | prefix your current or previous commands with sudo by pressing esc twice |
| systemd | provides many useful aliases for systemd |
| ubuntu | This plugin adds completions and aliases for Ubuntu |
| zsh_reload | type _src_ to reload Zsh session |
| zsh-autosuggestions | suggests commands as you type based on history and completions |
| zsh-syntax-highlighting | package provides syntax highlighting |

You can always go to <https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins> to see a complete list of plugins and their respective documentation.

The last two plugins on my list aren't part of the default Oh-My-Zsh installation and should be installed separately. Maybe you can install it with your distribution package manager, but I do prefer to install it via Github to take advantage of possible new features.

As you are using Oh-My-Zsh as a plugin manager, and the plugins are already enabled in our _.zshrc_ file, all you have to do is clone the project repository to our _$ZSH_CUSTOM_ directory.
Just type the following commands.
For `zsh-autosuggestions`:

```shell
git clone <https://github.com/zsh-users/zsh-autosuggestions> ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

And for `zsh-syntax-highlighting`:

```shell
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

## Installing a better font

For better support icons and symbols, you have to install a modern font like Nerd Fonts. I use the Meslo, but you can choose your own and test it.

* [Meslo Nerd Fonts](https://github.com/ryanoasis/nerd-fonts/releases/)

Now you have to configure your terminal emulator to use Meslo Nerd Fonts.

## Theming the prompt with Starship

To finish the task, the last step is to install Starship which will bring a lot of goodies to our Zsh shell.
The installation is very simple, just type:

* `curl` should be installed.

```shell
curl -fsSL https://starship.rs/install.sh | zsh
```

Once installed, you have to enable it. Just place the following line at the end _~/.zshrc_

```shell
eval "$(starship init zsh)"  
```

It is a good idea to comment out the `ZSH_THEME` entry in `~/.zshrc`.

## Configuring Starship

The configuration of Starship is easy to understand. First, you need to create the `starship.toml` file. It should be placed inside `~/.config`:

```shell
mkdir -p ~/.config && touch ~/.config/starship.toml
```

After this, you have to fill the file with the options that you wish to change the default setup. By the way, the default setup is quite cool! As the configuration is a `.toml` file, all the options are of the type `key : value`, pretty intuitive.

Detailed information about every option is well described in the [official documentation](https://starship.rs/config/). However, I paste the one that I'm using to serve as a reference for you.

```toml
# Inserts a blank line between shell prompts
add_newline = true

# Customizing the prompt
format = """
$username\
$hostname\
$shlvl\
$singularity\
$kubernetes\
$directory\
$vcsh\
$git_branch\
$git_commit\
$git_state\
$git_metrics\
$git_status\
$hg_branch\
$docker_context\
$package\
$cmake\
$cobol\
$dart\
$deno\
$dotnet\
$elixir\
$elm\
$erlang\
$golang\
$helm\
$java\
$julia\
$kotlin\
$lua\
$nim\
$nodejs\
$ocaml\
$perl\
$php\
$pulumi\
$purescript\
$python\
$rlang\
$red\
$ruby\
$rust\
$scala\
$swift\
$terraform\
$vlang\
$vagrant\
$zig\
$nix_shell\
$conda\
$memory_usage\
$aws\
$gcloud\
$openstack\
$azure\
$env_var\
$crystal\
$custom\
$sudo\
$cmd_duration\
$line_break\
$jobs\
$battery\
$time\
$status\
$shell\
[$character](bold green)"""

# Configure if and how the time is shown
[time]
disabled = false
time_format = "%T"
format = "🕛[$time ](bold blue)"

[sudo]
disabled = false
style = "bold green"
symbol = "💪"
format = "[<SUDO>$symbol]($style)"

[status]
disabled = false
style = "bg:blue"
symbol = "🔴"
map_symbol = true
format = "[[$symbol $common_meaning$signal_name$maybe_int]]($style) "

[hostname]
ssh_only = false
ssh_symbol = " 🔒🐚"
format = "[$ssh_symbol](bold blue) on [$hostname](bold green) "
#trim_at = ".companyname.com"
disabled = false

[memory_usage]
disabled = false
threshold = -1
symbol = "🧠"
format = "$symbol [${ram}( | ${swap})]($style) "
style = "bold dimmed green"

[username]
style_user = "white bold"
style_root = "black bold"
format = "[$user]($style)"
disabled = false
show_always = true
```

Close and reopen your terminal to see the results. Cool! Isn't it

That's it! I hope this article can be useful. Thanks for reading!
