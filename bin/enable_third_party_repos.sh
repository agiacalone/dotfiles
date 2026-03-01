# --- Enable 3rd Party Repositories ---
echo "==> Enabling RPM Fusion and RPM Sphere..."

FEDORA_VER="$(rpm -E %fedora)"

# --- GPG Key Installation ---
sudo dnf install -y distribution-gpg-keys
sudo rpmkeys --import /usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-free-fedora-${FEDORA_VER}
sudo dnf --setopt=localpkg_gpgcheck=1 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm

# --- RPM Fusion ---
if ! rpm -q rpmfusion-free-release >/dev/null 2>&1; then
  dnf install -y \
    "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
    "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm"
else
  echo "RPM Fusion already installed."
fi

# --- RPM Sphere ---
if ! rpm -q rpmsphere-release >/dev/null 2>&1; then
  sudo dnf install -y \
    "https://github.com/rpmsphere/noarch/raw/master/r/rpmsphere-release-40-1.noarch.rpm"
else
  echo "RPM Sphere already installed."
fi
