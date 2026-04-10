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
      { "<C-h>",  "<cmd>TmuxNavigateLeft<CR>" },
      { "<C-j>",  "<cmd>TmuxNavigateDown<CR>" },
      { "<C-k>",  "<cmd>TmuxNavigateUp<CR>" },
      { "<C-l>",  "<cmd>TmuxNavigateRight<CR>" },
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<CR>" },
    },
  },

  -- Fix FocusGained/FocusLost events inside tmux (needed for autoread)
  { "tmux-plugins/vim-tmux-focus-events", event = "VeryLazy" },

  -- Tmux clipboard integration
  { "gsiano/vmux-clipboard" },
}
