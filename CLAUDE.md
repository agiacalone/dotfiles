# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for macOS and Linux (Fedora/Kinoite and Ubuntu/Debian) environments. Files are deployed via **direct copying**, not symlinks or GNU Stow.

## Deployment

Dotfiles are installed by copying everything to the home directory:
```bash
cp -R ~/git/dotfiles/* ~/
cp -R ~/git/dotfiles/.* ~/
```

The `bin/new_ubuntu_install.sh` script handles full Ubuntu system setup including package installation, plugin manager setup, and dotfile deployment.

For macOS, `bin/mac-brew-gnu.sh` installs GNU tools via Homebrew.

## Shell Configuration

`.zshrc` is the primary shared config, deployed directly as `~/.zshrc`. It auto-detects the OS via `uname` and sources the appropriate config:
- `.zshrc-macos` — macOS-specific (iTerm2, Homebrew paths, GPG)
- `.zshrc-linux` — Linux/Ubuntu-specific (dircolors, GPG)
- `.zshrc-fedora` — Fedora/Kinoite-specific (dircolors, GPG, Flatpak path)
- `.zshrc-sdf` — SDF (SDF Public Access Unix System, sourced manually)

Common aliases live in `.aliases`, sourced from the shell configs.

## Plugin Managers

- **Vim**: Vundle — plugins defined in `.vimrc`, installed via `:PluginInstall`
- **Tmux**: TPM (Tmux Plugin Manager) — plugins defined in `.tmux.conf`, installed via `prefix + I`
- **Zsh**: oh-my-zsh — theme `cypher`, plugins: git, tmux, colored-man-pages, mosh, npm, node, macos

## Key Directories

- `bin/` — utility scripts deployed to `~/bin/`; includes precompiled binaries (`amfora`, `ticker`)
- `extra-configs/` — configs for privoxy, squid, newsboat, tor (not deployed to home dir)
- `vlc/` — VLC media player extensions and configs
- `.vim/` — Vim plugin directory managed by Vundle
- `.tmux/` — Tmux plugins and color schemes
- `.mutt/` — Mutt email client configs (multi-account: Gmail, SDF)

## Tmux

Prefix key is `Ctrl-A` (not the default `Ctrl-B`); `Ctrl-B` is set as a secondary prefix for ShadowTerm iOS app compatibility. Session persistence via tmux-resurrect and tmux-continuum.

## Theme switcher

`bin/theme` switches the color scheme across emulator (Konsole/iTerm2 via OSC), tmux, neovim, and zsh in lockstep. Source of truth = `themes/*.theme` palette files (16 ANSI + fg/bg/cursor + per-program mapping keys). `bin/theme-gen` turns a palette into tmux/Konsole/iTerm2 artifacts. State in `~/.config/theme/current` (neovim `fs_event`-watches it; `.config/nvim/lua/theme-sync.lua` applies the matching colorscheme, generating a monochrome highlight set for the `phosphor-*` themes). `bin/tmux-theme` is a back-compat shim → `theme`. Spec + plan in `docs/superpowers/`. Tests: `bash themes/tests/run_all.sh`. Adding a theme = drop one `themes/<name>.theme`.

## .gitignore

`.claude`, `.passwords`, and `.DS_Store` are intentionally excluded from the repository.

## IMPORTANT!

Always use PGP key signing when committing repositories
