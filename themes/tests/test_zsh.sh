#!/usr/bin/env bash
# Lint .zshrc and verify the theme block wired correctly.
set -u
DF="$(cd "$(dirname "$0")/../.." && pwd)"
command -v zsh >/dev/null 2>&1 || { echo "SKIP: no zsh"; exit 0; }
zsh -n "$DF/.zshrc" || { echo "zshrc lint failed"; exit 1; }
grep -q '^theme() {' "$DF/.zshrc"                      || { echo "no theme() wrapper"; exit 1; }
grep -q 'command theme --reapply phosphor-red' "$DF/.zshrc" || { echo "no root-red guard"; exit 1; }
grep -q 'THEME_ROOT_RED' "$DF/.zshrc"                  || { echo "no THEME_ROOT_RED toggle"; exit 1; }
grep -q '_theme_dircolors' "$DF/.zshrc"                || { echo "no dircolors refresh"; exit 1; }
echo "OK"
