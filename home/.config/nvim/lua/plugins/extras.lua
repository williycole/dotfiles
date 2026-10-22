-- LazyVim extras, declared here so they're TRACKED IN GIT and sync to every box.
-- Relying on lazyvim.json (written by :LazyExtras) doesn't work across machines:
-- home/.chezmoiignore ignores .config/nvim/lazyvim.json, so a new box comes up
-- missing every extra. LazyVim merges + dedupes imports, so declaring them here
-- is additive and safe alongside the UI.
-- ponytail: keeps lazyvim.json ignored (churny news/version state) while the
-- extras list itself stays version-controlled. Add/remove extras by editing
-- this file, not the :LazyExtras UI, if you want it to reach other boxes.
return {
  { import = "lazyvim.plugins.extras.ai.sidekick" },
  { import = "lazyvim.plugins.extras.ai.supermaven" },
  { import = "lazyvim.plugins.extras.coding.luasnip" },
  { import = "lazyvim.plugins.extras.coding.mini-surround" },
  { import = "lazyvim.plugins.extras.coding.yanky" },
  { import = "lazyvim.plugins.extras.editor.dial" },
  { import = "lazyvim.plugins.extras.editor.harpoon2" },
  { import = "lazyvim.plugins.extras.editor.illuminate" },
  { import = "lazyvim.plugins.extras.editor.inc-rename" },
  { import = "lazyvim.plugins.extras.editor.mini-diff" },
  { import = "lazyvim.plugins.extras.editor.mini-files" },
  { import = "lazyvim.plugins.extras.editor.mini-move" },
  { import = "lazyvim.plugins.extras.editor.overseer" },
  { import = "lazyvim.plugins.extras.editor.refactoring" },
  { import = "lazyvim.plugins.extras.editor.snacks_picker" },
  { import = "lazyvim.plugins.extras.editor.telescope" },
  { import = "lazyvim.plugins.extras.lang.clangd" },
  { import = "lazyvim.plugins.extras.lang.cmake" },
  { import = "lazyvim.plugins.extras.lang.docker" },
  { import = "lazyvim.plugins.extras.lang.elixir" },
  { import = "lazyvim.plugins.extras.lang.git" },
  { import = "lazyvim.plugins.extras.lang.go" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.lang.markdown" },
  { import = "lazyvim.plugins.extras.lang.python" },
  { import = "lazyvim.plugins.extras.lang.rust" },
  { import = "lazyvim.plugins.extras.lang.sql" },
  { import = "lazyvim.plugins.extras.lang.tailwind" },
  { import = "lazyvim.plugins.extras.lang.toml" },
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.lang.yaml" },
  { import = "lazyvim.plugins.extras.linting.eslint" },
  { import = "lazyvim.plugins.extras.test.core" },
  { import = "lazyvim.plugins.extras.ui.edgy" },
  { import = "lazyvim.plugins.extras.ui.mini-animate" },
  { import = "lazyvim.plugins.extras.ui.mini-indentscope" },
  { import = "lazyvim.plugins.extras.ui.smear-cursor" },
  { import = "lazyvim.plugins.extras.ui.treesitter-context" },
  { import = "lazyvim.plugins.extras.util.dot" },
  { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
  { import = "lazyvim.plugins.extras.util.octo" },
  { import = "lazyvim.plugins.extras.util.rest" },
  { import = "lazyvim.plugins.extras.util.startuptime" },
}
