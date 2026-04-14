#!/usr/bin/env bash
set -euo pipefail

REBUILD=0

for arg in "$@"; do
  case "$arg" in
    --rebuild)
      REBUILD=1
      ;;
  esac
done

# === Config ===
NAME="${NAME:-workbench}"
IMAGE="${IMAGE:-registry.fedoraproject.org/fedora:43}"  # stable (avoid Rawhide for workbench containers)
DEFAULT_SHELL_ZSH="${DEFAULT_SHELL_ZSH:-1}"

# --- Packages (always installed) ---
PKGS_BASE=(
  # build / dev
  gcc gcc-c++ make cmake gdb
  git gh git-lfs clang-tools-extra
  rust cargo

  # editor / terminal
  neovim tmux
  zsh
  pwgen
  fastfetch
  yt-dlp

  # search / navigation
  ripgrep fd-find fzf
  htop
  tree
  bat

  # data / net / archives
  jq yq
  wget curl
  rtorrent
  unzip unrar
  bind-utils

  # debug / introspection
  strace
  file

  # fun
  bsd-games nethack
  fortune

  # python (handy everywhere)
  python3 python3-pip

  # javascript (needed for markdown-preview.nvim and npm-based tools)
  nodejs npm

  # writing / linting (used by neovim LSP and none-ls)
  latexmk
  texlive-chktex
  ShellCheck

  # GUI programs
  dosbox-staging
  pulseaudio-utils

)

# --- Optional extras (space-separated, e.g. EXTRA_PKGS="htop strace") ---
PKGS=( "${PKGS_BASE[@]}" )
if [[ -n "${EXTRA_PKGS:-}" ]]; then
  read -r -a EXTRA_ARR <<< "$EXTRA_PKGS"
  PKGS+=( "${EXTRA_ARR[@]}" )
fi

# === Helpers ===
need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 1; }; }

# Run a command inside the container as root
inbox_root() { distrobox enter "$NAME" -- sudo -n bash -lc "$*"; }

# Run a command inside the container as the current user
inbox_user() { distrobox enter "$NAME" -- bash -lc "$*"; }

# Idempotently append a line to a file inside the container (as user)
append_once() {
  local pattern="$1" line="$2" file="$3"
  inbox_user "touch ${file} && grep -qF '${pattern}' ${file} || echo '${line}' >> ${file}"
}

# === Container setup ===
echo "[*] Checking host dependencies..."
need distrobox
need podman

echo "[*] Creating container '$NAME' from '$IMAGE' (or reusing if it exists)..."
if podman container exists "$NAME"; then
  if [[ "$REBUILD" == "1" ]]; then
    echo "[*] Rebuild requested. Removing existing container '$NAME'..."
    distrobox rm -f "$NAME"
    echo "[*] Recreating container..."
    distrobox create --name "$NAME" --image "$IMAGE"
  else
    echo "[*] Container '$NAME' already exists; will configure/update it."
  fi
else
  distrobox create --name "$NAME" --image "$IMAGE"
fi

echo "[*] Ensuring sudo works inside container (you may be prompted once)..."
inbox_user "sudo -v"

echo "[*] Setting DNF defaults to avoid distrobox base-package landmines..."
# filesystem* and setup* can try to chown bind-mounted host files and fail in distrobox.
inbox_root "mkdir -p /etc/dnf"
inbox_root "grep -q '^exclude=' /etc/dnf/dnf.conf 2>/dev/null || echo 'exclude=filesystem* setup*' >> /etc/dnf/dnf.conf"
inbox_root "dnf -y makecache --refresh"

echo "[*] Installing packages..."
# shellcheck disable=SC2048
inbox_root "dnf -y install ${PKGS[*]}"

# === Shell environment ===
echo "[*] Configuring shell environment..."

# sysupdate alias
append_once 'alias sysupdate=' \
  "alias sysupdate='sudo dnf upgrade -y --refresh --exclude=filesystem\* --exclude=setup\*'" \
  ~/.aliases

for rcfile in ~/.zshrc ~/.bashrc; do
  append_once '[[ -f ~/.aliases ]]'  '[[ -f ~/.aliases ]] && source ~/.aliases' "$rcfile"
  append_once 'EDITOR=nvim'          'export EDITOR=nvim'                       "$rcfile"
  append_once 'VISUAL=nvim'          'export VISUAL=nvim'                       "$rcfile"
done

if [[ "$DEFAULT_SHELL_ZSH" == "1" ]]; then
  echo "[*] Setting default shell to zsh inside container..."
  inbox_user "command -v zsh >/dev/null && (chsh -s \"\$(command -v zsh)\" \"\$(whoami)\" || true)"
fi

# === Nerd Fonts ===
echo "[*] Installing Nerd Fonts (Hack, JetBrains Mono)..."
inbox_user "mkdir -p ~/.local/share/fonts"
inbox_user "
  BASE='https://github.com/ryanoasis/nerd-fonts/releases/latest/download'
  for font in Hack JetBrainsMono; do
    zip=\"/tmp/\${font}.zip\"
    curl -fsSL \"\${BASE}/\${font}.zip\" -o \"\$zip\" && \
      unzip -o \"\$zip\" -d ~/.local/share/fonts/ '*.ttf' && \
      echo \"  installed \$font\" || echo \"  FAILED \$font\" >&2
    rm -f \"\$zip\"
  done
  fc-cache -f
"

# === npm tools ===
echo "[*] Installing npm-based tools (markdownlint-cli)..."
inbox_user "npm install -g markdownlint-cli"

# === vale (prose linter, GitHub releases) ===
echo "[*] Installing vale..."
inbox_user "
  VALE_VERSION=\$(curl -fsSL https://api.github.com/repos/errata-ai/vale/releases/latest | python3 -c 'import sys,json; print(json.load(sys.stdin)[\"tag_name\"].lstrip(\"v\"))')
  if [[ -n \"\$VALE_VERSION\" ]]; then
    curl -fsSL \"https://github.com/errata-ai/vale/releases/latest/download/vale_\${VALE_VERSION}_Linux_64-bit.tar.gz\" \
      | tar -xz -C ~/.local/bin vale && echo \"  installed vale \$VALE_VERSION\"
  else
    echo \"  FAILED: could not determine vale version\" >&2
  fi
"

# === Sanity checks ===
echo "[*] Quick sanity checks..."
inbox_user "nvim --version | head -n 2 || true"
inbox_user "tmux -V || true"
inbox_user "zsh --version || true"

# === Third-party repos ===
echo "[*] Enabling third-party repositories..."
distrobox enter --name "$NAME" -- bash ~/bin/enable_third_party_repos.sh

cat <<EOF

✅ Done.

Enter your environment with:
  distrobox enter $NAME

Then run:
  sysupdate

Notes:
- Uses Fedora 43 stable (good for a long-lived daily driver container).
- Permanently excludes filesystem/setup upgrades inside the container to avoid RPM chown failures on bind mounts.
- Override package list with: EXTRA_PKGS="pkg1 pkg2" $0

To rebuild from scratch:
  NAME=$NAME $0 --rebuild

EOF
