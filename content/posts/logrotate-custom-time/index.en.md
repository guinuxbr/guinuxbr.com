---
title: "Logrotate_custom_time"
date: 2023-09-12T20:07:23+01:00
draft: true
tags: ["Linux", "logs"]
categories: ["tutorials"]
align: left
---

We frequently use [logrotate](https://github.com/logrotate/logrotate) to control log rotation on Linux servers. By default `logrotate` use the custom configration files locate in `/etc/logrotate.d`.

But what if we need a specific log file to be handled separately from the system-wide log rotation? you should create a custom logrotate configuration file outside of the `/etc/logrotate.d` directory.

## Create a Custom Configuration File

```bash
sudo nano /apps/app_name/logrotate/app_name
```

## Configure Log Rotation

In this new file, specify the log file, how frequently you want it to rotate, how many rotated versions to keep, and any other specific settings:

```text
/apps/app_name/logs/logname.log {
    daily
    rotate 7
    # Add any other needed configurations here
}
```

Save the file and exit the text editor.

## Configuration options

In a logrotate configuration file, you can use various options to customize the behavior of log rotation. Here are some of the common options:

- `compress`: This option compresses the rotated log files using gzip or other compress utility. It is used to save disk space.

- `copytruncate`: This option allows logrotate to truncate the original log file after creating a copy, instead of moving or deleting it. This is useful for applications that do not support log file rotation.

- `create`: This option creates a new empty log file after rotation, if it does not exist. You can specify the permissions and owner/group for the new file.

- `daily`: Rotates the log file once a day. This is one of the frequency options. Other options include `weekly`, `monthly`, and `yearly`.

- `dateext`: Appends a date in `YYYYMMDD` format to the rotated log files. This is useful for keeping track of when each log was created.

- `delaycompress`: Postpones the compression of log files until the next rotation. This can be useful in conjunction with copytruncate to prevent race conditions.

- `ifempty`: Rotates the log file even if it is empty. By default, logrotate skips empty files.

- `missingok`: Ignores errors if the log file is missing.

- `notifempty`: Prevents log rotation if the log file is empty.

- `rotate n`: Specifies how many rotated versions of the log file to keep. For example, `rotate 4` will keep four rotated log files.

- `size`: Rotates the log file when it reaches a specified size. You can use suffixes like `k` for kilobytes, `M` for megabytes, etc. For example, size `10M` means rotate when the file reaches 10 megabytes.

- `sharedscripts`: Runs the postrotate script only once for all rotated logs, rather than once for each log.

- `su`: Specifies the user and group ownership of the log file after rotation. This can be used to change ownership if log files are created with elevated privileges.

- `postrotate` and `prerotate`: These options allow you to specify shell commands or scripts to be run before or after log rotation. For example, you could use postrotate to reload a service after log rotation.

- `lastaction`: This is similar to postrotate and prerotate but is run after all log files have been rotated.

These are some of the common options you can use in a logrotate configuration file. Depending on your specific needs, you may use a combination of these options to achieve the desired log rotation behavior.

## Verify Configuration

Check the syntax of your configuration file:

```bash
sudo logrotate -vdf /etc/logrotate_custom/custom_log
```

`-vdf` stands for:

- `v`: produce a detailed verbose output
- `d`: execute a dry-run, in other words, a simulation of which `logrotate` would do
- `f`: force the rotation even if the defined criteria are not met

## Create a Cron Job

Open the crontab configuration for editing:

```bash
crontab -e
```

Add a line to schedule the execution of your custom log rotation at the desired time. For example, if you want to run it every day at 7 PM, add the following line:

```bash
0 19 * * * /usr/sbin/logrotate -f /apps/app_name/logrotate/app_name
```

Save and exit the editor.

With this setup, your custom log rotation for the **/apps/app_name/logs/logname.log** file will occur at the time specified in the `cron` job, and it won't be affected by the system-wide log rotation.
