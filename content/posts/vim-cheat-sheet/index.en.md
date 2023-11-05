---
title: "Vim Cheat Sheet"
subtitle: "Sooner or later you will need it"
date: 2020-12-25T19:22:19Z
draft: false
tags: ["Linux", "Vim"]
categories: ["tutorials", "tips"]
align: left
featuredImage: banner.en.png
---

## Introduction

For a long time, I ran away from Vim because it seemed very tricky and because there is a lot of simpler editors out there to work with. However, as it comes installed in most Linux distributions, I made this cheat sheet to help me understand how things work. I have discovered that is possible to be very productive with Vim 😃.

I'll try to go straight to the point. This cheat sheet is not intended to be a complete guide but it helps to get started.

Vim has different operation modes, and I will not cover all of them in this cheat sheet. I'll stick with the basic functionality needed to open, edit and save a file.

Let's begin! To open a file with Vim just type `vim filename`.  
`ESC` = enter "command mode"

## Move the cursor

You can use the arrow keys to move the cursor around. There is also special keys to do this:

* `h` = Move one character left  
* `j` = Move one row down
* `k` = Move one row up
* `l` = Move one character right

## Edition Mode  

The following keys have to be typed in "Command Mode".

* `i` = Insert text in the cursor position
* `I` = Insert text at the beginning of the line
* `o` = Insert text in the next line
* `O` = Insert text in the previous line
* `a` = Insert a character after the current
* `A` = Insert text at the end of the line
* `r` = Replace the character at the current cursor position
* `R` = Enter replace mode to replace characters from the current cursor position
* `u` = Undo the last action
* `CTRL + r` = redo

## Saving & Exiting

The following keys have to be typed in "Command Mode".

* `:w` = Save
* `:q` = Exit
* `:q!` = Force exit (exit without saving)
* `:qa` = Exit from all opened files
* `:wq` = Save and exit
* `:x` = Save and exit
* `ZZ` = Save and exit
* `ZQ` = Force exit (exit without saving)

## Copy, paste & cut

The following keys have to be typed in "Command Mode".

* `yy` = Copy line
* `p` = Paste content to the below line
* `P` = Paste content to the above line
* `yNy` = Copy N lines
* `cw` = Cut the word starting from the current cursor position
* `dd` = Cut or delete a line
* `D` = Delete the line starting from the current cursor position
* `dG` = Delete the lines starting from the current cursor position to the end of the file
* `dGG` = Delete the lines starting from the current cursor position to the beginning of the file
* `dw` = Delete the word starting from the current cursor position
* `dNd` = Cut or delete N lines
* `x` = Delete a character at the current cursor position (similar to "D" key behaviour)
* `X` = Delete a character before the current cursor position (similar to "backspace" key behaviour)
* `yw` = Copy the word starting from the current cursor position

## Visual Mode

The following keys have to be typed in "Command Mode".

* `v` = Visual mode that allows selecting a text fragment
* `V` = Visual mode that allows selecting an entire line
* `CTRL+v` = Visual block that allows selecting a block of text

## Navigation

The following keys have to be typed in "Command Mode".

* `/pattern` = Search forward for a patter
* `?pattern` = Search backward for a pattern
* `n` = Pattern forward search
* `N` = Pattern backward search
* `gg` = Goes to the first line of the file
* `G` = Goes to the last line of the file
* `H` = Goes to the top of the current screen
* `M` = Goes to the middle of the current screen
* `L` = Goes to the end of the current screen

## Commands

The following keys have to be typed in "Command Mode".

* `:set hlsearch` = Enable search highlight
* `:set number` = Show line numbers
* `:set tabstop=N` = Set the size of **TAB** to **N**
* `:set expandtab` = Convert **TAB** in spaces
* `:set bg=dark/light` = Change the color scheme
* `:set ignorecase` = Makes the search case insensitive
* `:syntax on/off` = Enable/disable syntax highlighting
* `:LNs/<tobereplaced>/<replacer>/g` = Replaces(s) all(g) \<tobereplaced> with \<replacer> in the line **LN**
* `:%s/<tobereplaced>/<replacer>/g` = Replaces(s) all(g) \<tobereplaced> with \<replacer> in the entire file
* `:e filename` = Opens "filename"
* `:r filename` = Copy the contents of the "filename" to the current file
* `:split filename` = Split screen horizontally to show the current file and "filename"
* `:vsplit filename` = Split screen vertically to show the current file and "filename"
* `:! command` = Runs "command" in shell and show the **STDOUT**
* `!! command` = Runs "command" in shell and paste the **STDOUT** in the file
