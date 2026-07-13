#!/usr/bin/env bash
# ── Bare Fedora KDE ISO -> a working "workbench" VM, in one command. ───────────────────
#
# The VM *is* the workstation now: the Mac/iPad are thin clients that speak RDP, and this
# script builds the thing on the other end. Run it ONCE inside a freshly-installed guest.
# Idempotent — safe to re-run, and re-running is the fix if you break something.
#
#   curl -fsSL https://raw.githubusercontent.com/agiacalone/dotfiles/main/bin/bootstrap-vm-workbench.sh -o bootstrap.sh
#   bash bootstrap.sh [hostname]        # default hostname: workbench
#
# It runs, in order:
#   1. vm-provision-rdp.sh   — xrdp + Xorg Plasma, sshd, no-sleep, polkit, firewall
#   2. vm-setup-dotfiles.sh  — packages, oh-my-zsh, dotfiles, p10k; login shell stays bash
#
# Afterwards the guest needs NOTHING else. The remaining wiring is on the HOST (pin the
# guest IP, DNAT a host port -> guest:3389); see notes/desktop-vm-on-reason.md.
#
# Clone this box to `presentation` when you need a lecture/demo VM — the clone inherits
# every fix below for free. See ~/clone-presentation-vm.sh on the host.
set -euo pipefail

NEW_HOSTNAME="${1:-workbench}"
RAW="https://raw.githubusercontent.com/agiacalone/dotfiles/main/bin"

echo "== bootstrap-vm-workbench -> ${NEW_HOSTNAME} =="
echo

# Fetch the two stages if we're running from a bare guest that has no dotfiles yet.
# Once dotfiles-update has run, they live in ~/bin and we prefer those.
fetch() {  # fetch <script-name> -> echoes a runnable path
    local name="$1"
    if [ -x "$HOME/bin/$name" ]; then
        echo "$HOME/bin/$name"
    else
        local tmp="/tmp/$name"
        curl -fsSL "$RAW/$name" -o "$tmp"
        chmod +x "$tmp"
        echo "$tmp"
    fi
}

# 0. Name the box before anything else — a clone that keeps its parent's hostname is a
#    debugging trap (two VMs, same name, same journald keys).
if [ "$(hostname)" != "$NEW_HOSTNAME" ]; then
    sudo hostnamectl set-hostname "$NEW_HOSTNAME"
    echo "hostname -> $NEW_HOSTNAME"
fi

# 1. Desktop over RDP (this is the part that must not be "improved" — read the script).
bash "$(fetch vm-provision-rdp.sh)"

# 2. Shell environment. Deliberately AFTER the RDP stage: it enforces bash as the login
#    shell, and that check wants a provisioned graphical box to test against.
bash "$(fetch vm-setup-dotfiles.sh)"

cat <<EOF

== ${NEW_HOSTNAME} is ready. ==

  Connect:  Microsoft Remote Desktop -> <host-ip>[:PORT], session Xorg, your Fedora user.
  Recover:  ssh into it. A black screen is ALWAYS diagnosable over ssh; that is why it's on.

Two rules, both learned the hard way (notes/desktop-vm-on-reason.md):

  1. Do NOT 'chsh -s zsh'. The login shell stays BASH or the desktop black-screens on the
     next reboot. You still get zsh in every terminal — .bashrc execs it. Nothing is lost.
  2. Do NOT set KWIN_COMPOSE / LIBGL_ALWAYS_SOFTWARE / GALLIUM_DRIVER to "fix" the GL
     warnings in the xrdp log. They are harmless. Plasma falls back on its own. Every one
     of those env vars has turned a WORKING desktop black, and they persist across
     reconnects (systemd user manager), so only a guest reboot clears them.

Still to do on the HOST: pin this guest's IP, DNAT a host port -> ${NEW_HOSTNAME}:3389.
EOF
