---
title: "LIST FILES WITHIN GZIP"
date: 2024-01-16T21:25:00Z
draft: false
tags: ["Linux", "gzip"]
categories: ["tips"]
align: left
featuredImage: banner.en.png
---

## List files within gzip

How to list the files within a compressed `gzip` file without extracting it and get information like the timestamp and permissions?

To achieve this, we can use a tool called `zcat`.

Looking to its help session we can see:

```bash
zcat --help
Usage: /usr/bin/zcat [OPTION]... [FILE]...
Uncompress FILEs to standard output.

-f, --force       force; read compressed data even from a terminal
-l, --list        list compressed file contents
-q, --quiet       suppress all warnings
-r, --recursive   operate recursively on directories
-S, --suffix=SUF  use suffix SUF on compressed files
--synchronous     synchronous output (safer if system crashes, but slower)
-t, --test        test compressed file integrity
-v, --verbose     verbose mode
--help            display this help and exit
--version         display version information and exit

With no FILE, or when FILE is -, read standard input.

Report bugs to <bug-gzip@gnu.org>.
```

## Understanding the option `-l`

The option we need is `-l` to **list compressed file contents**.

This will output a list of all the files and directories in the compressed file, along with some information.

For example, if you have a compressed file called `file_sample.gz`, you can run the following command to list its contents:

```bash
zcat -l file_sample.gz
```

This will output something like the following:

```bash
-rw-r--r-- 1 user group 1024 2023-09-19 17:38:25 file_sample_01.txt
-rw-r--r-- 1 user group 1024 2023-10-25 18:40:25 file_sample_02.txt
-rw-r--r-- 1 user group 1024 2022-04-11 17:38:25 file_sample_03.txt
```

This tells us that the compressed file contains several files, and list information like file permission, file ownership, size and timestamp.

## Conclusion

`zcat` is very useful for several situations. This short article is a small introduction, always check the package `man pages` or the online documentation for more broad knowledge.
