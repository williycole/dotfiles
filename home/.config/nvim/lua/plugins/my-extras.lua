-- NOTE: where I put all extra plugins
return {
  {
    -- Sidekick is used for its CLI/terminal integration (claude, opencode, pi),
    -- NOT Copilot's Next Edit Suggestions. The `ai.sidekick` LazyVim extra only
    -- registers the copilot LSP when `nes.enabled ~= false`, so disabling nes
    -- stops the "not signed into GitHub" nag while keeping the CLI features.
    "folke/sidekick.nvim",
    opts = { nes = { enabled = false } },
  },
  {
    "ThePrimeagen/99",
    config = function()
      local _99 = require("99")

      -- For logging that is to a file if you wish to trace through requests
      -- for reporting bugs, i would not rely on this, but instead the provided
      -- logging mechanisms within 99.  This is for more debugging purposes
      local cwd = vim.uv.cwd()
      local basename = vim.fs.basename(cwd)
      _99.setup({
        provider = _99.Providers.ClaudeCodeProvider, -- default: OpenCodeProvider
        logger = {
          level = _99.DEBUG,
          path = "/tmp/" .. basename .. ".99.debug",
          print_on_error = true,
        },
        -- When setting this to something that is not inside the CWD tools
        -- such as claude code or opencode will have permission issues
        -- and generation will fail refer to tool documentation to resolve
        -- https://opencode.ai/docs/permissions/#external-directories
        -- https://code.claude.com/docs/en/permissions#read-and-edit
        tmp_dir = "./tmp",

        --- Completions: #rules and @files in the prompt buffer
        completion = {
          -- I am going to disable these until i understand the
          -- problem better.  Inside of cursor rules there is also
          -- application rules, which means i need to apply these
          -- differently
          -- cursor_rules = "<custom path to cursor rules>"

          --- A list of folders where you have your own SKILL.md
          --- Expected format:
          --- /path/to/dir/<skill_name>/SKILL.md
          ---
          --- Example:
          --- Input Path:
          --- "scratch/custom_rules/"
          ---
          --- Output Rules:
          --- {path = "scratch/custom_rules/vim/SKILL.md", name = "vim"},
          --- ... the other rules in that dir ...
          ---
          custom_rules = {
            "scratch/custom_rules/",
          },

          --- Configure @file completion (all fields optional, sensible defaults)
          files = {
            -- enabled = true,
            -- max_file_size = 102400,     -- bytes, skip files larger than this
            -- max_files = 5000,            -- cap on total discovered files
            -- exclude = { ".env", ".env.*", "node_modules", ".git", ... },
          },

          --- What autocomplete you use.
          source = "blink", --or "cmp"
        },

        --- WARNING: if you change cwd then this is likely broken
        --- ill likely fix this in a later change
        ---
        --- md_files is a list of files to look for and auto add based on the location
        --- of the originating request.  That means if you are at /foo/bar/baz.lua
        --- the system will automagically look for:
        --- /foo/bar/AGENT.md
        --- /foo/AGENT.md
        --- assuming that /foo is project root (based on cwd)
        md_files = {
          "CLAUDE.md",
          "AGENT.md",
        },
      })

      -- take extra note that i have visual selection only in v mode
      -- technically whatever your last visual selection is, will be used
      -- so i have this set to visual mode so i dont screw up and use an
      -- old visual selection
      --
      -- likely ill add a mode check and assert on required visual mode
      -- so just prepare for it now
      vim.keymap.set("v", "<leader>9v", function()
        _99.visual()
      end)

      --- if you have a request you dont want to make any changes, just cancel it
      vim.keymap.set("n", "<leader>9x", function()
        _99.stop_all_requests()
      end)

      vim.keymap.set("n", "<leader>9s", function()
        _99.search()
      end)
    end,
  },
  {
    "VVoruganti/today.nvim",
    opts = function()
      local path_a = vim.fn.expand("~/repos/cb-vault/daily")
      local path_b = vim.fn.expand("~/Repos/personal/cb-vault/daily")
      local root = path_b
      if vim.fn.filereadable(path_a .. "/template.md") == 1 then
        root = path_a
      end
      return {
        local_root = root,
        template = "template.md",
      }
    end,
    keys = {
      { "<leader>dn", "<cmd>Today<CR>", desc = "Open today's Daily Note" },
    },
  },
  {
    "fredrikaverpil/godoc.nvim",
    ft = { "go" },
    config = function()
      require("godoc").setup()
      vim.keymap.set("n", "<leader>gD", ":GoDoc<CR>", { desc = "Open GoDoc" })
    end,
  },
  {
    "S1M0N38/love2d.nvim",
    event = "VeryLazy",
    version = "2.*",
    -- Only load where the LÖVE runtime exists; skips cleanly on boxes without
    -- `love` installed (e.g. fresh nobara) instead of erroring. Install with the
    -- OS pkg manager (`brew install love` / `dnf install love`) to enable it.
    cond = function()
      return vim.fn.executable("love") == 1
    end,
    opts = {},
    keys = {
      { "<leader>v", ft = "lua", desc = "LÖVE" },
      { "<leader>vv", "<cmd>LoveRun<cr>", ft = "lua", desc = "Run LÖVE" },
      { "<leader>vs", "<cmd>LoveStop<cr>", ft = "lua", desc = "Stop LÖVE" },
      { "<leader>vh", "<cmd>help love2d<cr>", ft = "lua", desc = "Help LÖVE" },
    },
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    opts = {

      preset = "ghost",

      hi = {
        error = "DiagnosticError",
        warn = "DiagnosticWarn",
        info = "DiagnosticInfo",
        hint = "DiagnosticHint",
        arrow = "NonText",
        background = "CursorLine",
        mixing_color = "None",
      },
      options = {
        show_source = true,
        use_icons_from_diagnostic = false,
        add_messages = true,
        throttle = 0,
        softwrap = 30,
        multiple_diag_under_cursor = false,
        multilines = {
          enabled = true,
          always_show = true,
        },
        show_all_diags_on_cursorline = true,
        enable_on_insert = true,
        overflow = {
          mode = "wrap",
        },
        virt_texts = {
          priority = 5000,
        },
      },
    },
    config = function(_, opts)
      vim.diagnostic.config({ virtual_text = false })
      require("tiny-inline-diagnostic").setup(opts)
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup()
      vim.keymap.set("n", "<leader>tv", "<Esc>:ToggleTerm direction=vertical<CR>", { desc = "Open vertical terminal" })
    end,
  },
  {
    "luckasRanarison/nvim-devdocs",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
    keys = {
      { "<leader>dd", "<cmd>DevdocsOpenFloat<cr>", desc = "DevDocs (float)" },
      { "<leader>dD", "<cmd>DevdocsOpen<cr>", desc = "DevDocs" },
    },
  },
  {
    -- Seamless <C-hjkl> between Neovim splits and herdr panes: move within nvim,
    -- and cross into the neighboring herdr pane at a split edge. These keys
    -- override LazyVim's own <C-hjkl> window maps (lazyvim keymaps.lua).
    --
    -- v3 (2026-10-28). smart-splits moved to its own org and pulled every
    -- multiplexer out of the repo, so the herdr manifest this used to link
    -- against is gone — `herdr plugin list` said `manifest unavailable` and all
    -- four keys resolved to nothing. Worse, herdr swallowed them: ctrl+j is the
    -- same byte as shift+enter, so shift+enter died everywhere too.
    --
    -- herdr support now lives in adriankarlen/smart-splits-backend-herdr,
    -- written against smart-splits' v3 PROTOCOL.md. The herdr half is installed
    -- separately with `herdr plugin install adriankarlen/smart-splits-backend-herdr`
    -- and still decides where a keypress goes by asking herdr whether the
    -- focused pane runs nvim, so it does not depend on load order. Needs jq.
    "smart-splits-nvim/smart-splits.nvim",
    version = "^3.0.0",
    lazy = false,
    dependencies = {
      { "adriankarlen/smart-splits-backend-herdr", main = "smart-splits-backend-herdr", opts = {} },
    },
    opts = { mux = { backend = "smart-splits-backend-herdr" } },
    keys = {
      { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Go to Left Window" },
      { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Go to Lower Window" },
      { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Go to Upper Window" },
      { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Go to Right Window" },
    },
  },

  {
    -- jj's diff-editor. Replaces the `:builtin` TUI, which cannot be driven by
    -- an agent in a herdr pane and is awkward to use by hand. `HunkDiffEditor`
    -- selects by file, hunk or individual line; `HunkDiffView` is a read-only
    -- two-directory viewer that also renders jj's materialized conflicts.
    --
    -- Wired up in home/.config/jj/config.toml as ui.diff-editor and the
    -- [merge-tools.hunk] difftool. nui.nvim is already in the lock file.
    "julienvincent/hunk.nvim",
    cmd = { "HunkDiffView", "HunkDiffEditor" },
    dependencies = { "MunifTanjim/nui.nvim" },
    config = function()
      require("hunk").setup()
    end,
  },
}
