-- all overrides for LazyVim Defaults
return {
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
        "nvim-lspconfig",
        opts = {
            inlay_hints = { enabled = false },
        },
    },
    -- Add aerial override here
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
    -- Disable edgy integration for aerial
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
}
