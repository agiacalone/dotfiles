# Neovim init.lua Migration Design

**Date:** 2026-04-10
**Status:** Approved

## Overview

Migrate from a Vundle-based `.vimrc` shared between vim and neovim to a modular
`init.lua` config using lazy.nvim, with Lua-native plugin replacements where
available. The `.vimrc` is retained as a standalone legacy vim config for systems
without neovim. The `vim` shell alias is updated to point to `nvim` directly.

## Directory Structure

```
~/.config/nvim/
├── init.lua              ← bootstraps lazy.nvim, requires all modules
├── lua/
│   ├── options.lua       ← vim options (ported from .vimrc)
│   ├── keymaps.lua       ← keybindings
│   └── plugins/
│       ├── ui.lua        ← lualine, gruvbox, nvim-tree, indent-blankline, startify
│       ├── git.lua       ← gitsigns, fugitive
│       ├── lsp.lua       ← mason, nvim-lspconfig, nvim-cmp, luasnip, none-ls
│       ├── editing.lua   ← nvim-surround, tabular, vim-markdown, render-markdown,
│       │                    markdown-preview, obsession, prosession
│       ├── writing.lua   ← vimtex, vim-journal, vim-inform7
│       └── tmux.lua      ← vim-tmux-navigator, vim-tmux-focus-events, vmux-clipboard
```

Mirrored in the dotfiles repo under `nvim/`.

## Plugin Modernization

### Replaced with Lua-native equivalents

| Old | New | Reason |
|-----|-----|--------|
| `lightline` | `lualine.nvim` | Lua-native, faster, more extensible |
| `NERDTree` + `vim-nerdtree-syntax-highlight` | `nvim-tree.lua` | Lua-native, async, actively maintained |
| `vim-gitgutter` | `gitsigns.nvim` | Lua-native, significantly faster |
| `ALE` | `mason.nvim` + `nvim-lspconfig` + `nvim-cmp` | Built-in LSP, proper completion |
| `ultisnips` + `vim-snippets` | `luasnip` + `friendly-snippets` | Lua-native, integrates with nvim-cmp |
| `indentLine` | `indent-blankline.nvim` | Lua rewrite of the same plugin |
| `vim-surround` | `nvim-surround` | Lua rewrite, same muscle memory |
| `gruvbox` | `gruvbox.nvim` | Lua port, same look |

### Dropped

- `seti.vim`, `night-owl.vim` — unused themes

### Retained as-is

- `vim-fugitive` — still best-in-class git plugin
- `vimtex` — no meaningful Lua alternative
- `tabular` — no Lua alternative
- `vim-markdown` — kept alongside render-markdown
- `vim-obsession` + `vim-prosession` — session management, no Lua alternative
- `vim-journal` — specialty format
- `vim-inform7` — specialty format
- `vmux-clipboard` — tmux clipboard integration
- `vim-tmux-navigator` — tmux pane navigation
- `vim-tmux-focus-events` — focus event fix for tmux
- `vim-startify` — start screen

### New additions

- `render-markdown.nvim` — renders markdown visually in-buffer
- `markdown-preview.nvim` — live browser preview with synced scroll

## LSP Configuration

Servers managed by `mason.nvim`, auto-installed on first launch:

| Language | Server | Notes |
|----------|--------|-------|
| Markdown | `marksman` | Project-aware markdown LSP |
| C/C++ | `clangd` | Pairs with `bear` for compile commands |
| Shell | `bash-language-server` | Covers bash/zsh scripts |
| LaTeX | `texlab` | Pairs with vimtex |

Linters via `none-ls.nvim`:

| Tool | Language | Purpose |
|------|----------|---------|
| `vale` | Markdown/prose | Style and grammar linting |
| `markdownlint` | Markdown | Structure and formatting |
| `shellcheck` | Shell | Common scripting bug detection |
| `cppcheck` | C/C++ | Static analysis on top of clangd |
| `chktex` | LaTeX | Style linting |

Completion via `nvim-cmp`: LSP + luasnip snippets + buffer words.

## Implementation Phases

| Phase | Contents | End State |
|-------|----------|-----------|
| 1 | Scaffold: `init.lua`, `options.lua`, `keymaps.lua`, lazy.nvim bootstrap | Working neovim, no plugins |
| 2 | UI: gruvbox, lualine, nvim-tree, indent-blankline, startify | Looks and feels right |
| 3 | LSP: mason, nvim-lspconfig, nvim-cmp, luasnip, none-ls + all linters | Full language intelligence |
| 4 | Git: gitsigns, fugitive | Git workflow intact |
| 5 | Editing: nvim-surround, tabular, vim-markdown, render-markdown, markdown-preview, obsession, prosession | Writing workflow complete |
| 6 | Writing: vimtex, vim-journal, vim-inform7 | LaTeX + specialty formats |
| 7 | Tmux: navigator, focus-events, vmux-clipboard | Tmux integration restored |
| 8 | Dotfiles: add `nvim/` to repo, strip `.vimrc` to pure vim, update `vim` alias | Everything synced |

Each phase produces a working, usable config before the next begins.

## Dotfiles Integration

- `~/git/dotfiles/nvim/` mirrors `~/.config/nvim/`
- `.vimrc` stripped of neovim-specific settings, kept as standalone legacy config
- `alias vim='nvim'` replaces `alias vim='nvim -u ~/.vimrc'` in `.aliases`
- All changes committed with PGP signing per repo convention
