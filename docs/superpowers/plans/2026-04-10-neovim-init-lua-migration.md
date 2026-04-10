# Neovim init.lua Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate from a Vundle-based `.vimrc` to a modular `init.lua` config using lazy.nvim with Lua-native plugin replacements and full LSP support.

**Architecture:** Modular layout under `~/.config/nvim/` with `init.lua` as entry point, `lua/options.lua` and `lua/keymaps.lua` for core config, and `lua/plugins/*.lua` for plugin specs loaded by lazy.nvim. Each phase produces a working, usable config.

**Tech Stack:** Neovim, Lua, lazy.nvim, mason.nvim, nvim-lspconfig, nvim-cmp, LuaSnip, none-ls.nvim, lualine, nvim-tree, gitsigns

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `~/.config/nvim/init.lua` | Create | Bootstrap lazy.nvim, require options/keymaps, load plugins |
| `~/.config/nvim/lua/options.lua` | Create | All vim options (ported from .vimrc) |
| `~/.config/nvim/lua/keymaps.lua` | Create | Leader key, quality-of-life keybindings |
| `~/.config/nvim/lua/plugins/ui.lua` | Create | gruvbox, lualine, nvim-tree, indent-blankline, startify |
| `~/.config/nvim/lua/plugins/git.lua` | Create | gitsigns, vim-fugitive |
| `~/.config/nvim/lua/plugins/lsp.lua` | Create | mason, nvim-lspconfig, nvim-cmp, luasnip, none-ls + linters |
| `~/.config/nvim/lua/plugins/editing.lua` | Create | nvim-surround, tabular, vim-markdown, render-markdown, markdown-preview, obsession, prosession |
| `~/.config/nvim/lua/plugins/writing.lua` | Create | vimtex, vim-journal, vim-inform7 |
| `~/.config/nvim/lua/plugins/tmux.lua` | Create | vim-tmux-navigator, vim-tmux-focus-events, vmux-clipboard |
| `~/git/dotfiles/nvim/` | Create | Mirror of ~/.config/nvim/ for dotfiles repo |
| `~/git/dotfiles/.aliases` | Modify | Update vim alias from `nvim -u ~/.vimrc` to `nvim` |
| `~/git/dotfiles/.vimrc` | Modify | Strip to pure vim (remove neovim-specific settings) |

---

## Phase 1: Scaffold

### Task 1: Create directory structure

**Files:**
- Create: `~/.config/nvim/init.lua`
- Create: `~/.config/nvim/lua/options.lua`
- Create: `~/.config/nvim/lua/keymaps.lua`
- Create: `~/.config/nvim/lua/plugins/.gitkeep`

- [ ] **Step 1: Create directories**

```bash
mkdir -p ~/.config/nvim/lua/plugins
```

- [ ] **Step 2: Verify structure**

```bash
find ~/.config/nvim -type d
```

Expected output:
```
/home/anthony/.config/nvim
/home/anthony/.config/nvim/lua
/home/anthony/.config/nvim/lua/plugins
```

---

### Task 2: Write options.lua

**Files:**
- Create: `~/.config/nvim/lua/options.lua`

- [ ] **Step 1: Create options.lua**

```lua
-- ~/.config/nvim/lua/options.lua
local opt = vim.opt

opt.showmode     = false          -- lualine shows mode
opt.laststatus   = 2              -- always show status line
opt.tabstop      = 4
opt.softtabstop  = 4
opt.shiftwidth   = 4
opt.scrolloff    = 3              -- keep 3 lines when scrolling
opt.showcmd      = true
opt.hlsearch     = true
opt.incsearch    = true
opt.ruler        = true
opt.backup       = false
opt.ignorecase   = true
opt.title        = true
opt.modeline     = true
opt.modelines    = 3
opt.startofline  = false
opt.wrap         = true
opt.linebreak    = true
opt.textwidth    = 0
opt.colorcolumn  = "80"
opt.whichwrap    = "b,s,h,l,<,>,[,]"
opt.autoindent   = true
opt.smartindent  = true
opt.number       = true
opt.background   = "dark"
opt.wildmenu     = true
opt.showmatch    = true
opt.foldenable   = true
opt.foldlevelstart = 10
opt.foldnestmax  = 10
opt.foldmethod   = "indent"
opt.cursorline   = true
opt.swapfile     = false
opt.termguicolors = true
opt.autoread     = true           -- reload files changed outside vim (used by vim-tmux-focus-events)
opt.backspace    = "indent,eol,start"
opt.shortmess:append("atI")
```

