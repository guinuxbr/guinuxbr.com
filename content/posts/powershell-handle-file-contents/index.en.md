---
title: "POWERSHELL HANDLE FILE CONTENTS"
date: 2024-03-25T10:46:55Z
draft: true
tags: ["Windows", "PowerShell", "Telnet"]
categories: ["tips"]
align: left
featuredImage: banner.en.png
---

## How to add contents to a file

To add contents to a file we can use the `Add-Content` cmdlet.

```powershell
Add-Content -Path C:\path_to_destination_file "Content to be added"
```

## How to add the contents of a file to another file

To get a file contents we can use the `Get-Content` cmdlet.

```powershell
Get-Content C:\file_to_source | Add-Content -Path C:\path_to_destination_file
```

### Note

This is similar to use `cat` and redirection `>>` in the Unix world.

```bash
cat /file_to_source >> /path_to_destination_file
```

## How to combine the above two commands

```powershell
Add-Content -Path C:\path_to_destination_file "Content to be added"; Get-Content C:\file_to_source | Add-Content -Path C:\path_to_destination_file
```
