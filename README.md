# GuinuxBR.com

![GitHub repo size](https://img.shields.io/github/repo-size/guinuxbr/guinuxbr.com)
![GitHub contributors](https://img.shields.io/github/contributors/guinuxbr/guinuxbr.com)
![GitHub stars](https://img.shields.io/github/stars/guinuxbr/guinuxbr.com)
![GitHub forks](https://img.shields.io/github/forks/guinuxbr/guinuxbr.com)
![Twitter Follow](https://img.shields.io/twitter/follow/guinuxbr?style=social)

This repo holds the files of my blog [guinuxbr.com](https://guinuxbr.com).

This blog is built with [Hugo](https://gohugo.io/), one of the most popular and fast open-source static site generators.

## Set up the blog for local development

### Requirements

[Hugo](https://gohugo.io/) and [Git](https://git-scm.com/) must be installed and configured.

### Clone the repo

```bash
git clone git@github.com:guinuxbr/guinuxbr.com.git
```

### Pull the theme files (Git submodule)

```bash
git submodule update --init --recursive
```

### When needed, update the theme files (Git submodule)

```bash
git submodule update --remote --merge
```

### Start Hugo locally

```bash
hugo server -D --bind 0.0.0.0 --baseURL http://<LAN_IP>:1313
```

This will serve the blog to all LAN addresses, so tests can be made from multiple devices.
