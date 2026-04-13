# Terminal Modernization Notes

This setup is already close to a good "modern classic" baseline:

- Shell: `zsh` with `oh-my-zsh`, `powerlevel10k`, syntax highlighting, autosuggestions
- Multiplexer: `tmux` with theme switching and plugin support
- Terminal: iTerm2 with a Nerd Font profile (`JetBrainsMonoNFM-Regular 15`)

Terminal-specific behavior is kept out of the shared shell config. Anything that is not expected to work across both iTerm2 and Konsole belongs in an OS-specific file such as `~/.zshrc.macos`, `~/.zshrc.linux`, or `~/.zshrc.fedora`.

## What changed in dotfiles

- `zsh` startup now initializes Homebrew and completions in one place.
- History is larger, shared across sessions, and duplicate-heavy entries are reduced.
- Completion menus are more forgiving and case-insensitive.
- Optional integrations for `eza`, `bat`, `fzf`, `zoxide`, and `atuin` are enabled only when those tools are installed.
- iTerm2 shell integration is now gated so it only loads when `TERM_PROGRAM=iTerm.app`.
- `tmux` now keeps deeper history, renumbers windows, handles focus changes, reloads quickly, and has cleaner vi-style copy bindings.

## iTerm2 recommendations

These are the settings I would use for the "modern classic" look you described.

- Profile: keep `Personal` as the daily profile.
- Font: keep `JetBrainsMono Nerd Font` around `14-15pt`.
- Scrollback: raise from `1000` to at least `20000`.
- Cursor: keep a box cursor for the classic feel.
- Transparency: keep `0`; crisp text fits the classic aesthetic better.
- Window appearance: enable a subtle status bar, not a heavy tab chrome.
- Selection: keep semantic history enabled so file paths and URLs remain clickable.
- Keys: map left/right `Option` to `Esc+` if you want stronger readline and vim-style movement.
- Startup: keep shell integration enabled; it pairs well with `tmux`.

## Optional installs

If you want the shell config to light up more features, these are the highest-value additions:

```bash
brew install eza bat fzf zoxide atuin
$(brew --prefix)/opt/fzf/install
```

What each adds:

- `eza`: modern file listings without losing the old `ls` muscle memory
- `bat`: readable file previews with syntax highlighting
- `fzf`: fast fuzzy history, file, and directory selection
- `zoxide`: better directory jumping
- `atuin`: searchable shell history across sessions

## Practical daily flow

This is the usage model the config now leans toward:

- `tmux` for long-lived sessions
- `C-a` as primary prefix, preserving your existing habits
- `j <partial-dir>` if `zoxide` is installed
- `lt` for a quick directory tree if `eza` is installed
- `prefix + r` to reload tmux after edits
- `view file.txt` for a highlighted read-only preview if `bat` is installed
