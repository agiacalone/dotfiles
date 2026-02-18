# --- Enable 3rd Party Repositories ---
echo "==> Enabling RPM Fusion and RPM Sphere..."

FEDORA_VER="$(rpm -E %fedora)"

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
  dnf install -y \
    "https://github.com/rpmsphere/noarch/raw/master/r/rpmsphere-release-40-1.noarch.rpm"
else
  echo "RPM Sphere already installed."
fi
