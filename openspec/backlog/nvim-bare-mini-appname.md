# Try bare nvim + mini.nvim next to LazyVim

Source: owner, 2026-11-05. Curiosity, not a problem. LazyVim works; this is "own every line" bait. Backlog.

LazyVim is 82 plugins and 44 extras, and the custom config on top is 20 lines. Everything typed daily is a LazyVim default. nvim 0.12 now has `vim.pack`, `vim.lsp.enable`, and `vim.lsp.completion` built in, so a ~250-line config on mini.nvim modules covers the same five jobs (plugins, LSP, syntax, finding, chrome) with one dependency.

Run it side by side with `NVIM_APPNAME=mini nvim` so LazyVim is never touched: own config dir at `home/.config/mini/`, own data and state dirs, delete three dirs to bail. Reuse mason's binaries by putting `~/.local/share/nvim/mason/bin` on PATH inside the config. The real cost is rebuilding LazyVim's keymaps by hand, not the plugins.

Full getting-started guide with an init.lua skeleton, lsp/ file examples for the current languages, and a loss table lives in cb-vault at `lang-notes/nvim/bare-nvim-mini-getting-started.md`. MiniMax (nvim-mini's own config generator) is the shortcut if writing from scratch feels like too much.

- Depends on / UI home: `home/.config/nvim` (unchanged), new `home/.config/mini`, `just link` picks it up
- Promote after a free Saturday with no game work queued, or the next time LazyVim breaks in a way that needs reading its source again.
