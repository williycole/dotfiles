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
