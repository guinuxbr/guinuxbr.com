---
title: "Backup dotfiles to GitHub"
subtitle: "Or any other version control system"
date: 2021-12-29T13:18:49Z
draft: false
tags: ["Linux", "Git", "GitHub"]
categories: ["tutorials", "tips"]
align: left
---

This article is about how to back up dotfiles using Git. I will try to keep it short and straightforward.

I'm using `Zsh` as the shell in the examples, but another shell can be used. The commands below should be executed as a normal user in the `/home` directory.

Create a local Git repository that will be used to track the dotfiles.

```shell
git init $HOME/.dotfiles
```

The default behaviour of Git commands is to run inside the project folder using information stored at the `<project>/.git` directory and Git assumes that the working tree is located at `<project>`. To enable the execution of Git commands specifically for the "dotfiles" repository from anywhere, it is needed to create an alias that indicates the location of the Git directory and the working tree.

```shell
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME'
```

Make this alias permanent.

```shell
echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME'" >> $HOME/.zsh/aliases
```

Source the `aliases` file inside the `.zshrc` file by adding the following line.

```shell
source $HOME/.zsh/aliases
```

By default, Git will consider all the files under the working tree as untracked. To avoid this behaviour, configure Git to show only the files that are explicitly added.

```shell
dotfiles config --local status.showUntrackedFiles no
```

Add the files that you want to track, for example.

```shell
dotfiles add .vimrc .zshrc .gitignore
```

Link the local to the remote repository. The remote repository can be a GitHub or any other Git repository.

```shell
dotfiles remote add origin <remote-url>
```

Push the changes to the remote repository. This is effectively the backup of the dotfiles.

```shell
dotfiles push -u origin main
```

Now the dotfiles are backed up to the remote repository.
