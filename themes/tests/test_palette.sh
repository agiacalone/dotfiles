#!/usr/bin/env bash
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$DIR/lib/palette.sh"
declare -A PAL
palette_load "$DIR/phosphor-amber.theme" || { echo "load failed"; exit 1; }
[ "${PAL[color15]}" = "#ffe2a8" ] || { echo "color15 wrong: ${PAL[color15]}"; exit 1; }
[ "${PAL[background]}" = "dark" ] || { echo "bg wrong"; exit 1; }
[ "$(palette_list | wc -l | tr -d ' ')" -ge 12 ] || { echo "expected >=12 themes"; exit 1; }
echo "OK"
