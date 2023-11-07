---
title: "FIND LINUX BROKEN SYMLINKS"
date: 2023-11-07T20:46:53Z
draft: false
tags: ["Linux", "symlinks"]
categories: ["tips"]
align: left
featuredImage: banner.en.png
---

## Find broken symbolic links

A while ago, I was willing to contribute with a GitHub project, but I found some issues with broken links. This situation led me to a question: how can I recursively find all broken links within a directory?

The command below will print the path to any broken symbolic links found in the specified folder and its subfolders.

```shell
find /path/to/folder -type l ! -exec test -e {} \; -print
```

Let's explain each part of the command does:

- `find /path/to/folder`: Search recursively starting from the specified folder.
- `-type l`: Only look for symbolic links.
- `! -exec test -e {} \;`: Use the test command to check if each symbolic link exists. The `{}` is a placeholder for the path to the symbolic link. The `-e` option to test checks if the file exists. The `!` negates the result of the test, so the command will succeed if the file does not exist (i.e., if the symbolic link is broken).
- `-print`: Print the path to any broken symbolic links found.

## Conclusion

With the list of broken symbolic links, to fix the issue, it is just a matter of recreating the links pointing to the right locations.
