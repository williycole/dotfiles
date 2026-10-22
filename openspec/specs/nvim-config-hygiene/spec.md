# nvim-config-hygiene

## Purpose
Keep the Neovim custom layer honest against LazyVim defaults: every override is either a justified capability-add or a deliberately-documented re-skin, no default keymap is silently shadowed, and overlapping tools resolve to a set the user actually uses.

## Requirements

### Requirement: Overrides justified by the add-vs-reskin lens

Every custom plugin override in the Neovim config (`lua/plugins/my-overrides.lua`, `lua/plugins/my-extras.lua`) SHALL be classifiable as either **capability-adding** (provides behavior LazyVim / LazyVim-Extras does not ship) or **re-skinning** (reproduces a default with different styling). Re-skinning overrides SHALL either be removed, replaced by the equivalent LazyVim extra, or explicitly annotated as a deliberate stylistic choice.

#### Scenario: Classifying an existing override

- **WHEN** an override in the custom layer is reviewed
- **THEN** it is labeled `add` or `re-skin`, and every `re-skin` has a recorded decision (remove / swap-to-extra / keep-with-intent)

Example — the Aerial float is a `re-skin` (LazyVim already binds `<leader>cs` → Trouble symbols), decision = **remove**:

```lua
-- my-overrides.lua:211-248 — DELETE this whole block (re-skin, un-shadows Trouble default)
{
  "stevearc/aerial.nvim",
  keys = {
    { "<leader>cs", "<cmd>AerialOpen float<cr>", desc = "Aerial (Symbols)" },
  },
  opts = function(_, conf)
    -- ~35 lines of centered-float window math
    conf.row = (vim.o.lines - height) / 2
    -- ...
  end,
}
```

#### Scenario: Deliberate re-skin is documented

- **WHEN** a re-skinning override is kept
- **THEN** the config carries a comment stating it deliberately overrides a named LazyVim default and why the custom shape is preferred

Example — the custom dashboard is a kept re-skin, so it gets an intent comment:

```lua
-- my-overrides.lua:100 — dashboard: deliberate re-skin of the `dashboard-nvim`
-- extra. Kept on purpose for the custom header/datetime/layout. Do not
-- replace with stock defaults.
{ "nvimdev/dashboard-nvim", opts = function() --[[ custom layout ]] end },
```

### Requirement: No unintended shadowing of baked-in keymaps

Custom keymaps SHALL NOT silently override a LazyVim default keybinding without the override being an intentional, recorded decision. Known collision: `<leader>cs` (LazyVim default → `Trouble symbols`) is overridden by the Aerial float.

#### Scenario: Auditing a custom keymap

- **WHEN** a custom keymap is defined on a key that LazyVim binds by default
- **THEN** the collision is identified against LazyVim source and recorded as intentional or accidental

Example — `<leader>cs` collision is accidental; removing the Aerial `keys` entry restores the default:

```lua
-- LazyVim default (LazyVim/lua/lazyvim/plugins/editor.lua:219):
{ "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" }

-- Custom shadow to REMOVE (my-overrides.lua:246):
{ "<leader>cs", "<cmd>AerialOpen float<cr>", desc = "Aerial (Symbols)" }
-- → after removal, `<leader>cs` resolves to the Trouble default again.
```

### Requirement: Single deliberate symbol-navigation strategy

The config SHALL resolve the three overlapping symbol navigators — Aerial float (`<leader>cs`), Trouble symbols (LazyVim default, `<leader>cs`), and Snacks picker symbols (`<leader>ss` / `<leader>sS`) — to a set the user actually uses, rather than retaining all three by accident.

#### Scenario: Symbol navigation decision

- **WHEN** the symbol-navigation overlap is resolved
- **THEN** each retained navigator maps to a distinct interaction mode the user confirms they use (glance float / pinned sidebar / fuzzy jump), and unused ones are removed or left as cheap defaults by explicit choice

Example — retained set after removing the Aerial float:

```
<leader>cs  → Trouble symbols   (pinned sidebar tree — LazyVim default, restored)
<leader>ss  → Snacks doc symbols (fuzzy jump — snacks_picker extra)
<leader>sS  → Snacks workspace symbols (fuzzy jump, workspace scope)
```

No custom Lua remains for symbol navigation — the two retained tools are both stock, distinct modes.
