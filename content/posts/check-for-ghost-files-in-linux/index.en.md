---
title: "Check for Ghost Files in Linux"
date: 2023-11-05T13:30:00+00:00
draft: false
tags: ["Linux", "Shell"]
categories: ["tips"]
align: left
featuredImage: banner.en.png
---

## Check for deleted files held by a process

Sometimes, after deleting a file some process can hold the file open, causing it to not be properly deleted. This can cause various issues like the OS reading directories sizes bigger than they truly are.

## Root Cause

On Linux or Unix systems, deleting a file via `rm` or through a file manager application will unlink the file from the file system's directory structure; however, if the file is still open (in use by a running process) it will still be accessible to this process and will continue to occupy space on disk. Therefore, such processes may need to be restarted before that file's space will be cleared up on the filesystem.

`lsof` can be used to look for deleted files held by a process.

```shell
lsof +L1
```

After identifying the process holding the ghost files, restarting or killing the process will release the files and tools like `df` will then show the correct amount of space used.
