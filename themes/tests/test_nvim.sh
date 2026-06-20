#!/usr/bin/env bash
# Headless test of theme-sync's monochrome path (no plugins needed).
set -u
command -v nvim >/dev/null 2>&1 || { echo "SKIP: nvim not installed"; exit 0; }
TR="$(cd "$(dirname "$0")/.." && pwd)"
ND="$(cd "$TR/../.config/nvim" && pwd)"
st="$(mktemp)"; trap 'rm -f "$st"' EXIT
echo phosphor-amber > "$st"
out="$(THEME_STATE="$st" THEME_ROOT="$TR" nvim --headless -u NONE \
  --cmd "set rtp+=$ND" \
  -c "lua require('theme-sync').apply()" \
  -c "lua local h=vim.api.nvim_get_hl(0,{name='Normal'}); io.stderr:write(('%06x'):format(h.fg or 0))" \
  -c "qa!" 2>&1)"
echo "$out" | grep -qi 'ffb000' || { echo "mono Normal fg wrong (want ffb000): [$out]"; exit 1; }
echo "OK"
