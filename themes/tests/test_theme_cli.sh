#!/usr/bin/env bash
set -u
export THEME_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
B="$THEME_ROOT/../bin/theme"
export THEME_STATE="$(mktemp)"; trap 'rm -f "$THEME_STATE"' EXIT
"$B" --no-emulator --quiet nord || { echo "switch failed"; exit 1; }
[ "$(cat "$THEME_STATE")" = "nord" ] || { echo "state not written"; exit 1; }
"$B" list | grep -qE '^\* nord$' || { echo "current not marked"; exit 1; }
[ "$("$B" list --names | wc -l | tr -d ' ')" -eq 12 ] || { echo "expected 12 names"; exit 1; }
"$B" --no-emulator --quiet next || { echo "next failed"; exit 1; }
[ "$(cat "$THEME_STATE")" != "nord" ] || { echo "next did not advance"; exit 1; }
"$B" --no-emulator badtheme 2>/dev/null && { echo "should reject unknown"; exit 1; }
# reapply must not change state
cur="$(cat "$THEME_STATE")"
"$B" --no-emulator --reapply phosphor-red >/dev/null
[ "$(cat "$THEME_STATE")" = "$cur" ] || { echo "reapply changed state"; exit 1; }
echo "OK"
