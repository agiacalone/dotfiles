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
IMAGE="${IMAGE:-registry.fedoraproject.org/fedora:43}"   # stable (avoid Rawhide for workbench containers)
HOME_MOUNTS="${HOME_MOUNTS:-1}"                          # 1 = use real $HOME inside container
DEFAULT_SHELL_ZSH="${DEFAULT_SHELL_ZSH:-1}"


# --- Packages (always installed) ---
PKGS_BASE=(
  # build / dev
  gcc gcc-c++ make cmake gdb
  git git-lfs

  # editor / terminal
  neovim tmux
  zsh
  fastfetch

  # search / navigation
  ripgrep fd-find fzf
  htop

  # data / net / archives
  jq yq
  wget

  # python (handy everywhere)
  python3 python3-pip
)

# --- Optional extras (defaults, but easily overridden) ---
EXTRA_PKGS_DEFAULT=""
EXTRA_PKGS="${EXTRA_PKGS:-$EXTRA_PKGS_DEFAULT}"

# Build final PKGS array (base + extras)
PKGS=( "${PKGS_BASE[@]}" )
if [[ -n "$EXTRA_PKGS" ]]; then
  read -r -a EXTRA_ARR <<< "$EXTRA_PKGS"
  PKGS+=( "${EXTRA_ARR[@]}" )
fi



need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 1; }; }

echo "[*] Checking host dependencies..."
need distrobox
need podman

# Helper: run a command inside the container as root
inbox_root() {
  distrobox enter "$NAME" -- sudo -n bash -lc "$*"
}

# Helper: run a command inside the container as user
inbox_user() {
  distrobox enter "$NAME" -- bash -lc "$*"
}

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
  echo "[*] Creating container '$NAME'..."
  distrobox create --name "$NAME" --image "$IMAGE"
fi

echo "[*] Ensuring sudo works inside container (you may be prompted once)..."
# This will ask for your password inside the container if needed.
inbox_user "sudo -v"

echo "[*] Setting DNF defaults to avoid distrobox base-package landmines..."
# These packages sometimes try to chown bind-mounted host files (/etc/host.conf, /dev, etc.) and can fail in distrobox.
# Excluding them keeps your "pet" container stable.
inbox_root "mkdir -p /etc/dnf"
inbox_root "grep -q '^exclude=' /etc/dnf/dnf.conf 2>/dev/null || echo 'exclude=filesystem* setup*' | tee -a /etc/dnf/dnf.conf >/dev/null"
inbox_root "dnf -y makecache --refresh"

echo "[*] Installing packages..."
# shellcheck disable=SC2048
inbox_root "dnf -y install ${PKGS[*]}"

echo "[*] Creating/patching your alias file (~/.aliases) with a safe sysupdate..."
inbox_user "touch ~/.aliases"
inbox_user "grep -q '^alias sysupdate=' ~/.aliases || echo \"alias sysupdate='sudo dnf upgrade -y --refresh --exclude=filesystem\\* --exclude=setup\\*'\" >> ~/.aliases"

echo "[*] Ensuring your shell loads ~/.aliases (idempotent)..."
# For zsh (zsh is always installed)
inbox_user "touch ~/.zshrc"
inbox_user "grep -q 'source ~/.aliases' ~/.zshrc || echo '[[ -f ~/.aliases ]] && source ~/.aliases' >> ~/.zshrc"
inbox_user "grep -q 'export EDITOR=nvim' ~/.zshrc || echo 'export EDITOR=nvim' >> ~/.zshrc"
inbox_user "grep -q 'export VISUAL=nvim' ~/.zshrc || echo 'export VISUAL=nvim' >> ~/.zshrc"


# For bash (in case you ever enter with bash)
inbox_user "touch ~/.bashrc"
inbox_user "grep -q 'source ~/.aliases' ~/.bashrc || echo '[[ -f ~/.aliases ]] && source ~/.aliases' >> ~/.bashrc"
inbox_user "grep -q 'export EDITOR=nvim' ~/.bashrc || echo 'export EDITOR=nvim' >> ~/.bashrc"
inbox_user "grep -q 'export VISUAL=nvim' ~/.bashrc || echo 'export VISUAL=nvim' >> ~/.bashrc"

if [[ "$DEFAULT_SHELL_ZSH" == "1" ]]; then
  echo "[*] Setting default shell to zsh inside container (for your user)..."
  # chsh may require passwd entry inside container; this usually works in distrobox.
  inbox_user "command -v zsh >/dev/null && (chsh -s \"\$(command -v zsh)\" \"\$(whoami)\" || true)"
fi

echo "[*] Quick sanity checks..."
inbox_user "nvim --version | head -n 2 || true"
inbox_user "tmux -V || true"
inbox_user "zsh --version || true"

cat <<EOF

✅ Done.

Enter your environment with:
  distrobox enter $NAME

Then run:
  sysupdate

Notes:
- This uses Fedora 43 stable (good for a long-lived daily driver container).
- It permanently excludes filesystem/setup upgrades inside the container to avoid RPM chown failures on bind mounts.

To rebuild from scratch:
  distrobox rm -f $NAME
  $0

EOF