- [ ] **Step 2: Verify no syntax errors**

```bash
nvim --headless -c "luafile ~/.config/nvim/lua/options.lua" -c "q" 2>&1
```

Expected: no output (silent = success)

---

### Task 3: Write keymaps.lua

**Files:**
- Create: `~/.config/nvim/lua/keymaps.lua`

- [ ] **Step 1: Create keymaps.lua**

```lua
-- ~/.config/nvim/lua/keymaps.lua
vim.g.mapleader      = " "
vim.g.maplocalleader = "\\"

local map = vim.keymap.set

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Better window navigation (fallback when not in tmux)
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Keep visual selection when indenting
map("v", "<", "<gv")
map("v", ">", ">gv")
```

- [ ] **Step 2: Verify no syntax errors**

```bash
nvim --headless -c "luafile ~/.config/nvim/lua/keymaps.lua" -c "q" 2>&1
```

Expected: no output

---

### Task 4: Bootstrap lazy.nvim and write init.lua

**Files:**
- Create: `~/.config/nvim/init.lua`

- [ ] **Step 1: Create init.lua**

```lua
-- ~/.config/nvim/init.lua

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to continue...", "ErrorMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Load core config
require("options")
require("keymaps")

-- Load plugins
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  checker = { enabled = true },
})
```

- [ ] **Step 2: Open neovim and verify lazy.nvim installs**

```bash
nvim
```

Expected: lazy.nvim clones itself, no error messages. `:Lazy` shows empty plugin list.

- [ ] **Step 3: Commit phase 1**

```bash
cd ~/git/dotfiles
mkdir -p nvim/lua/plugins
cp ~/.config/nvim/init.lua nvim/
cp ~/.config/nvim/lua/options.lua nvim/lua/
cp ~/.config/nvim/lua/keymaps.lua nvim/lua/
git add nvim/
git commit -S -m "nvim: phase 1 - scaffold init.lua, options, keymaps, lazy.nvim bootstrap"
```

---

## Phase 2: UI

### Task 5: Write plugins/ui.lua

**Files:**
- Create: `~/.config/nvim/lua/plugins/ui.lua`

- [ ] **Step 1: Create ui.lua**

```lua
-- ~/.config/nvim/lua/plugins/ui.lua
return {
  -- Colorscheme
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        italic = {
          strings   = true,
          emphasis  = true,
          comments  = true,
          operators = false,
          folds     = true,
        },
        bold = true,
      })
      vim.cmd("colorscheme gruvbox")
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "gruvbox" },
      })
    end,
  },

  -- File tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      vim.g.loaded_netrw       = 1
      vim.g.loaded_netrwPlugin = 1
      require("nvim-tree").setup()
      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>")
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup()
    end,
  },

  -- Start screen
  { "mhinz/vim-startify" },
}
```

- [ ] **Step 2: Open neovim and verify UI plugins install**

```bash
nvim
```

Expected: lazy.nvim installs all UI plugins. Gruvbox colorscheme loads, lualine appears at bottom, no errors.

- [ ] **Step 3: Verify nvim-tree works**

In neovim: press `<Space>e`

Expected: file tree opens on the left.

- [ ] **Step 4: Commit phase 2**

