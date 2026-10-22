-- NOTE: Where I put all my overrides for lsp, lint, etc
--
-- POLICY: before hand-writing an override here, check whether a LazyVim extra
-- or default already does it (`:LazyExtras`, or grep the LazyVim source).
-- Prefer enabling an extra over re-skinning a default — keep this layer thin.
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- Initialize tables if they don't exist
      opts.formatters = opts.formatters or {}
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      -- Add odinfmt formatter.
      -- odinfmt ships bundled inside the `ols` mason package but is NOT symlinked
      -- onto PATH, so point at the bundled binary directly. The glob handles the
      -- arch suffix per host (odinfmt-arm64-darwin on mac, odinfmt-x64-linux on Nobara).
      opts.formatters.odinfmt = {
        command = vim.fn.expand(vim.fn.stdpath("data") .. "/mason/packages/ols/odinfmt-*"),
        args = { "-stdin" },
        stdin = true,
      }

      -- Assign formatters by filetype
      opts.formatters_by_ft.odin = { "odinfmt" }
      opts.formatters_by_ft.html = { "prettier" }

      return opts
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      -- NOTE: this turns off inlay_hints globally by default
      opts.inlay_hints = { enabled = false }

      -- GDScript. There is no server to install: Godot IS the language server,
      -- and nvim-lspconfig's shipped gdscript config just opens a TCP connection
      -- to 127.0.0.1:6005 (editor settings -> network/language_server).
      --
      -- CONSEQUENCE: completion, go-to-definition and hover only work while the
      -- Godot editor is OPEN on that project. With Godot closed you get a
      -- connection error and plain treesitter highlighting. That is how Godot
      -- works, not a broken config — do not go looking for a gdscript binary to
      -- install, and do not add one to mason.
      opts.servers.gdscript = {}

      -- Odin LS config lives here (global) instead of a per-project ols.json.
      -- OLS ingests these via LSP initializationOptions; same keys as ols.json.
      -- Only checker_path/collections need a project ols.json when a layout demands it.
      opts.servers.ols = {
        init_options = {
          -- inlay hints (off by default in OLS)
          enable_inlay_hints_params = true,
          enable_inlay_hints_default_params = true,
          enable_inlay_hints_implicit_return = true,
          -- quality-of-life
          enable_auto_import = true,
          enable_unused_imports_reporting = true,
          enable_snippets = true,
        },
      }

      opts.servers.lua_ls = {
        settings = {
          Lua = {
            hint = {
              enable = true,
              paramType = true,
              paramName = "All",
              arrayIndex = "Enable",
              semicolon = "All",
              setType = true,
            },
            -- NOTE: -> git clone https://github.com/LuaCATS/love2d ~/.local/share/lua-addons/love2d to get the auto completion in .luarc.json
            workspace = {
              library = { os.getenv("HOME") .. "/.local/share/LuaAddons" },
              checkThirdParty = false,
            },
            diagnostics = {
              globals = { "love" },
            },
          },
        },
      }

      opts.servers.basedpyright = {
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      }

      return opts
    end,
  },
  -- give oct snacks picker since it wants to use telescope
  {
    "pwntester/octo.nvim",
    opts = {
      picker = "snacks",
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      -- LazyVim's snacks dashboard, re-skinned: only the header and the clock
      -- line are ours. Keys and the startup footer are LazyVim's defaults and
      -- merge in from lazyvim/plugins/ui.lua.
      dashboard = {
        preset = {
          header = [[
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░▒█▀▀▀█░█▀▀░█▀▀░░░▒█░░▒█░▄▀▀▄░█░▒█░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░▀▀▀▄▄░█▀▀░█▀▀░░░▒▀▄▄▄▀░█░░█░█░▒█░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░▒█▄▄▄█░▀▀▀░▀▀▀░░░░░▒█░░░░▀▀░░░▀▀▀░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░▒█▀▀▀█░▄▀▀▄░█▀▀▄░█▀▄░█▀▀░░░▒█▀▀▄░▄▀▀▄░█░░░█░█▀▀▄░▄▀▀▄░█░░█░░░░░░░
░░▀▀▀▄▄░█▄▄█░█▄▄█░█░░░█▀▀░░░▒█░░░░█░░█░▀▄█▄▀░█▀▀▄░█░░█░█▄▄█░░░░░░░
░▒█▄▄▄█░█░░░░▀░░▀░▀▀▀░▀▀▀░░░▒█▄▄▀░░▀▀░░░▀░▀░░▀▀▀▀░░▀▀░░▄▄▄▀░█░█░█░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░]],
        },
        sections = {
          { section = "header" },
          { text = { { os.date("%Y-%m-%d %I:%M:%S %p"), hl = "header" } }, align = "center", padding = 1 },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
      image = { enabled = true },
      picker = {
        enabled = true,
        icons = {
          icon_sources = { "nerd_fonts", "emoji" }, -- Enable both Nerd Fonts and emojis
        },
        previewers = {
          image = { enabled = true },
        },
      },
      zen = {
        toggles = { dim = false, wrap = true },
        win = { width = 80, backdrop = { transparent = false, bg = "#1f1f28" } },
        show = { statusline = false, tabline = true },
      },
    },
    keys = {
      {
        "<leader>si",
        function()
          Snacks.picker.icons()
        end,
        desc = "Search Icons",
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections = opts.sections or {}
      opts.sections.lualine_z = { function() return os.date("%I:%M %p") end }
      return opts
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      -- godot_resource is the parser name; nvim's own filetype for .tscn/.tres is
      -- `gdresource`. They do not match, and treesitter maps parser -> filetype
      -- itself, so do not "fix" this by renaming either one.
      vim.list_extend(opts.ensure_installed, { "odin", "gdscript", "gdshader", "godot_resource" })
      return opts
    end,
  },
  {
    -- LazyVim's lang.markdown extra puts prettier in the markdown formatter chain
    -- but only ensure_installs markdownlint-cli2 and markdown-toc. Without this,
    -- a fresh box has no prettier binary and conform silently skips it, so
    -- markdown stops formatting on save with no error anywhere.
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "prettier" })
      return opts
    end,
  },
  {
    -- markdownlint-cli2 reads its config from the directory of the file it lints,
    -- walking up to the filesystem root. nvim-lint pipes the buffer over stdin
    -- (`args = { "-" }` in nvim-lint's markdownlint-cli2 linter), so there is no
    -- file path to walk up from and the tool falls back to nvim's cwd WITHOUT a
    -- parent search. A config in ~ therefore never loads while cwd is a repo, and
    -- every prose file lights up with MD013/line-length.
    --
    -- Fix: pass --config explicitly. A repo-local config still wins because it is
    -- found first; markdownlint.jsonc next to init.lua is the fallback.
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters = opts.linters or {}
      opts.linters["markdownlint-cli2"] = {
        args = {
          "--config",
          function()
            local repo_config = vim.fs.find({
              ".markdownlint-cli2.jsonc",
              ".markdownlint-cli2.yaml",
              ".markdownlint.jsonc",
              ".markdownlint.json",
              ".markdownlint.yaml",
              ".markdownlint.yml",
            }, { upward = true, path = vim.fn.expand("%:p:h") })[1]
            return repo_config or vim.fn.stdpath("config") .. "/markdownlint.jsonc"
          end,
          "-",
        },
      }
      return opts
    end,
  },
  { "rebelot/kanagawa.nvim" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa",
    },
  },
}
