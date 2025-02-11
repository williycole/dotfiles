# Dotfiles for Neovim with WSL, Go, and DAP

This repository contains my personal configuration to use Neovim, Go, and Debug Adpater Protocol (DAP) support.
Kickstart.nvim was used to initalzie this configuration.
This config should work across powershell, WSL, and gitbash, pending all required dependencies are installed in your environment.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [License](#license)

## Prerequisites

Before you begin, ensure you have the following installed:

- **Windows Subsystem for Linux (WSL)**: Follow the instructions [here](https://docs.microsoft.com/en-us/windows/wsl/install) to install WSL on your Windows machine.
- **Ubuntu**: You can install Ubuntu from the Microsoft Store.

## Installation

1. **Open WSL (Ubuntu)**:
   Launch Ubuntu from the Start menu.

2. **Install Go**:

   ```bash
   sudo apt update
   sudo rm -rf /usr/local/go
   wget https://go.dev/dl/go1.22.7.linux-amd64.tar.gz
   sudo tar -C /usr/local -xzf go1.22.7.linux-amd64.tar.gz
   echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
   echo 'export PATH=$GOROOT/bin:$PATH' >> ~/.bashrc
   source ~/.bashrc
   go version  # Verify installation

---

# TODO: A list of things I still want todo

1. Explore installing all deps of my workflow via a script
   - primagen has a [course](https://frontendmasters.com/courses/developer-productivity-v2) for this on frontend masters
2. - containerizing my workflow with ^ and [devcontainers](https://github.com/devcontainers/cli)
3. - setup lingering nvim plugins such as [refactor](https://github.com/ThePrimeagen/refactoring.nvim) & [minuet-ai](https://github.com/milanglacier/minuet-ai.nvim)
4. Polish all dotfiles
5. Explore more efficient ways of managing my dotfiles and implement or create one.
6. Optomize glazewm / zebar setup
