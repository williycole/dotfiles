return {
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
}
