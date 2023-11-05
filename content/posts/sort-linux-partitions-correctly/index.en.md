---
title: "Sort Linux Partitions Correctly"
date: 2020-08-21T15:10:00-03:00
draft: false
tags: ["Linux", "partitions"]
categories: ["tutorials"]
align: left
featuredImage: banner.en.png
---

## Introduction

Hi and welcome to my blog!
Here goes a quick tip on how to properly sort partitions number in Linux.

Let's think that we had a disk `/dev/sda` with 4 partitions:  

```shell
/dev/sda1
/dev/sda2
/dev/sda3
/dev/sda4
```

Now, if we have to repartition our disk and delete `/dev/sda2` and `/dev/sda3` to make `/dev/sda1` larger, occasionally you will end up with `/dev/sda1` and `/dev/sda4` when it should be only `/dev/sda1` and `/dev/sda2`.

## The fix

To fix this mess and sort the partitions correctly we can use `fdisk` which is present by default in almost every Linux installation. Remember that `fdisk` and most of the partition/disk tools are very powerful and can be dangerous. Make sure to have a backup of your important files.

Now, let's do the job.
Begin typing `sudo fdisk /dev/sda`.

Then type **"**m"** to see the help.

Press **"p"** to print the partition list.

You'll see that they are unsorted.

Now, type **"x"** to access the advanced options.

Then type **"m"** again to see the help.

Press **"f"** to fix the order of the partitions.

Press **"p"** again to print the partition list.

Now, they should be sorted correctly 😉.

Press **"w"** to write changes to the disk and exit.

It's done.
