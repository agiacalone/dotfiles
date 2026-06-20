#!/usr/bin/env bash
# Validates every themes/*.theme has all required keys + 16 hex colors.
set -u
cd "$(dirname "$0")/.." || exit 1
req_scalar="name background fg bg cursor selection"
fail=0; count=0
for f in *.theme; do
  [ -e "$f" ] || { echo "no palettes found"; exit 1; }
  count=$((count+1))
  for k in $req_scalar; do
    grep -qE "^$k=" "$f" || { echo "$f: missing $k"; fail=1; }
  done
  for n in $(seq 0 15); do
    grep -qE "^color$n=#[0-9A-Fa-f]{6}$" "$f" || { echo "$f: bad/missing color$n"; fail=1; }
  done
  grep -qE "^(nvim_colorscheme=|nvim_generate=mono)" "$f" || { echo "$f: missing nvim mapping"; fail=1; }
  grep -qE "^background=(dark|light)$" "$f" || { echo "$f: background must be dark|light"; fail=1; }
done
[ $fail -eq 0 ] && echo "OK: $count palettes valid"
exit $fail
