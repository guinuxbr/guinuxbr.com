# GuinuxBR.com

[![Build and deploy](https://github.com/guinuxbr/guinuxbr.com/actions/workflows/hugo.yaml/badge.svg)](https://github.com/guinuxbr/guinuxbr.com/actions/workflows/hugo.yaml)
![Hugo](https://img.shields.io/badge/Hugo-Extended_v0.167+-ff4088?logo=hugo&logoColor=white)
![GitHub repo size](https://img.shields.io/github/repo-size/guinuxbr/guinuxbr.com)
![GitHub stars](https://img.shields.io/github/stars/guinuxbr/guinuxbr.com)
[![License: CC BY-NC 4.0](https://img.shields.io/badge/License-CC_BY--NC_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc/4.0/)

Source repository for my personal blog [guinuxbr.com](https://guinuxbr.com), focused on Linux, Open Source, DevOps, and
system administration.

## Tech Stack & Features

- **Static Site Generator:** [Hugo](https://gohugo.io/) (Extended edition)
- **Theme:** [DoIt](https://github.com/HEIGE-PCloud/DoIt) (included as a Git submodule)
- **Languages:** Bilingual support in English (`en`) and Brazilian Portuguese (`pt-BR`)
- **CI/CD:** Automated build and deployment to GitHub Pages via GitHub Actions
- **Linting:** Markdown formatting and linting via [`rumdl`](https://github.com/pomdtr/rumdl)

---

## Local Development

### Prerequisites

- **[Hugo Extended](https://gohugo.io/installation/)** (v0.125+ / v0.167+; **Extended edition is required** for
  SCSS/Dart Sass support)
- **[Git](https://git-scm.com/)**
- **[rumdl](https://github.com/pomdtr/rumdl)** for Markdown linting and formatting

### 1. Clone the Repository

Clone with submodules in a single step:

```bash
git clone --recurse-submodules git@github.com:guinuxbr/guinuxbr.com.git
cd guinuxbr.com
```

If you already cloned without submodules, initialize them:

```bash
git submodule update --init --recursive
```

### 2. Run the Development Server

#### Local Machine

```bash
hugo server -D
```

The site will be available at `http://localhost:1313`.

#### LAN / Multi-device Testing

To test the site from mobile devices or other computers on your local network:

```bash
hugo server -D --bind 0.0.0.0 --baseURL http://<LAN_IP>:1313
```

---

## Common Commands

### Create a New Post

English post:

```bash
hugo new posts/my-new-post/index.en.md
```

Portuguese post:

```bash
hugo new posts/my-new-post/index.pt-br.md
```

### Format Markdown with rumdl

Check formatting

```bash
rumdl check content/
```

Auto-format files

```bash
rumdl fmt content/
```

### Update the Theme Submodule

```bash
git submodule update --remote --merge
```

### Build for Production

```bash
hugo --gc --minify
```

The generated static site will be placed in the `public/` directory.

---

## Project Structure

```text
├── archetypes/       # Content templates for new posts
├── content/          # Markdown content (posts, about page)
│   ├── about/
│   └── posts/
├── static/           # Static assets (images, icons)
├── themes/DoIt/      # Theme submodule
├── .github/          # GitHub Actions deployment workflow
├── .rumdl.toml       # Markdown linter/formatter configuration
└── hugo.toml         # Main site configuration
```

---

## License

Content is licensed under
[Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)](https://creativecommons.org/licenses/by-nc/4.0/).
