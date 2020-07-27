---
title: "Convert OVA to QCOW2"
subtitle: "Easy way to use in KVM"
date: 2020-07-09T19:50:56-03:00
draft: false
tags: ["linux", "virtualization"]
categories: ["tutorials"]
align: justify
---

Hello! In this quick tutorial, I will show you how to convert OVA file to a QCOW2.

A few days ago I have to install Windows in a virtual environment to test some stuff. Then, I found that Microsoft provides some test images officially at https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/ but there are no images to use with KVM. So, what if it would be possible to convert some of the provided formats to a KVM compatible format?

Well, this is possible and much easier than I thought it was. Follow me!

First, we have to extract the files from the OVA file.
>tar -xvf MSEdge-Win10.ova

An OVA file is an Open Virtualization Appliance that contains a compressed version of a virtual machine. Now we have two files: the MSEdge - Win10-disk001.vmdk and the MSEdge - Win10.ovf. To convert the .vmdk file to a .qcow2 file to import into KVM we just have to use the qemu-img command as follows.

>qemu-img convert MSEdge-Win10-disk001.vmdk the_name_you_want.qcow2 -O qcow2

Observe that I've renamed the file MSEdge - Win10-disk001.vmdk to remove the blank spaces. I always try to do this before work with files in the command line.

That's it! Now we can just move our converted the_name_you_want.qcow2 to the images directory that is usually /var/lib/libvirt/images, but you can place it wherever you wish and import it.