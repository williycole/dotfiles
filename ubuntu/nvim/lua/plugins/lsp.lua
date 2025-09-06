-- Custom Pyright settings
local pyright = function(_, opts)
    opts.settings = opts.settings or {}
    opts.settings.python = opts.settings.python or {}
    opts.settings.python.pythonPath = vim.fn.getcwd() .. "/.venv/bin/python"
    return false -- Let LazyVim handle the rest
end

-- CSS LSP for outline view
local cssls = function(_, opts)
    opts.filetypes = { "css", "scss", "less" }
    opts.settings = opts.settings or {}
    opts.settings.css = { validate = true }
    opts.settings.scss = { validate = true }
    return false -- Let LazyVim handle the rest
end

-- Disable tsserver formatting
local tsserver = function(_, opts)
    opts.capabilities = opts.capabilities or {}
    opts.capabilities.documentFormattingProvider = false
    return false
end

-- Configure angularls
local angularls = function(_, opts)
    opts.capabilities = opts.capabilities or {}
    opts.capabilities.documentFormattingProvider = false
    opts.root_dir = function(fname)
        return vim.fn.getcwd() -- Force project root to ~/repos/ggs/nitropay/panel
    end
    opts.settings = {
        angular = {
            tsconfig = vim.fn.getcwd() .. "/tsconfig.json", -- Point to your tsconfig.json
            log = "verbose",                                -- Enable verbose logging for debugging
        },
    }
    return false
end

return {
    "neovim/nvim-lspconfig",
    opts = {
        servers = {
            angularls = {
                filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx" },
            },
        },
        setup = {
            pyright = pyright,
            cssls = cssls,
            tsserver = tsserver,
            angularls = angularls,
        },
    },
}
