#!/usr/bin/env bash
set -euo pipefail

# Blow away old container if it exists
distrobox rm -f fedora-dev || true

# Recreate it
distrobox create -n fedora-dev -i registry.fedoraproject.org/fedora-toolbox:43

# Install packages inside it
distrobox enter fedora-dev -- sudo dnf upgrade -y
distrobox enter fedora-dev -- sudo dnf groupinstall -y "Development Tools"
distrobox enter fedora-dev -- sudo dnf install -y \
  git zsh neovim vim tmux fastfetch \
  ripgrep fd-find tree htop \
  python3 python3-pip \
  gcc gcc-c++ clang gdb make cmake \
  shellcheck

echo "fedora-dev rebuilt. Don't forget to set up ~/.bashrc and ~/.zshrc inside if this is a fresh home."
