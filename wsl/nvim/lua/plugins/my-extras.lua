-- NOTE: where I put all extra plugins
return {
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
    opts = {
      local_root = "/home/cb/Repos/cb-vault/daily", -- NOT notes_path

      template = "template.md",                     -- NOT template_path
      -- filename option does not exist in standard today.nvim!
    },
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
    -- NOTE: -> git clone https://github.com/LuaCATS/love2d ~/.local/share/lua-addons/love2d to get the auto completion in .luarc.json
    --[[
        {
          "workspace.library": ["~/.local/share/lua-addons/love2d/library"],
          "diagnostics.globals": ["love"],
          "runtime.version": "Lua 5.1",
          "workspace.checkThirdParty": false
        }
    --]]
    "S1M0N38/love2d.nvim",
    event = "VeryLazy",
    version = "2.*",
    opts = {},
    keys = {
      { "<leader>v",  ft = "lua",             desc = "LÖVE" },
      { "<leader>vv", "<cmd>LoveRun<cr>",     ft = "lua",   desc = "Run LÖVE" },
      { "<leader>vs", "<cmd>LoveStop<cr>",    ft = "lua",   desc = "Stop LÖVE" },
      { "<leader>vh", "<cmd>help love2d<cr>", ft = "lua",   desc = "Help LÖVE" },
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
      vim.opt.updatetime = 0
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup()
      vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", { desc = "Open vertical terminal" })
    end,
  },
}
