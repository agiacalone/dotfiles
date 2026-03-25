#!/usr/bin/env bash
set -euo pipefail

FONT_DIR="$HOME/.local/share/fonts"
TMP_DIR="$(mktemp -d)"

echo "→ Creating font directory at: $FONT_DIR"
mkdir -p "$FONT_DIR"

echo "→ Working in temp dir: $TMP_DIR"
cd "$TMP_DIR"

########################################
# 1. JetBrains Mono
########################################
echo "→ Downloading JetBrains Mono..."
# Official JetBrains Mono release zip
JBM_URL="https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip"

curl -L -o jetbrains-mono.zip "$JBM_URL"
unzip -q jetbrains-mono.zip

echo "→ Installing JetBrains Mono fonts..."
find . -maxdepth 3 -type f \( -name "*.ttf" -o -name "*.otf" \) -print0 | while IFS= read -r -d '' f; do
    cp -v "$f" "$FONT_DIR/"
done

########################################
# 2. IBM Plex Mono
########################################
echo "→ Downloading IBM Plex Mono..."
# IBM Plex full zip from GitHub releases (mono is inside)
IBM_PLEX_URL="https://github.com/IBM/plex/releases/download/v6.3.0/TrueType.zip"

curl -L -o ibm-plex.zip "$IBM_PLEX_URL"
unzip -q ibm-plex.zip -d ibm-plex

echo "→ Installing IBM Plex Mono fonts..."
find ibm-plex -maxdepth 5 -type f -iname "IBMPlexMono-*.ttf" -print0 | while IFS= read -r -d '' f; do
    cp -v "$f" "$FONT_DIR/"
done

########################################
# 3. Hack
########################################
echo "→ Downloading Hack..."
HACK_URL="https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip"

curl -L -o hack.zip "$HACK_URL"
unzip -q hack.zip -d hack

echo "→ Installing Hack fonts..."
find hack -maxdepth 5 -type f -name "*.ttf" -print0 | while IFS= read -r -d '' f; do
    cp -v "$f" "$FONT_DIR/"
done

########################################
# Refresh font cache
########################################
echo "→ Refreshing font cache..."
fc-cache -f -v "$FONT_DIR"

########################################
# Optional: clean up layered RPM fonts
########################################
echo
read -rp "Do you want to remove rpm-ostree font packages from the host image now? [y/N] " answer
case "$answer" in
    [yY][eE][sS]|[yY])
        echo "→ Removing layered font RPMs via rpm-ostree..."
        sudo rpm-ostree uninstall ibm-plex-fonts-all jetbrains-mono-fonts source-foundry-hack-fonts || true
        echo "→ Done. You should reboot to use a deployment without those RPMs:"
        echo "   sudo systemctl reboot"
        ;;
    *)
        echo "→ Skipping rpm-ostree font cleanup. Fonts are still installed in \$HOME."
        ;;
esac

echo
echo "✅ Finished installing dev fonts into $FONT_DIR"
echo "You can now select JetBrains Mono / IBM Plex Mono / Hack in terminals & editors."
