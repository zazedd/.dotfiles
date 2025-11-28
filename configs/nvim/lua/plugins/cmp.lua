return {

  {
    "saghen/blink.cmp",
    enabled = true,
    lazy = false, -- lazy loading handled internally
    -- optional: provides snippets for the snippet source
    dependencies = { "rafamadriz/friendly-snippets", "onsails/lspkind.nvim" },

    -- use a release tag to download pre-built binaries
    version = "1.*",
    -- OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',

    opts = {
      completion = {
        menu = {
          -- Don't automatically show the completion menu
          auto_show = false,

          -- nvim-cmp style menu
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", "kind" }
            },
          }
        },

        documentation = { auto_show = true, auto_show_delay_ms = 500 },
      },

      signature = { enabled = true },

      keymap = { preset = "enter" },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },

      -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- adjusts spacing to ensure icons are aligned
      appearance = {
        nerd_font_variant = "mono",
      },

      -- experimental auto-brackets support
      -- accept = { auto_brackets = { enabled = true } }
    },
  },

  {
    "onsails/lspkind.nvim",
    opts = {
      mode = "symbol",
      symbol_map = {
        Array = "󰅪",
        Boolean = "⊨",
        Class = "󰌗",
        Constructor = "",
        Key = "󰌆",
        Namespace = "󰅪",
        Null = "NULL",
        Number = "#",
        Object = "󰀚",
        Package = "󰏗",
        Property = "",
        Reference = "",
        Snippet = "",
        String = "󰀬",
        TypeParameter = "󰊄",
        Unit = "",
      },
      menu = {},
    },
    -- enabled = vim.g.icons_enabled,
    enabled = false,
    config = function(_, opts)
      require("lspkind").init(opts)
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    enabled = false,
    opts = function()
      local cmp = require("cmp")
      local snip_status_ok, luasnip = pcall(require, "luasnip")
      if not snip_status_ok then
        return
      end
      local lspkind_status_ok, lspkind = pcall(require, "lspkind")

      local function has_words_before()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local function border_n(hl_name)
        return {
          { "┏", hl_name },
          { "━", hl_name },
          { "┓", hl_name },
          { "┃", hl_name },
          { "┛", hl_name },
          { "━", hl_name },
          { "┗", hl_name },
          { "┃", hl_name },
        }
      end

      local function border_d(hl_name)
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
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
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
            border = border_n("CmpDocBorder"),
            -- winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
            winhighlight = "Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None",
            scrollbar = false,
          },
          documentation = {
            border = border_d("CmpDocBorder"),
            winhighlight = "Normal:CmpDoc",
          },
        },
        mapping = {
          ["<PageUp>"] = cmp.mapping.select_prev_item({
            behavior = cmp.SelectBehavior.Select,
            count = 8,
          }),
          ["<PageDown>"] = cmp.mapping.select_next_item({
            behavior = cmp.SelectBehavior.Select,
            count = 8,
          }),
          ["<C-PageUp>"] = cmp.mapping.select_prev_item({
            behavior = cmp.SelectBehavior.Select,
            count = 16,
          }),
          ["<C-PageDown>"] = cmp.mapping.select_next_item({
            behavior = cmp.SelectBehavior.Select,
            count = 16,
          }),
          ["<S-PageUp>"] = cmp.mapping.select_prev_item({
            behavior = cmp.SelectBehavior.Select,
            count = 16,
          }),
          ["<S-PageDown>"] = cmp.mapping.select_next_item({
            behavior = cmp.SelectBehavior.Select,
            count = 16,
          }),
          ["<Up>"] = cmp.mapping.select_prev_item({
            behavior = cmp.SelectBehavior.Select,
          }),
          ["<Down>"] = cmp.mapping.select_next_item({
            behavior = cmp.SelectBehavior.Select,
          }),
          ["<C-p>"] = cmp.mapping.select_prev_item({
            behavior = cmp.SelectBehavior.Insert,
          }),
          ["<C-n>"] = cmp.mapping.select_next_item({
            behavior = cmp.SelectBehavior.Insert,
          }),
          ["<C-k>"] = cmp.mapping.select_prev_item({
            behavior = cmp.SelectBehavior.Insert,
          }),
          ["<C-j>"] = cmp.mapping.select_next_item({
            behavior = cmp.SelectBehavior.Insert,
          }),
          ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-y>"] = cmp.config.disable,
          ["<C-e>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
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
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
        }),
        sorting = {
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,

            function(entry1, entry2)
              local _, entry1_under = entry1.completion_item.label:find("^_+")
              local _, entry2_under = entry2.completion_item.label:find("^_+")
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
          native_menu = false,
        },
      }
    end,
  },
}