```bash
cp ~/.config/nvim/lua/plugins/ui.lua ~/git/dotfiles/nvim/lua/plugins/
cd ~/git/dotfiles
git add nvim/
git commit -S -m "nvim: phase 2 - UI plugins (gruvbox, lualine, nvim-tree, indent-blankline, startify)"
```

---

## Phase 3: LSP

### Task 6: Write plugins/lsp.lua

**Files:**
- Create: `~/.config/nvim/lua/plugins/lsp.lua`

- [ ] **Step 1: Create lsp.lua**

```lua
-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  -- Mason: LSP server manager
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- Bridge mason <-> lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "marksman",       -- Markdown
          "clangd",         -- C/C++
          "bashls",         -- Shell
          "texlab",         -- LaTeX
        },
        automatic_installation = true,
      })

      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local servers = { "marksman", "clangd", "bashls", "texlab" }
      for _, server in ipairs(servers) do
        lspconfig[server].setup({ capabilities = capabilities })
      end
    end,
  },

  -- LSP config
  { "neovim/nvim-lspconfig" },

  -- Snippets engine
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Linters / formatters bridge
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          -- Markdown
          null_ls.builtins.diagnostics.markdownlint,  -- comment out if markdownlint not installed
          null_ls.builtins.diagnostics.vale,           -- comment out if vale not installed
          -- Shell
          null_ls.builtins.diagnostics.shellcheck,
          -- C/C++
          null_ls.builtins.diagnostics.cppcheck,
          -- LaTeX
          null_ls.builtins.diagnostics.chktex,
        },
      })
    end,
  },
}
```

- [ ] **Step 2: Open neovim and verify LSP plugins install**

```bash
nvim
```

Expected: lazy.nvim installs mason, lspconfig, nvim-cmp, luasnip, none-ls. No errors.

- [ ] **Step 3: Verify mason installs LSP servers**

In neovim: `:Mason`

Expected: Mason window opens. `marksman`, `clangd`, `bashls`, `texlab` show as installed (may take a moment on first run).

- [ ] **Step 4: Verify LSP attaches to a file**

```bash
echo "# Hello" > /tmp/test.md && nvim /tmp/test.md
```

In neovim: `:LspInfo`

Expected: `marksman` shown as attached.

- [ ] **Step 5: Verify completion works**

In the test.md file, enter insert mode and type a word, then press `<C-Space>`.

Expected: completion popup appears.

- [ ] **Step 6: Commit phase 3**

```bash
cp ~/.config/nvim/lua/plugins/lsp.lua ~/git/dotfiles/nvim/lua/plugins/
cd ~/git/dotfiles
git add nvim/
git commit -S -m "nvim: phase 3 - LSP (mason, lspconfig, nvim-cmp, luasnip, none-ls, linters)"
```

---

## Phase 4: Git

### Task 7: Write plugins/git.lua

**Files:**
- Create: `~/.config/nvim/lua/plugins/git.lua`

- [ ] **Step 1: Create git.lua**

```lua
-- ~/.config/nvim/lua/plugins/git.lua
return {
  -- Git signs in gutter
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "+" },
          change       = { text = "~" },
          delete       = { text = "_" },
          topdelete    = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end
          map("n", "]c", gs.next_hunk,        "Next hunk")
          map("n", "[c", gs.prev_hunk,        "Prev hunk")
          map("n", "<leader>hs", gs.stage_hunk,   "Stage hunk")
          map("n", "<leader>hr", gs.reset_hunk,   "Reset hunk")
          map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
          map("n", "<leader>hb", gs.blame_line,   "Blame line")
        end,
      })
    end,
  },

  -- Full git commands
  { "tpope/vim-fugitive" },
}
```

- [ ] **Step 2: Open a file in a git repo and verify gitsigns**

```bash
nvim ~/git/dotfiles/.zshrc
```

Expected: `+`/`~`/`_` signs appear in the gutter for changed lines. `:Git` (fugitive) works.

- [ ] **Step 3: Commit phase 4**

