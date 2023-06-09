-- Dev core
-- Things that are just there.

--    Sections:
--       ## TREE SITTER
--       -> nvim-treesitter                [syntax highlight]
--       -> nvim-ts-autotag                [treesitter understand html tags]
--       -> nvim-ts-context-commentstring  [treesitter comments]
--       -> nvim-colorizer                 [hex colors]
--       -> nvim-surround                  [surround stuff]

--       ## LSP
--       -> SchemaStore.nvim               [lsp schema manager]
--       -> mason.nvim                     [lsp package manager]
--       -> nvim-lspconfig                 [lsp config]
--       -> null-ls                        [code formatting]

--       ## AUTO COMPLETON
--       -> nvim-cmp                       [auto completion engine]
--       -> cmp-nvim-buffer                [auto completion buffer]
--       -> cmp-nvim-path                  [auto completion path]
--       -> cmp-nvim-lsp                   [auto completion lsp]
--       -> cmp-luasnip                    [auto completion snippets]

--       ## USER
--       -> flash.nvim                     [search jump and f jump]

return {
  {
    --  PURE CORE -------------------------------------------------------------
    --  [syntax highlight] + [treesitter understand html tags] + [comments]
    --  https://github.com/nvim-treesitter/nvim-treesitter
    --  https://github.com/windwp/nvim-ts-autotag
    --  https://github.com/JoosepAlviste/nvim-ts-context-commentstring

    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "windwp/nvim-ts-autotag",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    event = "User BaseFile",
    cmd = {
      "TSBufDisable",
      "TSBufEnable",
      "TSBufToggle",
      "TSDisable",
      "TSEnable",
      "TSToggle",
      "TSInstall",
      "TSInstallInfo",
      "TSInstallSync",
      "TSModuleInfo",
      "TSUninstall",
      "TSUpdate",
      "TSUpdateSync",
    },
    build = ":TSUpdate",
    opts = {
      highlight = {
        enable = true,
        disable = function(_, bufnr)
          return vim.api.nvim_buf_line_count(bufnr) > 10000
        end,
      },
      matchup = {
        enable = true,
        enable_quotes = true,
      },
      ensure_installed = { "c", "lua", "ocaml", "vimdoc", "vim", "bash", "markdown", "norg" },
      incremental_selection = { enable = true },
      indent = { enable = true },
      autotag = { enable = true },
      context_commentstring = { enable = true, enable_autocmd = false },
      auto_install = true, -- Install a parser for the current language if not present.
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
      vim.cmd ""
    end,
  },

  --  [hex colors]
  --  https://github.com/NvChad/nvim-colorizer.lua
  {
    "NvChad/nvim-colorizer.lua",
    event = "User BaseFile",
    cmd = {
      "ColorizerToggle",
      "ColorizerAttachToBuffer",
      "ColorizerDetachFromBuffer",
      "ColorizerReloadAllBuffers",
    },
    opts = { user_default_options = { names = false } },
  },

  -- nvim-surround [surround stuff]
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end,
  },

  --  LSP -------------------------------------------------------------------
  --  Schema Store [lsp schema manager]
  --  https://github.com/b0o/SchemaStore.nvim
  {
    "b0o/SchemaStore.nvim",
    {
      "folke/neodev.nvim",
      opts = {
        override = function(root_dir, library)
          for _, base_config in ipairs(base.supported_configs) do
            if root_dir:match(base_config) then
              library.plugins = true
              break
            end
          end
          vim.b.neodev_enabled = library.enabled
        end,
      },
    },

    --  Syntax highlight [lsp package manager]
    --  https://github.com/williamboman/mason.nvim
    {
      "williamboman/mason.nvim",
      cmd = {
        "Mason",
        "MasonInstall",
        "MasonUninstall",
        "MasonUninstallAll",
        "MasonLog",
        "MasonUpdate",
        "MasonUpdateAll",
      },
      opts = {
        ui = {
          icons = {
            package_installed = "✓",
            package_uninstalled = "✗",
            package_pending = "⟳",
          },
        },
      },
      build = ":MasonUpdate",
      config = function(_, opts)
        require("mason").setup(opts)

        -- TODO: change these auto command names to not conflict with core Mason commands
        local cmd = vim.api.nvim_create_user_command
        cmd("MasonUpdate", function(options) require("base.utils.mason").update(options.fargs) end, {
          nargs = "*",
          desc = "Update Mason Package",
          complete = function(arg_lead)
            local _ = require "mason-core.functional"
            return _.sort_by(
              _.identity,
              _.filter(_.starts_with(arg_lead), require("mason-registry").get_installed_package_names())
            )
          end,
        })
        cmd(
          "MasonUpdateAll",
          function() require("base.utils.mason").update_all() end,
          { desc = "Update Mason Packages" }
        )

        for _, plugin in ipairs {
          "mason-lspconfig",
          "mason-null-ls",
          "mason-nvim-dap",
        } do
          pcall(require, plugin)
        end
      end,
    },

    --  Syntax highlight [lsp config]
    --  https://github.com/nvim-lspconfig
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        {
          "williamboman/mason-lspconfig.nvim",
          cmd = { "LspInstall", "LspUninstall" },
          opts = function(_, opts)
            opts.ensure_installed = {
              "clangd", "lua_ls", "marksman", "bashls"
            }
            if not opts.handlers then opts.handlers = {} end
            opts.handlers[1] = function(server)
              require("base.utils.lsp").setup(server)
            end
          end,
          config = function(_, opts)
            require("mason-lspconfig").setup(opts)
            require("base.utils").event "MasonLspSetup"
          end,
        },
      },
      event = "User BaseFile",
      config = function(_, _)
        local lsp = require "base.utils.lsp"
        local utils = require "base.utils"
        local get_icon = require("base.utils").get_icon
        local signs = {
          {
            name = "DiagnosticSignError",
            text = get_icon "DiagnosticError",
            texthl = "DiagnosticSignError",
          },
          {
            name = "DiagnosticSignWarn",
            text = get_icon "DiagnosticWarn",
            texthl = "DiagnosticSignWarn",
          },
          {
            name = "DiagnosticSignHint",
            text = get_icon "DiagnosticHint",
            texthl = "DiagnosticSignHint",
          },
          {
            name = "DiagnosticSignInfo",
            text = get_icon "DiagnosticInfo",
            texthl = "DiagnosticSignInfo",
          },
          {
            name = "DapStopped",
            text = get_icon "DapStopped",
            texthl = "DiagnosticWarn",
          },
          {
            name = "DapBreakpoint",
            text = get_icon "DapBreakpoint",
            texthl = "DiagnosticInfo",
          },
          {
            name = "DapBreakpointRejected",
            text = get_icon "DapBreakpointRejected",
            texthl = "DiagnosticError",
          },
          {
            name = "DapBreakpointCondition",
            text = get_icon "DapBreakpointCondition",
            texthl = "DiagnosticInfo",
          },
          {
            name = "DapLogPoint",
            text = get_icon "DapLogPoint",
            texthl = "DiagnosticInfo",
          },
        }

        for _, sign in ipairs(signs) do
          vim.fn.sign_define(sign.name, sign)
        end
        lsp.setup_diagnostics(signs)

        local orig_handler = vim.lsp.handlers["$/progress"]
        vim.lsp.handlers["$/progress"] = function(_, msg, info)
          local progress, id = base.lsp.progress, ("%s.%s"):format(info.client_id, msg.token)
          progress[id] = progress[id] and utils.extend_tbl(progress[id], msg.value) or msg.value
          if progress[id].kind == "end" then
            vim.defer_fn(function()
              progress[id] = nil
              utils.event "LspProgress"
            end, 100)
          end
          utils.event "LspProgress"
          orig_handler(_, msg, info)
        end

        -- if vim.g.lsp_handlers_enabled then
        --   vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        --     vim.lsp.handlers.hover,
        --     { border = "rounded", silent = true }
        --   )
        --   vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        --     vim.lsp.handlers.signature_help,
        --     { border = "rounded", silent = true }
        --   )
        -- end
        local setup_servers = function()
          vim.api.nvim_exec_autocmds("FileType", {})
          require("base.utils").event "LspSetup"
        end
        if require("base.utils").is_available "mason-lspconfig.nvim" then
          vim.api.nvim_create_autocmd("User", {
            pattern = "BaseMasonLspSetup",
            once = true,
            callback = setup_servers,
          })
        else
          setup_servers()
        end
      end,
    },

    --  null ls [code formatting]
    --  https://github.com/jose-elias-alvarez/null-ls.nvim
    {
      "jose-elias-alvarez/null-ls.nvim",
      dependencies = {
        {
          "jay-babu/mason-null-ls.nvim",
          cmd = { "NullLsInstall", "NullLsUninstall" },
          opts = {
            handlers = {},
            ensure_installed = { "prettierd", "clang-format", "beautysh" }
          },
          config = function(_, opts)
            require("mason-null-ls").setup(opts)
          end,
        },
      },
      event = "User File",
      opts = function()
        local nls = require "null-ls"
        return {
          sources = {
            nls.builtins.formatting.beautysh.with {
              command = "beautysh",
              args = {
                "--indent-size=2",
                "$FILENAME",
              },
            },
          },
          on_attach = require("base.utils.lsp").on_attach,
        }
      end,
    },

    --  AUTO COMPLETION --------------------------------------------------------
    --  Auto completion engine [autocompletion engine]
    --  https://github.com/hrsh7th/nvim-cmp
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-nvim-lsp",
      },
      event = "InsertEnter",
      opts = function()
        local cmp = require "cmp"
        local snip_status_ok, luasnip = pcall(require, "luasnip")
        local utils = require "base.utils"
        local lspkind_status_ok, lspkind = pcall(require, "lspkind")
        if not snip_status_ok then return end

        local function has_words_before()
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0
              and vim.api
              .nvim_buf_get_lines(0, line - 1, line, true)[1]
              :sub(col, col)
              :match "%s"
              == nil
        end

        local function border(hl_name)
          return {
            { "╭", hl_name },
            { "─", hl_name },
            { "╮", hl_name },
            { "│", hl_name },
            { "╯", hl_name },
            { "─", hl_name },
            { "╰", hl_name },
            { "│", hl_name },
          }
        end

        return {
          enabled = function()
            local dap_prompt = utils.is_available "cmp-dap" -- add interoperability with cmp-dap
                and vim.tbl_contains(
                  { "dap-repl", "dapui_watches", "dapui_hover" },
                  vim.api.nvim_get_option_value("filetype", { buf = 0 })
                )
            if
                vim.api.nvim_get_option_value("buftype", { buf = 0 })
                == "prompt"
                and not dap_prompt
            then
              return false
            end

            return vim.g.cmp_enabled
          end,
          preselect = cmp.PreselectMode.None,
          formatting = {
            fields = { "abbr", "kind", "menu" },
            format = function(_, item)
              local icons = lspkind.presets.default
              local icon = icons[item.kind] or ""

              icon = lspkind_status_ok and (" " .. icon .. " ") or icon
              item.kind = string.format("%s %s", icon, item.kind or "")

              return item
            end,
          },
          snippet = {
            expand = function(args) luasnip.lsp_expand(args.body) end,
          },
          duplicates = {
            nvim_lsp = 1,
            luasnip = 1,
            cmp_tabnine = 1,
            buffer = 1,
            path = 1,
          },
          confirm_opts = {
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
          },
          completion = {
            completeopt = "menu,menuone",
          },
          window = {
            completion = {
              side_padding = 1,
              border = border "CmpDocBorder",
              winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
              scrollbar = false,
            },
            documentation = {
              border = border "CmpDocBorder",
              winhighlight = "Normal:CmpDoc",
            },
          },
          mapping = {
            ["<PageUp>"] = cmp.mapping.select_prev_item {
              behavior = cmp.SelectBehavior.Select,
              count = 8,
            },
            ["<PageDown>"] = cmp.mapping.select_next_item {
              behavior = cmp.SelectBehavior.Select,
              count = 8,
            },
            ["<C-PageUp>"] = cmp.mapping.select_prev_item {
              behavior = cmp.SelectBehavior.Select,
              count = 16,
            },
            ["<C-PageDown>"] = cmp.mapping.select_next_item {
              behavior = cmp.SelectBehavior.Select,
              count = 16,
            },
            ["<S-PageUp>"] = cmp.mapping.select_prev_item {
              behavior = cmp.SelectBehavior.Select,
              count = 16,
            },
            ["<S-PageDown>"] = cmp.mapping.select_next_item {
              behavior = cmp.SelectBehavior.Select,
              count = 16,
            },
            ["<Up>"] = cmp.mapping.select_prev_item {
              behavior = cmp.SelectBehavior.Select,
            },
            ["<Down>"] = cmp.mapping.select_next_item {
              behavior = cmp.SelectBehavior.Select,
            },
            ["<C-p>"] = cmp.mapping.select_prev_item {
              behavior = cmp.SelectBehavior.Insert,
            },
            ["<C-n>"] = cmp.mapping.select_next_item {
              behavior = cmp.SelectBehavior.Insert,
            },
            ["<C-k>"] = cmp.mapping.select_prev_item {
              behavior = cmp.SelectBehavior.Insert,
            },
            ["<C-j>"] = cmp.mapping.select_next_item {
              behavior = cmp.SelectBehavior.Insert,
            },
            ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
            ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
            ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
            ["<C-y>"] = cmp.config.disable,
            ["<C-e>"] = cmp.mapping {
              i = cmp.mapping.abort(),
              c = cmp.mapping.close(),
            },
            ["<CR>"] = cmp.mapping.confirm { select = false },
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              elseif has_words_before() then
                cmp.complete()
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" }),
          },
          sources = cmp.config.sources {
            { name = "nvim_lsp", priority = 1000 },
            { name = "luasnip",  priority = 750 },
            { name = "buffer",   priority = 500 },
            { name = "path",     priority = 250 },
          },
          sorting = {
            -- TODO: Would be cool to add stuff like "See variable names before method names" in rust, or something like that.
            comparators = {
              cmp.config.compare.offset,
              cmp.config.compare.exact,
              cmp.config.compare.score,

              function(entry1, entry2)
                local _, entry1_under = entry1.completion_item.label:find "^_+"
                local _, entry2_under = entry2.completion_item.label:find "^_+"
                entry1_under = entry1_under or 0
                entry2_under = entry2_under or 0
                if entry1_under > entry2_under then
                  return false
                elseif entry1_under < entry2_under then
                  return true
                end
              end,

              cmp.config.compare.kind,
              cmp.config.compare.sort_text,
              cmp.config.compare.length,
              cmp.config.compare.order,
            },
          },
          experimental = {
            native_menu = false
          }
        }
      end,
    },
  }, -- end of collection

  -- USER
  -- flash.nvim [search jump and f jump]
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          -- default options: exact mode, multi window, all directions, with a backdrop
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
    },
  },

  {
    "lewis6991/hover.nvim",
    event = "VeryLazy",
    config = function()
      require("hover").setup {
        init = function()
          -- Require providers
          require("hover.providers.lsp")
          require('hover.providers.gh')
          -- require('hover.providers.gh_user')
          -- require('hover.providers.jira')
          -- require('hover.providers.man')
          require('hover.providers.dictionary')
        end,
        preview_opts = {
          border = "rounded"
        },
        -- Whether the contents of a currently open hover window should be moved
        -- to a :h preview-window when pressing the hover keymap.
        preview_window = false,
        title = true
      }

      -- Setup keymaps
      vim.keymap.set("n", "K", require("hover").hover, { desc = "hover.nvim" })
      vim.keymap.set("n", "gK", require("hover").hover_select, { desc = "hover.nvim (select)" })
    end
  }

} -- end of return
