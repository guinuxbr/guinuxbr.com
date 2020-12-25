---
title: "Vim Cheat Sheet"
subtitle: "Sooner or latter you will need it"
date: 2020-12-25T19:22:19Z
draft: false
tags: ["linux", "vim", "editor"]
categories: ["tutorials", "tips"]
align: left
---

For a long time, I ran away from Vim because it seemed very tricky and because there is a lot of simpler editors out there to work with. However, as it comes installed in most Linux distributions, I made this cheat sheet to help me understand how things work. I have discovered that is possible to be very productive with Vim 😃.

I'll try to go straight to the point. This cheat-sheet is not intended to be a complete guide but it helps to get started.

Vim have different operation modes, and I will not cover all of them in this cheat sheet. I'll stick with the basic functionality needed to open, edit and save a file.

![vim-logo](/img/vim-cheat-sheet/vim-logo.png)

Let's begin! To open a file with Vim just type `vim filename`.  
`ESC` = enter "command mode"

##### Move the cursor

You can use the arrow keys to move the cursor around. There is also special keys to do this:

* `h` = move one character left  
* `j` = move one row down
* `k` = move one row up
* `l` = move one character right

##### Edition Mode  

The following keys have to be typed in "Command Mode".

* `i` = insert text in the cursor position
* `I` = insert text in the begin of the line
* `o` = insert text in the next line
* `O` = insert text in the previous line
* `a` = insert a character after the current
* `A` = insert text at the end of the line
* `r` = replace the character at the current cursor position
* `R` = enter replace mode to replace characters from the current cursor position
* `u` = undo last action
* `CTRL + r` = redo

##### Saving & Exiting

The following keys have to be typed in "Command Mode".

* `:w` = Save
* `:q` = Exit
* `:q!` = Force exit (exit without saving)
* `:qa` = Exit from all opened files
* `:wq` = Save and exit
* `:x` = Save and exit
* `ZZ` = Save and exit
* `ZQ` = Force exit (exit without saving)

##### Copy, paste & cut

The following keys have to be typed in "Command Mode".

* `yy` = copy line
* `p` = paste content to the below line
* `P` = paste content to the above line
* `yNy` = copy N lines
* `cw` = cut the word starting from the current cursor position
* `dd` = cut or delete a line
* `D` = delete the line starting from the current cursor position
* `dG` = delete the lines starting from the current cursor position to the end of the file
* `dGG` = delete the lines starting from the current cursor position to the begin of the file
* `dw` = delete the word starting from the current cursor position
* `dNd` = cut or delete N lines
* `x` = delete a character at the current cursor position (similar to "delete" key behaviour)
* `X` = delete a character before the current cursor position (similar to "backspace" key behaviour)
* `yw` = copy the word starting from the current cursor position

##### Visual Mode

The following keys have to be typed in "Command Mode".

* `v` = visual mode that allows to select a text fragment
* `V` = visual mode that allows to select an entire line
* `CTRL+v` = visual block that allows select a block of text

##### Navigation

The following keys have to be typed in "Command Mode".

* `/pattern` = search forward for a patter
* `?pattern` = search backward for a pattern
* `n` = pattern forward search
* `N` = pattern backward search
* `gg` = goes to the first line of the file
* `G` = goes to the last line of the file
* `H` = goes to the top of the current screen
* `M` = goes to the middle of the current screen
* `L` = goes to the end of the current screen

##### Commands

The following keys have to be typed in "Command Mode".

* `:set hlsearch` = enable search highlight
* `:set number` = show line numbers
* `:set tabstop=N` = set the size of TAB to N
* `:set expandtab` = convert TAB in spaces
* `:set bg=dark/light` = change the color scheme
* `:set ignorecase` = makes the search case insensitive
* `:syntax on/off` = enable/disable syntax highlighting
* `:LNs/tobereplaced/replacer/g` = replaces(s) all(g) _tobereplaced_ with _replacer_ in the line LN
* `:%s/tobereplaced/replacer/g` = replaces(s) all(g) _tobereplaced_ with _replacer_ in the entire file
* `:e filename` = opens "filename"
* `:r filename` = copy the contents of the "filename" to the current file
* `:split filename` = split screen horizontally to show the current file and "filename"
* `:vsplit filename` = split screen vertically to show the current file and "filename"
* `:! command` = runs "command" in shell and show the STDOUT
* `!! command` = runs "command" in shell and paste the STDOUT in the file
