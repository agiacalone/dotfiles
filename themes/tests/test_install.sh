#!/usr/bin/env bash
# Verify `theme --install-profiles` writes the per-OS native profiles + committed itermcolors.
set -u
TR="$(cd "$(dirname "$0")/.." && pwd)"
B="$TR/../bin/theme"
H="$(mktemp -d)"; trap 'rm -rf "$H"' EXIT
THEME_ROOT="$TR" HOME="$H" "$B" --quiet --install-profiles
case "$(uname -s)" in
  Linux)
    [ -r "$H/.local/share/konsole/nord.colorscheme" ] || { echo "no konsole colorscheme"; exit 1; }
    [ -r "$H/.local/share/konsole/Theme nord.profile" ] || { echo "no konsole profile"; exit 1; }
    grep -q 'JetBrainsMono' "$H/.local/share/konsole/Theme nord.profile" || { echo "profile font missing"; exit 1; } ;;
  Darwin)
    j="$H/Library/Application Support/iTerm2/DynamicProfiles/readest-themes.json"
    [ -r "$j" ] && jq -e '.Profiles|length>=12' "$j" >/dev/null || { echo "bad dynamic profile"; exit 1; } ;;
esac
[ -r "$TR/generated/nord.itermcolors" ] || { echo "no generated itermcolors"; exit 1; }
echo "OK"
