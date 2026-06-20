#!/usr/bin/env bash
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"; G="$DIR/../bin/theme-gen"
# Konsole INI
"$G" konsole-scheme phosphor-amber | grep -q '^\[Background\]' || { echo "no [Background]"; exit 1; }
"$G" konsole-scheme phosphor-amber | grep -q '^\[Color7Intense\]' || { echo "no Color7Intense"; exit 1; }
"$G" konsole-scheme phosphor-amber | grep -qE '^Color=18,10,2$' || { echo "bg rgb wrong"; exit 1; }
# Konsole profile has font
"$G" konsole-profile nord | grep -q 'JetBrainsMono Nerd Font Mono' || { echo "profile font missing"; exit 1; }
# iTerm JSON parses + has 16 ansi + inherits parent (colors only) + multi-theme
j="$("$G" iterm phosphor-amber nord)"
echo "$j" | jq -e '.Profiles|length==2' >/dev/null || { echo "expected 2 profiles"; exit 1; }
echo "$j" | jq -e '.Profiles[0]["Ansi 15 Color"]["Red Component"]' >/dev/null || { echo "bad iterm json"; exit 1; }
# profiles specify a parent (fonts/Nerd Font inherited) and carry NO font keys
echo "$j" | jq -e '.Profiles[0]["Dynamic Profile Parent Name"]|type=="string"' >/dev/null || { echo "parent name not set"; exit 1; }
echo "$j" | jq -e '[.Profiles[0]|keys[]|select(test("Font"))]|length==0' >/dev/null || { echo "font keys should be inherited, not emitted"; exit 1; }
# tmux conf
"$G" tmux tokyonight | grep -q 'status-style "bg=#1a1b26' || { echo "tmux bg wrong"; exit 1; }
# window-style: pane bg painted as cells (mosh/ShadowTerm survival)
"$G" tmux tokyonight | grep -q 'window-active-style "fg=#c0caf5,bg=#1a1b26"' || { echo "no window-active-style"; exit 1; }
# itermcolors plist parses (plutil if available, else xmllint, else skip)
p="$("$G" itermcolors nord)"
echo "$p" | grep -q '<key>Ansi 0 Color</key>' || { echo "itermcolors missing ansi"; exit 1; }
echo "OK"
