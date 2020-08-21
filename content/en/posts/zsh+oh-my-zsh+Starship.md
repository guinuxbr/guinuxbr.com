---
title: "Installing Zsh + Oh-My-Zsh + Starship"
subtitle: "Increasing productivity"
date: 2020-04-03T20:59:05-03:00
draft: false
tags: ["linux","shell", "bash", "zsh"]
categories: ["tutorials", "productivity"]
align: left
---

Hi, welcome to my blog!  

The objective of this article is to share my shell setup with you.
I think that my job and day to day tasks became easier and more productive than using the "normal" _bash_. I hope that it helps you.  

You will need the following tools:  

[Zsh](http://zsh.sourceforge.net/) - The Z shell.  
[Oh-My-Zsh](https://ohmyz.sh/) - A framework for managing your Zsh configuration.  
[Starship](https://starship.rs/) - A fast and customizable prompt for any shell!  

I assume that you already have _git_ installed and have a little knowledge of using it to clone repositories.

## Installing Zsh

First, you need to install Zsh. You can use your distribution package manager to install it easily.

For openSUSE:  
>sudo zypper install zsh  

For Ubuntu:  
>sudo apt install zsh  

For Fedora:  
>sudo dnf install zsh

After this you should set Zsh as your default shell:

>chsh -s $(which zsh)

Now reboot your machine.

## Installing Oh-My-Zsh

After rebooting, open your terminal and you should now be prompted by a Zsh configuration wizard. At this time you can just type **q** and **ENTER** because you will install and configure Oh-My-Zsh and it will install a _.zshrc_ template for us:  

* curl or wget should be installed.  
* git should be installed.

>sh -c "$(wget -O- <https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh>)"

If Oh-My-Zsh was successfully installed, you should see that your prompt changes to a green one. The template configuration file is _~/.zshrc_ and it gives you tons of possibilities to configure your shell behavior, like prompt themes and plugins.

## Loading some plugins

There is a lot of configurations that can be made in Zsh + Oh-My-Zsh, here I'll just talk about a list of cool plugins that I use, but you can dive deeper to discover more possibilities.
Plugins should be placed in ```plugins=(...)``` session of the configuration file. I use the following:

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

The last two plugins of my list aren't part of the default Oh-My-Zsh installation and should be installed separately. Maybe you can install it with your distribution package manager, but I do prefer to install via Github to take advantage of possible new features.

As you are using Oh-My-Zsh as a plugin manager, and the plugins are already enabled in our _.zshrc_ file, all you have to do is clone the project repository to our _$ZSH_CUSTOM_ directory.
Just type the following commands.
For _zsh-autosuggestions_:
>git clone <https://github.com/zsh-users/zsh-autosuggestions> ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

And for zsh-syntax-highlighting:
>git clone <https://github.com/zsh-users/zsh-syntax-highlighting.git> ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

## Installing a better font

For better support icons and symbols, you have to install a modern font like Nerd Fonts. I use the Meslo, but you can choose your own and test it.

* [Meslo Nerd Fonts](<https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip>)

Now you have to configure your terminal emulator to use Meslo Nerd Fonts.

## Theming the prompt with Starship

To finish the task, the last step is to install Starship that will bring a lot of goodies to our Zsh shell.
The installation is very simple, just type:

* curl should be installed.

>curl -fsSL <https://starship.rs/install.sh> | zsh

Once installed, you have to enable it. Just place the following line at the end _~/.zshrc_
>eval "$(starship init zsh)"  

It is a good idea to comment out the _ZSH\_THEME_ entry in _~/.zshrc_  

## Configuring Starship

The configuration of Starship is easy to understand. First, you need to create de _starship.toml_ file. It should be placed inside _~/.config_:
>mkdir -p ~/.config && touch ~/.config/starship.toml

After this, you have to fill the file with the options that you wish to change the default setup. By the way, the default setup is quite cool! As the configuration is a _.toml_ file, all the options are of the type _key : value_, pretty intuitive.

The detailed information about every option is well described at the [official documentation](https://starship.rs/config/). However, I paste the one that I'm using to serve as a reference for you.

```toml
add_newline = true

prompt_order = [
    "username",
    "memory_usage",
    "hostname",
    "kubernetes",
    "directory",
    "git_branch",
    "git_commit",
    "git_state",
    "git_status",
    "hg_branch",
    "package",
    "dotnet",
    "elixir",
    "elm",
    "golang",
    "haskell",
    "java",
    "nodejs",
    "php",
    "python",
    "ruby",
    "rust",
    "terraform",
    "nix_shell",
    "conda",
    "aws",
    "env_var",
    "crystal",
    "line_break",
    "battery",
    "cmd_duration",
    "jobs",
    "time",
    "character",
]

[battery]
full_symbol = "🔋"
charging_symbol = "⚡️"
discharging_symbol = "💀"

[[battery.display]]
threshold = 10
style = "bold red"

[[battery.display]]
threshold = 60
style = "bold yellow"

[[battery.display]]
threshold = 100
style = "bold green"

[character]
# symbol = "➜"
error_symbol = "✗"
use_symbol_for_status = true

[cmd_duration]
min_time = 500
prefix = "tooks "

[directory]
truncation_length = 6
truncate_to_repo = true
prefix = "in "
style = "bold cyan"
disabled = false

# [env_var]
# variable = "SHELL"
# default = "Zsh"
# prefix = "<"
# suffix = ">"

[git_branch]
# symbol = "🌱 "
truncation_length = 8
truncation_symbol = "..."
style = "bold purple"
disabled = false

[git_state]
cherry_pick = "CHERRY PICKING"
rebase = "REBASING"
merge = "MERGING"
revert = "REVERTING"
bisect = "BISECTING"
am = "AM"
am_or_rebase = "AM/REBASE"
progress_divider = " of "
style = "bold yellow"
disabled = false

# [git_status]
# conflicted = "🏳"
# ahead = "🏎💨"
# behind = "😰"
# diverged = "😵"
# untracked = "🤷‍"
# stashed = "📦"
# modified = "📝"
# staged.value = "++"
# staged.style = "green"
# staged_count.enabled = true
# staged_count.style = "green"
# renamed = "👅"
# deleted = "🗑"

# [[git_status.count]]
# enabled = true

[hostname]
ssh_only = false
prefix = "🤖"
# suffix = "⟫"
trim_at = "."
disabled = false

# [jobs]
# symbol = "+ "
# threshold = 1

[line_break]
disabled = false

# [memory_usage]
# disabled = false
# show_percentage = true
# show_swap = false
# threshold = -1
# symbol = " "
# separator = "/"
# style = "bold dimmed white"

[nodejs]
symbol = "⬢ "
style = "bold green"
disabled = false

# [package]
# symbol = "📦 "
# style = "bold red"
# disabled = false

[python]
symbol = "🐍 "
pyenv_version_name = false
pyenv_prefix = "pyenv"
style = "bold yellow"
disabled = false

# [time]
# format = "🕙%T"
# style_root = "bold red"
# style_user = "bold yellow"
# show_always = true
# disabled = false

[username]
style_root = "bold red"
style_user = "bold yellow"
show_always = false
disabled = false
```

Close and reopen your terminal to see the results. Cool! Isn't it?!

That's it! I hope this article can be useful. Thanks for reading!
