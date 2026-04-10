-- ~/.config/nvim/lua/keymaps.lua
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
