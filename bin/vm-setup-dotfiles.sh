#!/usr/bin/env bash
# Deploy Anthony's dotfiles + zsh environment onto a fresh Fedora VM (NOT a distrobox).
# This is the VM-native equivalent of bin/bootstrap-distrobox-workbench.sh — same result,
# no container layer. Run it INSIDE the guest (needs sudo). Idempotent.
#
# Order matters: install oh-my-zsh base BEFORE dotfiles-update (so ~/.oh-my-zsh exists),
# then deploy the tracked .zshrc/.zshrc.* + bin/, then clone p10k + plugins into custom/.
# Secrets (*.local) are gitignored and are NOT deployed — a VM gets a clean shell, no keys.
set -euo pipefail

echo "== vm-setup-dotfiles on $(hostname) =="

# 1. Packages the dotfiles expect (subset of the workbench bootstrap's PKGS_BASE).
sudo dnf install -y \
  zsh git gh neovim tmux lsd ripgrep fd-find fzf bat htop tree jq yq \
  wget curl unzip pv fastfetch util-linux-user gcc make \
  2>&1 | tail -3

# 2. oh-my-zsh base (unattended, don't touch shell yet, keep any existing .zshrc).
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 3. Deploy the dotfiles (clones the repo to ~/git/dotfiles and copies into $HOME, incl. bin/).
if [ -x "$HOME/bin/dotfiles-update" ]; then
  "$HOME/bin/dotfiles-update"
else
  mkdir -p "$HOME/git"
  git clone https://github.com/agiacalone/dotfiles.git "$HOME/git/dotfiles" 2>/dev/null || \
    git -C "$HOME/git/dotfiles" pull
  # first-time bootstrap copy so bin/dotfiles-update lands, then use it
  cp -R "$HOME/git/dotfiles/bin" "$HOME/" 2>/dev/null || true
  [ -x "$HOME/bin/dotfiles-update" ] && "$HOME/bin/dotfiles-update"
fi

# 4. p10k theme + zsh-autosuggestions/syntax-highlighting into ~/.oh-my-zsh/custom.
[ -x "$HOME/bin/omz-extras-install" ] && bash "$HOME/bin/omz-extras-install" || true

# 5. zsh for INTERACTIVE TERMINALS, but the LOGIN shell stays bash.
#    ==DO NOT `chsh -s zsh` on a GUI box.== zsh-as-login-shell has hung the xrdp/Plasma
#    session launch (p10k instant-prompt with no controlling terminal) -> permanent black
#    screen after the next reboot. The repo's .bashrc execs zsh for interactive shells, so
#    you still land in zsh in every terminal and give up nothing.
#    Tracked .zshrc/.bashrc are hardened against this now, but the login shell is user
#    state that dotfiles-update can't own — so ENFORCE it here, and undo a stray chsh.
login_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
if [ -n "${DISPLAY:-}" ] || systemctl get-default 2>/dev/null | grep -q graphical; then
  if [ "${login_shell##*/}" = "zsh" ]; then
    echo "!! login shell is zsh on a GRAPHICAL box — that black-screens the desktop. Fixing."
    sudo chsh -s /bin/bash "$(id -un)"
  fi
fi

echo
echo "== done. login shell: $(getent passwd "$(id -un)" | cut -d: -f7) (bash = GUI-safe) =="
echo "   Terminals still run zsh + p10k (.bashrc execs zsh when interactive)."
echo "   Per-machine secrets go in ~/.zshrc.local (gitignored, not deployed)."