```bash
cp ~/.config/nvim/lua/plugins/git.lua ~/git/dotfiles/nvim/lua/plugins/
cd ~/git/dotfiles
git add nvim/
git commit -S -m "nvim: phase 4 - git (gitsigns, fugitive)"
```

---

## Phase 5: Editing

### Task 8: Write plugins/editing.lua

**Files:**
- Create: `~/.config/nvim/lua/plugins/editing.lua`

- [ ] **Step 1: Create editing.lua**

```lua
-- ~/.config/nvim/lua/plugins/editing.lua
return {
  -- Surround motions (same muscle memory as vim-surround)
  { "kylechui/nvim-surround", config = function() require("nvim-surround").setup() end },

  -- Alignment
  { "godlygeek/tabular" },

  -- Markdown syntax
  {
    "plasticboy/vim-markdown",
    config = function()
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_conceal          = 0
    end,
  },

  -- Markdown rendering in buffer
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    config = function()
      require("render-markdown").setup()
    end,
  },

  -- Markdown live preview in browser
  {
    "iamcco/markdown-preview.nvim",
    cmd   = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init  = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },

  -- Session management
  { "tpope/vim-obsession" },
  {
    "dhruvasagar/vim-prosession",
    dependencies = { "tpope/vim-obsession" },
  },
}
```

- [ ] **Step 2: Open neovim and verify editing plugins install**

```bash
nvim
```

Expected: lazy.nvim installs all editing plugins. Note: `markdown-preview.nvim` runs `npm install` on first build — requires Node.js.

- [ ] **Step 3: Verify render-markdown works**

```bash
nvim /tmp/test.md
```

Expected: headings render with visual styling, code blocks highlighted.

- [ ] **Step 4: Verify markdown-preview works**

In neovim with test.md open: `:MarkdownPreview`

Expected: browser opens with live preview.

- [ ] **Step 5: Commit phase 5**

```bash
cp ~/.config/nvim/lua/plugins/editing.lua ~/git/dotfiles/nvim/lua/plugins/
cd ~/git/dotfiles
git add nvim/
git commit -S -m "nvim: phase 5 - editing (surround, markdown, render-markdown, markdown-preview, sessions)"
```

---

## Phase 6: Writing

### Task 9: Write plugins/writing.lua

**Files:**
- Create: `~/.config/nvim/lua/plugins/writing.lua`

- [ ] **Step 1: Create writing.lua**

```lua
-- ~/.config/nvim/lua/plugins/writing.lua
return {
  -- LaTeX
  {
    "lervag/vimtex",
    config = function()
      vim.g.tex_flavor = "latex"
    end,
  },

  -- Journal format
  { "junegunn/vim-journal" },

  -- Inform 7 interactive fiction
  { "lesliev/vim-inform7" },
}
```

- [ ] **Step 2: Open neovim and verify writing plugins install**

```bash
nvim
```

Expected: lazy.nvim installs vimtex, vim-journal, vim-inform7. No errors.

- [ ] **Step 3: Verify vimtex activates on a .tex file**

```bash
echo '\documentclass{article}\begin{document}Hello\end{document}' > /tmp/test.tex
nvim /tmp/test.tex
```

In neovim: `:echo g:vimtex_enabled`

Expected: `1`

- [ ] **Step 4: Commit phase 6**

```bash
cp ~/.config/nvim/lua/plugins/writing.lua ~/git/dotfiles/nvim/lua/plugins/
cd ~/git/dotfiles
git add nvim/
git commit -S -m "nvim: phase 6 - writing (vimtex, vim-journal, vim-inform7)"
```

---

## Phase 7: Tmux

### Task 10: Write plugins/tmux.lua

**Files:**
- Create: `~/.config/nvim/lua/plugins/tmux.lua`

- [ ] **Step 1: Create tmux.lua**

