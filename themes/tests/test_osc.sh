#!/usr/bin/env bash
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$DIR/lib/palette.sh"; . "$DIR/lib/osc.sh"
declare -A PAL; palette_load "$DIR/phosphor-amber.theme"
out="$(TMUX='' osc_string | cat -v)"
echo "$out" | grep -q '4;0;#120a02' || { echo "missing color0 OSC"; exit 1; }
echo "$out" | grep -q '11;#120a02'  || { echo "missing bg OSC"; exit 1; }
echo "$out" | grep -q 'Ptmux' && { echo "should NOT wrap when TMUX unset"; exit 1; }
wrapped="$(TMUX='x' osc_string | cat -v)"
echo "$wrapped" | grep -q 'Ptmux' || { echo "should wrap under tmux"; exit 1; }
echo "OK"
