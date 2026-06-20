# dotfiles

Personal dotfiles for macOS and Linux (Fedora/Kinoite, Ubuntu/Debian). Deployed via direct copy — no symlinks, no Stow.

## Highlights

### Shell — Zsh + Powerlevel10k
- `oh-my-zsh` with the **Powerlevel10k** theme and instant-prompt for a snappy startup
- Plugins: `git`, `tmux`, `docker`, `docker-compose`, `z`, `fzf`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, and more
- **OS-aware config**: `.zshrc` auto-detects macOS / Fedora / Ubuntu / BSD and sources the right platform file (`zshrc.macos`, `.zshrc.fedora`, `.zshrc.linux`, …)
- Machine-local overrides via `~/.zshrc.local` and `~/.aliases.local` (not tracked)

### Tmux
- Prefix: `Ctrl-A` (with `Ctrl-B` as a secondary prefix for [ShadowTerm](https://shadowterm.app/) on iOS)
- **Gruvbox dark** status bar with hostname, date, and time
- Vi-style pane navigation (`h/j/k`) and splits (`|` / `_`)
- Session persistence via **tmux-resurrect** + **tmux-continuum**
- Plugins: `tmux-yank`, `tmux-battery`, `tmux-prefix-highlight`, `vim-tmux-navigator`

### Vim / Neovim
- **Gruvbox** colorscheme with true color and italic support
- Managed by **Vundle**: lightline, NERDTree, vim-fugitive, vim-gitgutter, ALE (async linting), UltiSnips, vim-startify, vimtex, vim-markdown, and more
- Shared `.vimrc` works in both `vim` and `nvim` (Neovim also has its own `init.lua` in `.config/nvim/`)
- 80-column marker, smart indent, fold-by-indent, persistent cursor line

### Theme switcher (`theme`)
One command repaints **the emulator, tmux, neovim, and zsh** in lockstep — truecolor, live, no restart.

```sh
theme              # fzf picker (numbered-menu fallback)
theme nord         # switch everything, live
theme list         # available + current (*)
theme next | prev  # cycle
theme --install-profiles   # generate native Konsole / iTerm2 profiles
```

- **12 themes:** nord, gruvbox-dark/-light, tokyonight, solarized-dark/-light, catppuccin-mocha, everforest, and four warm **phosphor** monochromes — `phosphor-green` (IBM 5151/P39), `phosphor-green-apple` (Apple ][/P31), `phosphor-amber`, `phosphor-red` (soft, for root).
- **How:** palette files in `themes/*.theme` are the single source of truth. Switching emits **OSC 4/10/11/12** to repaint the live terminal (Konsole + iTerm2, tmux-passthrough aware), regenerates the tmux status conf, and writes `~/.config/theme/current` — which neovim `fs_event`-watches to flip its colorscheme (mono themes get a generated highlight set). New windows repaint on shell startup.
- **Font:** profiles use `JetBrainsMono Nerd Font Mono` (see `themes/theme.conf`; installed by `bin/install-fonts.sh`).
- **Root = red:** root shells auto-switch to `phosphor-red` (toggle with `THEME_ROOT_RED=0`).
- Add a theme: drop one `themes/<name>.theme` file. Tests: `bash themes/tests/run_all.sh`.

### Aliases (`~/.aliases`)
| Alias | What it does |
|-------|-------------|
| `lls` | `ls -lah --color` |
| `vim` | `nvim` |
| `weather` | `curl wttr.in/Los_Angeles` |
| `whatsmyip` | `curl ifconfig.me/ip` |
| `ytdl` | `yt-dlp` with best mp4+m4a quality preset |
| `dcp` | `docker compose pull && up && prune` |
| `bbs` | SSH into circumlunar BBS |

### Mutt
Multi-account email (Gmail + SDF) with custom 256-color themes and a mailcap for attachments.

### WeeChat
Libera.Chat-first WeeChat profile with secure SASL login placeholders, relay on port `9001`, service aliases, and a denser IRC UI. Setup notes: `docs/weechat-libera.md`

### VLC Extensions
- **Super Skipper** — auto-skip intros/outros
- Playlist scripts for SomaFM, FIP Radio, Flux FM, RadioTime, StreamTheWorld, and more

## Deployment

### Quick update (any machine)
```bash
~/bin/dotfiles-update
```
Clones or pulls the repo, then copies everything to `$HOME`.

### Full Ubuntu setup from scratch
```bash
bash ~/git/dotfiles/bin/new_ubuntu_install.sh
```
Installs packages, plugin managers, oh-my-zsh, and deploys dotfiles.

### Fedora Distrobox workbench
```bash
bash ~/git/dotfiles/bin/bootstrap-distrobox-workbench.sh
```
Creates (or reconfigures) a `workbench` Distrobox container from Fedora 43 with a full dev environment: Neovim, tmux, Rust/Cargo, Node, Python, ripgrep, fzf, bat, vale, ShellCheck, Nerd Fonts, and more.

```bash
# Optional: pass extra packages
EXTRA_PKGS="golang sqlite" bash ~/bin/bootstrap-distrobox-workbench.sh

# Rebuild the container from scratch
bash ~/bin/bootstrap-distrobox-workbench.sh --rebuild
```

### macOS
```bash
bash ~/git/dotfiles/bin/mac-brew-gnu.sh   # install GNU tools via Homebrew
```

## Key Files

| File / Dir | Purpose |
|------------|---------|
| `.zshrc` | Main Zsh config (OS-agnostic) |
| `.aliases` | Shared aliases for all machines |
| `.tmux.conf` | Tmux config with Gruvbox theme |
| `.vimrc` | Vim/Neovim config + Vundle plugins |
| `.config/nvim/` | Neovim Lua config |
| `.muttrc` | Mutt email client (multi-account) |
| `.config/weechat/` | WeeChat config for Libera.Chat + relay |
| `.p10k.zsh` | Powerlevel10k prompt config |
| `bin/` | Utility scripts deployed to `~/bin/` |
| `extra-configs/` | Privoxy, Squid, Tor, Newsboat (not auto-deployed) |
| `vlc/` | VLC extensions and playlist scripts |

## Plugin Managers

| Tool | Manager | Install |
|------|---------|---------|
| Vim | Vundle | `:PluginInstall` inside Vim |
| Tmux | TPM | `prefix + I` inside Tmux |
| Zsh | oh-my-zsh | bundled via `new_ubuntu_install.sh` or manual |
| Neovim | (see `.config/nvim/`) | `nvim-extras-install` script |

## Notes

- `~/.zshrc.local` and `~/.aliases.local` are gitignored — use them for machine-specific secrets and overrides
- PGP commit signing is expected on all commits
