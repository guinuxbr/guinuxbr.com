---
title: "DOCKER 101 - BASIC COMMANDS"
date: 2024-01-20T15:45:00Z
draft: false
tags: ["Containers", "Docker"]
categories: ["tips"]
align: left
featuredImage: banner.en.png
---

## Docker commands

In the article [DOCKER 101](https://guinuxbr.com/docker-101/), I wrote about the basics of Docker and its components. In this article I will cover a set o Docker **basic** commands very useful for any kind of usage.

### Docker command line structure

The old way:

```shell
docker <command> (options)
```

The new recommended way:

```shell
docker <command> <sub-command> (options)
```

### Checking the Docker version

There are two possible ways to check the version of docker is currently installed: `docker version` and `docker --version`.

The version command (`docker version`) prints the current version number for all independently versioned Docker components, while the `--version` flag (`docker --version`) outputs the version number of the Docker CLI you are using.

```shell
$ docker version
Client:
 Version:           20.10.23-ce
 API version:       1.41
 Go version:        go1.18.10
 Git commit:        6051f1429
 Built:             Tue Mar 14 14:32:06 2023
 OS/Arch:           linux/amd64
 Context:           default
 Experimental:      true

Server:
 Engine:
  Version:          20.10.23-ce
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.18.10
  Git commit:       6051f1429
  Built:            Wed Jan 18 16:24:28 2023
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v1.6.19
  GitCommit:        1e1ea6e986c6c86565bc33d52e34b81b3e2bc71f
 runc:
  Version:          1.1.5
  GitCommit:        v1.1.5-0-gf19387a6bec4
 docker-init:
  Version:          0.1.3_catatonit
  GitCommit:
```

```shell
$ docker --version
Docker version 20.10.23-ce, build 6051f1429
```

### `docker info`

This command displays system-wide information regarding the Docker installation. The information displayed includes the kernel version, number of containers and images. The number of images shown is the number of unique images. The same image tagged under different names is counted only once.

If a format is specified, the given template will be executed instead of the default format. Go’s [text/template](https://golang.org/pkg/text/template/) package describes all the details of the format.

Depending on the storage driver in use, additional information can be shown, such as pool name, data file, metadata file, data space used, total data space, metadata space used, and total metadata space.

The data file is where the images are stored, and the metadata file is where the metadata regarding those images are stored. When run for the first time Docker allocates a certain amount of data space and metadata space from the space available on the volume where `/var/lib/docker` is mounted.

```shell
$ docker info
Client:
 Context:    default
 Debug Mode: false

Server:
 Containers: 2
  Running: 0
  Paused: 0
  Stopped: 2
 Images: 2
 Server Version: 20.10.23-ce
 Storage Driver: overlay2
  Backing Filesystem: extfs
  Supports d_type: true
  Native Overlay Diff: true
  userxattr: false
 Logging Driver: json-file
 Cgroup Driver: cgroupfs
 Cgroup Version: 1
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
 Swarm: inactive
 Runtimes: runc io.containerd.runc.v2 io.containerd.runtime.v1.linux oci
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: 1e1ea6e986c6c86565bc33d52e34b81b3e2bc71f
 runc version: v1.1.5-0-gf19387a6bec4
 init version:
 Security Options:
  apparmor
  seccomp
   Profile: default
 Kernel Version: 4.12.14-122.156-default
 Operating System: openSUSE Linux
 OSType: linux
 Architecture: x86_64
 CPUs: 2
 Total Memory: 3.82GiB
 Name: localhost
 ID: U6HT:KTST:TBPU:J6AW:RHAD:A4UM:MGHP:WLS4:T0YB:T8RJ:Y4HJ:D7DY
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 Registry: https://index.docker.io/v1/
 Labels:
 Experimental: false
 Insecure Registries:
  127.0.0.0/8
 Live Restore Enabled: false

WARNING: No swap limit support 
```

### Running a container

The command used to run a container is `docker container run`.

```shell
$ docker container run --publish 80:80 nginx
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2023/05/02 12:53:22 [notice] 1#1: using the "epoll" event method
2023/05/02 12:53:22 [notice] 1#1: nginx/1.23.4
2023/05/02 12:53:22 [notice] 1#1: built by gcc 10.2.1 20210110 (Debian 10.2.1-6)
2023/05/02 12:53:22 [notice] 1#1: OS: Linux 4.12.14-122.156-default
2023/05/02 12:53:22 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2023/05/02 12:53:22 [notice] 1#1: start worker processes
2023/05/02 12:53:22 [notice] 1#1: start worker process 30
2023/05/02 12:53:22 [notice] 1#1: start worker process 31
```

Based on the above command, here is what the Docker daemon does when we try to run a container:

1. It looks for the image locally in the image cache. If it doesn't find anything, download the image from the Registry which defaults to Docker Hub. If no version is specified, it defaults to the latest available.
2. Started a new container based on the declared image.
3. Assign a virtual IP on a private network inside the Docker engine.
4. The argument `--publish 80:80` exposes the port 80 on the host and routes the traffic to the container on port 80.

The output shown in the standard out is the Nginx log because the container is running in foreground mode.

To run a container in background mode, just add the option `--detach`.

Running the container in background mode will only show the unique ID assigned by the Docker daemon.

```shell
$ docker container run --publish 80:80 --detach nginx
af25ab938a4cfeac32f5c42d0d9b04e024d0cf17ac53cec34e4601ff9ecbb1d5
```

### Listing containers

The `docker container ls` command lists all running containers on your system. You can use filters like `status`, `name` or `id` to see only specific types of containers. Use `--all` to show stopped containers as well as those that are currently running.

```shell
$ docker container ls
CONTAINER ID   IMAGE   COMMAND                  CREATED          STATUS          PORTS                               NAMES
af25ab938a4c   nginx   "/docker-entrypoint.…"   14 minutes ago   Up 14 minutes   0.0.0.0:80->80/tcp, :::80->80/tcp   clever-nonsense
```

### Stopping containers

The `docker container stop` command is used to stop a running container in Docker. When this command is executed, the main process inside the container receives a _SIGTERM_ signal, which warns the container of possible termination after a certain grace period. After this grace period, the process receives a _SIGKILL_ signal, which terminates the running container.

To use the `docker container stop` command, you need to specify the container ID or container name. For example, to stop a container named "my_container", you would execute the following command:

```shell
docker container stop my_container
```

#### Stopping multiple containers

To stop multiple containers at once, you can specify their container IDs or container names as arguments to the `docker container stop` command. For example:

```shell
docker container stop container_id_or_name_1 container_id_or_name_2 container_id_or_name_3
```

This will stop all three containers at once.

**Stop all containers associated with an image**: If you want to stop all running containers that are associated with a specific Docker image, you can filter the running containers based on their base image, and then pass their container IDs to the `docker container stop` command using the `xargs` command. For example:

```shell
docker container ls --quiet --filter ancestor=IMAGE_NAME | xargs docker container stop
```

This will stop all running containers associated with the Docker image named "IMAGE_NAME".

**Stop all running containers**: To stop all running containers, you can use the `docker container ls --quiet` command to list all running containers, and then pass their container IDs to the `docker container stop` command using the `xargs` command. For example:

```shell
docker container ls --quiet | xargs docker container stop
```

This will stop all running containers.

By default, the `docker container stop` command gives the container 10 seconds before forcefully killing it. This grace period can be changed using the `--time` option. For example, to wait 30 seconds before stopping a container, you would execute the following command:

```shell
docker container stop --time 30 container_name_or_id 
```

This will give the container 30 seconds to stop its processes and exit gracefully.

#### Curiosity

Docker assigns default container names using a combination of an adjective and the surname of a notable scientist or hacker. The algorithm used to generate the names is defined in the [names-generator_test.go](https://github.com/moby/moby/blob/master/pkg/namesgenerator/names-generator.go) file in the Docker source code. If the generated name is "boring_wozniak", the algorithm generates a new name to prevent "boring_wozniak" from being assigned to a container.

### docker container logs

The `docker container logs` command shows the logs of a running container. By default, it shows the command’s output as if it were run interactively in a terminal. Unix and Linux commands typically open three I/O streams when they run, called **STDIN**, **STDOUT**, and **STDERR**. **STDIN** is the command’s input stream, **STDOUT** is usually a command’s normal output, and **STDERR** is typically used to output error messages. By default, `docker container logs` show the command’s **STDOUT** and **STDERR**.

To check the logs of a running container, use the `docker container logs` command. For example, to display the logs of a MySQL container with the ID "30s60t3ayypg", run `docker container logs 30s60t3ayypg`. The logs contain the output you would see in your terminal when attached to a container in interactive mode (`-it` or `--interactive --tty`). Logs will only be available if the foreground process in your container emits some output.

The `docker container logs` command supports several flags that let you adjust its output. For instance, the `--timestamps` flag displays complete timestamps at the start of each log line, and the `--tail` flag fetches a given number of lines from the log.

It is important to note that the logs of a container depend almost entirely on the container’s endpoint command. In some cases, the logs may not show useful information unless additional steps are taken. For instance, if a logging driver sends logs to a file, an external host, a database, or another logging back-end, and has "[dual logging](https://docs.docker.com/config/containers/logging/dual-logging/)" disabled, `docker container logs` may not show useful information. If the image runs a non-interactive process such as a web server or a database, that application may send its output to log files instead of **STDOUT** and **STDERR**. In such cases, the logs are processed in other ways, and `docker container logs` may not be useful.

When choosing a logging driver, consider the built-in logging drivers within containers to serve as log management systems. The type of driver determines the format of the logs and where they are stored. By default, Docker uses the JSON file driver, which writes JSON-formatted logs on the container's host machine. You can use other built-in drivers to forward collected records to logging services, log shippers, or a centralized management service. If none of the existing drivers meet your requirements, Docker allows you to create a custom logging driver, add it as a plugin to a container and even distribute it through a Docker registry.

### List container processes

The `docker container top` command is used to list all the running processes of a container without the need to log in to the container. It provides information about the CPU, memory, and swap usage if run inside a Docker container.

The syntax of the command is `docker container top [OPTIONS] CONTAINER [ps OPTIONS]`. Here, "[OPTIONS]" are the command options and "[ps OPTIONS]" are the options for the Unix `ps` command.

For example, the command `docker container top a98db973kwl8` lists all the running processes of the container with ID "a98db973kwl8".

If more details about the processes are needed, the Unix `ps` options can be added like `docker container top a98db973kwl8 -ax`.

### Removing containers

The `docker container rm` command is used to remove Docker containers. It requires the container ID or name to be passed as an argument to remove or delete the container. The container must be in a stopped state unless we want to delete the containers forcefully using the `-f` or `--force` option, however, it's not recommended as it sends a kill command and your container might not save its state. Removing a container will delete all the data stored inside the container, and there is no way to get it back, so we use persistent storage to store the data to preserve it.

The `docker container rm` command has several options:

- `-f` or `--force`: This option is used to remove the running container forcefully using the SIGKILL signal.
- `-v` or `--volumes`: This option is used to remove the volumes attached to the container. If a volume was specified with a name, it will not be removed.
- `-l` or `--link`: This option is used to remove a specified link that exists.

To remove a specific container, the following command is used:

```shell
docker container rm container_id_or_name
```

To remove all containers, stop the running ones first and then remove them:

```shell
docker container ls --quiet | xargs docker stop
docker container ls --quiet | xargs docker rm
```

You can force remove a running container with the `--force` option,

### Remove all stopped containers

The `docker container prune` command can be used to remove all stopped containers.

### Clean up Docker environment

The `docker system prune` command can be used to remove unused containers in addition to other Docker resources, such as (unused) images and networks. Alternatively, you can use the `docker ps` command with the `-q` or `--quiet` option to generate a list of container IDs to remove and use that list as an argument for the `docker rm` command.

Another interesting option is to use the `--rm` flag for those containers that are only needed to accomplish something specific, e.g., compile your application inside a container or just test something that it works. This flag will tell the Docker daemon that once the container is done running, erase everything related to it and save the disk space.

## Conclusion

In this article, I've covered some basics Docker commands. I encourage everyone to try Docker for themselves, as it can greatly simplify the development and deployment of applications.

As usual, I recommend checking out the official Docker documentation at [docs.docker.com](https://docs.docker.com), as well as online courses and tutorials.
