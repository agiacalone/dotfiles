-- ~/.config/nvim/lua/plugins/writing.lua
return {
  -- LaTeX
  {
    "lervag/vimtex",
    ft = { "tex" },
    config = function()
      vim.g.tex_flavor             = "latex"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_view_method     = "general"
      -- macOS: open with Preview (swap viewer to "skim" for SyncTeX support)
      -- Linux: open with Okular
      vim.g.vimtex_view_general_viewer = vim.fn.has("mac") == 1 and "open" or "okular"
    end,
  },

  -- Journal format
  { "junegunn/vim-journal" },

  -- Inform 7 interactive fiction
  { "lesliev/vim-inform7" },
}
