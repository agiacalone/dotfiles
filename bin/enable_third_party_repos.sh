#!/usr/bin/env bash
set -euo pipefail

echo "==> Enabling third-party repositories..."

FEDORA_VER="$(rpm -E %fedora)"

# --- GPG Keys ---
sudo dnf install -y distribution-gpg-keys
sudo rpmkeys --import "/usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-free-fedora-${FEDORA_VER}"
sudo rpmkeys --import "/usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-nonfree-fedora-${FEDORA_VER}"

# --- RPM Fusion (free + nonfree) ---
if ! rpm -q rpmfusion-free-release >/dev/null 2>&1; then
  sudo dnf --setopt=localpkg_gpgcheck=1 install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm"
else
  echo "RPM Fusion already installed."
fi

# --- Cider (Apple Music client) ---
sudo rpm --import https://repo.cider.sh/RPM-GPG-KEY
if [[ ! -f /etc/yum.repos.d/cider.repo ]]; then
  sudo tee /etc/yum.repos.d/cider.repo << 'EOF'
[cidercollective]
name=Cider Collective Repository
baseurl=https://repo.cider.sh/rpm/RPMS
enabled=1
gpgcheck=1
gpgkey=https://repo.cider.sh/RPM-GPG-KEY
EOF
else
  echo "Cider repo already configured."
fi
sudo dnf install -y Cider

echo "==> Done."
