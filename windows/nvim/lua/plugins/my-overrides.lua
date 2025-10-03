return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        html = { "prettier" },
        htmx = { "prettier" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      -- NOTE: this turns off inlay_hints globally by default
      opts.inlay_hints = { enabled = false }

      -- ESLint: no formatting
      opts.servers.eslint = { format = false }

      -- vtsls: enable formatting
      opts.servers.vtsls = {
        settings = {
          typescript = { format = { enable = true } },
          javascript = { format = { enable = true } },
        },
      }

      -- lua_ls: keep your hints config (this is *Lua* hints, not inlay)
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
          },
        },
      }

      -- basedpyright: **NO inlayHints in settings**
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
  {
    "nvimdev/dashboard-nvim",
    lazy = false, -- As https://github.com/nvimdev/dashboard-nvim/pull/450, dashboard-nvim shouldn't be lazy-loaded to properly handle stdin.
    opts = function()
      local datetime = os.date("%Y-%m-%d %I:%M:%S %p")
      local logo2 = [[
████████████████████████████████████████████████████████████████████████████
█ ▄▄▀████ █▀▄█ ▄▄▀██▄██ ▄▄▄█ ████▄ ▄███ ▄▄▀███ ██ ███ █ ▄▄▀█ ██ █ ▄▄████████
█ ▀▀ ████ ▄▀██ ██ ██ ▄█ █▄▀█ ▄▄ ██ ████ ▀▀ ███ ██▄▀ ▀▄█ ▀▀ █ ▀▀ █▄▄▀████████
█ ██ ████ ██ █▄██▄█▄▄▄█▄▄▄▄█▄██▄██▄████ ██ ███▄▄██▄█▄██▄██▄█▀▀▀▄█▄▄▄████████
████████████████████████████████████████████████████████████████████████████
█ ██ █ ▄▄▀█ ▄▄████ ██ ██▄██ ▄▄████ ▄▄▀█ ▄▄▀█ ▄▄█ ▄▄▀█▄ ▄█ █████▄██ ▄▄▀█ ▄▄▄█
█ ▄▄ █ ▀▀ █▄▄▀████ ▄▄ ██ ▄█▄▄▀████ ▄▄▀█ ▀▀▄█ ▄▄█ ▀▀ ██ ██ ▄▄ ██ ▄█ ██ █ █▄▀█
█ ██ █▄██▄█▄▄▄████ ██ █▄▄▄█▄▄▄████ ▀▀ █▄█▄▄█▄▄▄█▄██▄██▄██▄██▄█▄▄▄█▄██▄█▄▄▄▄█
████████████████████████████████████████████████████████████████████████████
]]
      local logo = [[
 __ ___ ___        _         ___          __  __   _    _  ___ 
(_  )_  )_   \_)  / ) / /     )   )\ )   (_   )_) )_)  / ` )_  
__)(__ (__    /  (_/ (_/    _(_  (  (    __) /   / /  (_  (__  
          _    _         __    _          
         / `  / )\    /  )_)  / )\_)      
        (_   (_/  \/\/  /__) (_/  /  o o o
]]
      logo = string.rep("\n", 1) .. logo .. "\n" .. datetime .. "\n"
      local opts = {
        theme = "doom",
        hide = {
          -- this is taken care of by lualine
          -- enabling this messes up the actual laststatus setting after loading a file
          statusline = false,
        },
        config = {
          header = vim.split(logo, "\n"),
        -- stylua: ignore
        center = {
          { action = 'lua LazyVim.pick()()',                           desc = " Find File",       icon = " ", key = "f" },
          { action = "ene | startinsert",                              desc = " New File",        icon = " ", key = "n" },
          { action = 'lua LazyVim.pick("oldfiles")()',                 desc = " Recent Files",    icon = " ", key = "r" },
          { action = 'lua LazyVim.pick("live_grep")()',                desc = " Find Text",       icon = " ", key = "g" },
          { action = 'lua LazyVim.pick.config_files()()',              desc = " Config",          icon = " ", key = "c" },
          { action = 'lua require("persistence").load()',              desc = " Restore Session", icon = " ", key = "s" },
          { action = "LazyExtras",                                     desc = " Lazy Extras",     icon = " ", key = "x" },
          { action = "Lazy",                                           desc = " Lazy",            icon = "󰒲 ", key = "l" },
          { action = function() vim.api.nvim_input("<cmd>qa<cr>") end, desc = " Quit",            icon = " ", key = "q" },
        },
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return {
              "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms",
            }
          end,
        },
      }

      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
        button.key_format = "  %s"
      end

      -- open dashboard after closing lazy
      if vim.o.filetype == "lazy" then
        vim.api.nvim_create_autocmd("WinClosed", {
          pattern = tostring(vim.api.nvim_get_current_win()),
          once = true,
          callback = function()
            vim.schedule(function()
              vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
            end)
          end,
        })
      end

      return opts
    end,
  },
  {

    "folke/snacks.nvim",
    opts = {
      picker = {
        enabled = true,
        icons = {
          icon_sources = { "nerd_fonts", "emoji" }, -- Enable both Nerd Fonts and emojis
        },
      },
      zen = {
        toggles = { dim = false, wrap = true },
        win = { backdrop = { transparent = false, bg = "#1f1f28" } },
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
    "folke/edgy.nvim",
    optional = true,
    opts = function(_, opts)
      -- Remove aerial from the right sidebar
      if opts.right then
        opts.right = vim.tbl_filter(function(item)
          return item.ft ~= "aerial"
        end, opts.right)
      end
      return opts
    end,
  },
  {
    "stevearc/aerial.nvim",
    opts = function(_, opts)
      -- Override the default layout to use floating window
      opts.layout = {
        default_direction = "float",
        placement = "window",
        resize_to_content = false,
        win_opts = {
          winhl = "Normal:NormalFloat,FloatBorder:NormalFloat,SignColumn:SignColumnSB",
          signcolumn = "yes",
          statuscolumn = " ",
        },
      }

      -- Configure floating window to be centered
      opts.float = {
        relative = "editor",
        override = function(conf)
          -- Calculate center position
          local width = 60
          local height = 30
          conf.width = width
          conf.height = height
          conf.row = (vim.o.lines - height) / 2
          conf.col = (vim.o.columns - width) / 2
          conf.anchor = "NW"
          conf.border = "rounded"
          return conf
        end,
      }

      return opts
    end,
    keys = {
      { "<leader>cs", "<cmd>AerialToggle float<cr>", desc = "Aerial (Symbols)" },
    },
  },
  { "rebelot/kanagawa.nvim" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa",
    },
  },
}
