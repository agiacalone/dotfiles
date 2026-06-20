# themes/ — terminal theme switcher

Palette files are the single source of truth. `bin/theme` switches the live
terminal (OSC), tmux, neovim, and zsh in lockstep; `bin/theme-gen` turns a
palette into per-program artifacts. See the repo `README.md` for usage.

## Palette format (`<name>.theme`)

```
name=<name>
background=dark|light
color0..color15=#rrggbb        # 16 ANSI (0-7 normal, 8-15 bright)
fg=#rrggbb  bg=#rrggbb  cursor=#rrggbb  selection=#rrggbb
nvim_colorscheme=<plugin scheme>   # OR  nvim_generate=mono  (phosphor themes)
nvim_background=dark|light
tmux_accent=colorN                 # which ANSI slot drives tmux accents
```

Validate after editing: `bash tests/validate_palettes.sh`. Full suite:
`bash tests/run_all.sh`.

## Where colors come from

| Path | Mechanism |
|---|---|
| Emulator (Konsole, iTerm2, ShadowTerm/SwiftTerm) | OSC 4/10/11/12 emitted by `theme` (tmux-passthrough wrapped); also native profiles via `theme --install-profiles` |
| tmux | generated status conf + `window-style` (cell-painted background) |
| neovim | `theme-sync.lua` reads `~/.config/theme/current`, applies the mapped colorscheme (mono themes generated from the ramp) |
| zsh | `theme()` refreshes `LS_COLORS`; startup re-emits OSC for new windows |

## ShadowTerm (iOS) + mosh notes

- **SSH:** ShadowTerm is built on SwiftTerm, which implements OSC 4/10/11/12 and
  truecolor, so the live emulator repaint works over SSH.
- **mosh:** mosh replicates screen *cells*, not terminal state, so palette OSC is
  **dropped**. To keep themes correct under mosh, the generated tmux confs paint the
  pane background with `window-style "fg=…,bg=…"` (cells, which mosh syncs).
  truecolor cell rendering requires mosh ≥ 1.4.
- **External mosh** needs the router to forward UDP 60000–61000 → the server.
- ShadowTerm's own 16 built-in app themes are separate; with the above you don't
  need to match them by hand — tmux/nvim/ls carry the theme regardless.