```lua
-- ~/.config/nvim/lua/plugins/tmux.lua
return {
  -- Seamless navigation between vim splits and tmux panes
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft", "TmuxNavigateDown",
      "TmuxNavigateUp",   "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<CR>" },
      { "<C-j>", "<cmd>TmuxNavigateDown<CR>" },
      { "<C-k>", "<cmd>TmuxNavigateUp<CR>" },
      { "<C-l>", "<cmd>TmuxNavigateRight<CR>" },
    },
  },

  -- Fix FocusGained/FocusLost events inside tmux (needed for autoread)
  { "tmux-plugins/vim-tmux-focus-events" },

  -- Tmux clipboard integration
  { "gsiano/vmux-clipboard" },
}
```

- [ ] **Step 2: Open neovim inside tmux and verify navigation**

```bash
tmux
nvim
```

Create a split in tmux (`prefix + |`), then press `<C-h>` from neovim.

Expected: focus moves to the tmux pane, not a vim split.

- [ ] **Step 3: Commit phase 7**

```bash
cp ~/.config/nvim/lua/plugins/tmux.lua ~/git/dotfiles/nvim/lua/plugins/
cd ~/git/dotfiles
git add nvim/
git commit -S -m "nvim: phase 7 - tmux (navigator, focus-events, vmux-clipboard)"
```

---

## Phase 8: Dotfiles Sync and Cleanup

### Task 11: Update vim alias

**Files:**
- Modify: `~/git/dotfiles/.aliases`

- [ ] **Step 1: Update the vim alias**

In `~/.aliases`, change:
```zsh
alias vim='nvim -u ~/.vimrc'
```
to:
```zsh
alias vim='nvim'
```

- [ ] **Step 2: Verify alias works**

```bash
source ~/.aliases
which vim
vim --version | head -1
```

Expected: `vim` resolves to nvim, version string shows NVIM.

---

### Task 12: Strip .vimrc to pure vim

**Files:**
- Modify: `~/git/dotfiles/.vimrc`

- [ ] **Step 1: Remove neovim-specific settings from .vimrc**

Remove these lines — they are no-ops or harmful in traditional vim when neovim reads them, and belong only in the nvim config:

```vim
" Remove these lines:
if (has("termguicolors"))
    set termguicolors
endif

let &t_ZH="\e[3m"
let &t_ZR="\e[23m"

let $NVIM_TUI_ENABLE_TRUE_COLOR=1
```

Add a header comment so future maintainers know this is vim-only:

```vim
" .vimrc — traditional vim config (legacy systems without neovim)
" For neovim, see ~/.config/nvim/init.lua
```

- [ ] **Step 2: Verify vim still loads cleanly (if vim is available)**

```bash
vim --version | head -1
vim -c "q" 2>&1
```

Expected: no errors on startup.

---

### Task 13: Final dotfiles sync and commit

**Files:**
- Modify: `~/git/dotfiles/nvim/` (ensure fully in sync)
- Modify: `~/git/dotfiles/.aliases`
- Modify: `~/git/dotfiles/.vimrc`

- [ ] **Step 1: Sync all nvim config to dotfiles repo**

```bash
rsync -av ~/.config/nvim/ ~/git/dotfiles/nvim/
```

- [ ] **Step 2: Copy updated .aliases and .vimrc**

```bash
cp ~/.aliases ~/git/dotfiles/.aliases
cp ~/.vimrc ~/git/dotfiles/.vimrc
```

- [ ] **Step 3: Review diff**

```bash
cd ~/git/dotfiles && git diff
```

- [ ] **Step 4: Commit**

```bash
cd ~/git/dotfiles
git add nvim/ .aliases .vimrc
git commit -S -m "nvim: phase 8 - dotfiles sync, update vim alias, strip .vimrc to pure vim"
```

- [ ] **Step 5: Run :checkhealth in neovim**

```bash
nvim -c "checkhealth" -c "q"
```

Review output for any warnings. Common acceptable warnings: missing optional tools, clipboard providers on headless systems.
