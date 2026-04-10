-- ~/.config/nvim/lua/plugins/git.lua
return {
  -- Git signs in gutter
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
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
          map({ "n", "v" }, "<leader>hs", gs.stage_hunk, "Stage hunk")
          map({ "n", "v" }, "<leader>hr", gs.reset_hunk, "Reset hunk")
          map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
          map("n", "<leader>hb", gs.blame_line,   "Blame line")
        end,
      })
    end,
  },

  -- Full git commands
  { "tpope/vim-fugitive" },
}
