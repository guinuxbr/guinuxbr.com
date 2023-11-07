---
title: "LINUX, HOW TO FIND FILES BY AGE"
date: 2023-11-07T21:15:56Z
draft: false
tags: ["Linux", "find"]
categories: ["tips"]
align: left
featuredImage: banner.en.png
---

## Find files by age

A while ago I needed to find old files in a Linux server. The `find` utility have the `-mtime` option to complete this task.

Here's an example command:

```shell
find /path/to/directory -type f -mtime +730
```

Running this command will list all the files in the specified directory (and its subdirectories) that are older than two years.

Let's break down the command:

- `find /path/to/directory`: Search recursively starting from the specified folder.
- `-type f`: This option specifies that we are looking for regular files (excluding directories and other special file types).
- `-mtime +730`: This option specifies the modification time of the files. The +730 means files older than 730 days (365 days x 2 years).

Note that the modification time of a file is based on the last time it was modified, including changes to its content, permissions, or ownership.

## Conclusion

The `find` utility have several options and possibilities, always check the software manual pages with `man find` or [online](https://linux.die.net/man/1/find).
