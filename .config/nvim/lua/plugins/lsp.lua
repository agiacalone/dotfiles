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
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig", "hrsh7th/cmp-nvim-lsp" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "marksman",       -- Markdown
          "bashls",         -- Shell
          "texlab",         -- LaTeX
          -- clangd installed via system package manager (clang-tools-extra / Xcode CLT)
        },
        automatic_installation = true,
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local on_attach = function(_, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
        end
        map("gd",         vim.lsp.buf.definition,  "Go to Definition")
        map("K",          vim.lsp.buf.hover,        "Hover Documentation")
        map("gr",         vim.lsp.buf.references,   "Go to References")
        map("<leader>rn", vim.lsp.buf.rename,       "Rename")
        map("<leader>ca", vim.lsp.buf.code_action,  "Code Action")
      end

      -- Use native Neovim 0.11 LSP API (lspconfig provides server defaults,
      -- vim.lsp.config/enable replaces the deprecated lspconfig[server].setup())
      local servers = { "marksman", "bashls", "texlab", "clangd" }
      for _, server in ipairs(servers) do
        vim.lsp.config(server, { capabilities = capabilities, on_attach = on_attach })
      end
      vim.lsp.enable(servers)
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
      local sources = {}

      -- Only register sources where the underlying binary is installed
      local function add(builtin, bin)
        if vim.fn.executable(bin) == 1 then
          table.insert(sources, builtin)
        end
      end

      -- Markdown (builtins confirmed present in current none-ls)
      add(null_ls.builtins.diagnostics.markdownlint, "markdownlint")
      add(null_ls.builtins.diagnostics.vale,         "vale")
      -- Shell: shellcheck moved to none-ls-extras.nvim; bashls LSP handles diagnostics
      -- LaTeX: chktex moved to none-ls-extras.nvim; texlab LSP handles diagnostics
      -- C/C++: clangd LSP handles diagnostics

      null_ls.setup({ sources = sources })
    end,
  },
}
