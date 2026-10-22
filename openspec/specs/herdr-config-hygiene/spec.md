# herdr-config-hygiene

## Purpose
Keep the herdr config a set of deliberate decisions: no collision-prone prefix, no silent gaps. Every review-flagged setting is either explicitly chosen or a commented, considered default, and herdr's worktree/agent workflow is reachable rather than left unbound by omission.

## Requirements

### Requirement: Collision-free prefix key

The herdr prefix key SHALL NOT alias a control character the terminal already emits for another key. `ctrl+h` (ASCII 0x08 = Backspace) SHALL NOT be used as the prefix — verified empirically that it swallows Backspace even under Ghostty, and kitty-keyboard does not disambiguate them.

#### Scenario: Prefix does not shadow Backspace

- **WHEN** the config sets a prefix that aliases an ASCII control code produced by another key (Ctrl+H=BS, Ctrl+I=Tab, Ctrl+M=Enter)
- **THEN** the change SHALL replace it with a non-aliasing prefix (the chosen value is `ctrl+f`)

#### Scenario: Prefix change requires a restart

- **WHEN** the prefix is changed in `config.toml`
- **THEN** applying it SHALL require a herdr restart; `herdr server reload-config` alone does NOT rebind the live prefix

#### Scenario: Backspace still works in panes

- **WHEN** the chosen prefix is applied and the user presses Backspace inside an interactive pane
- **THEN** Backspace SHALL delete a character and SHALL NOT trigger prefix mode

### Requirement: Every setting is a deliberate choice

Each herdr setting SHALL be either explicitly set or intentionally left at its default with a comment marking it as a considered default. The config SHALL NOT contain unexplained gaps for settings the review flagged as workflow-relevant.

#### Scenario: Intentional default is annotated

- **WHEN** a review-flagged setting (theme, shell_mode, new_cwd, worktree bindings, worktree directory, agent-nav bindings) is left unset
- **THEN** the config SHALL carry a comment recording that the default was chosen deliberately

#### Scenario: No silent gaps remain

- **WHEN** the shored-up config is compared against `herdr --default-config`
- **THEN** every difference and every deliberately-kept default among the flagged settings SHALL trace to a decision recorded in this change's design or open questions

### Requirement: Agent and worktree workflow bindings decided

Because herdr exists to orchestrate AI coding agents across worktrees, the config SHALL make an explicit decision for each worktree and agent-navigation action: `open_worktree`, `remove_worktree`, `previous_agent`, `next_agent`, `focus_agent`, and `[worktrees] directory`. Each SHALL be either bound or explicitly declined in a comment.

#### Scenario: Worktree actions are reachable or declined

- **WHEN** the config is applied
- **THEN** each worktree/agent-navigation action SHALL have a keybinding OR a comment stating it is intentionally left to the menu/picker

#### Scenario: Worktree home path is decided

- **WHEN** worktree creation is used
- **THEN** the config SHALL either set `[worktrees] directory` to a chosen path or document that the herdr default (`~/.herdr/worktrees`) is accepted

### Requirement: Theme and terminal policy decided

The config SHALL make an explicit decision on `[theme] name`, `[terminal] shell_mode`, and `[terminal] new_cwd`, rather than leaving them as undocumented defaults.

#### Scenario: Theme follows the terminal palette

- **WHEN** the theme decision is made
- **THEN** the config SHALL set `[theme] name = "terminal"` so herdr renders from the host terminal's (Ghostty's) ANSI palette
- **AND** SHALL NOT add `[theme.custom]` overrides that reduce the selection-highlight contrast (e.g. `panel_bg = "reset"`), so the moving selector stays visible

#### Scenario: New panes use a decided cwd policy

- **WHEN** a new pane, tab, or workspace is created without an explicit `--cwd`
- **THEN** its working directory SHALL follow the `new_cwd` policy chosen in this change

### Requirement: Config remains repo-managed and valid

The shored-up config SHALL remain a single source file in the dotfiles repo and SHALL parse cleanly under herdr 0.6.8.

#### Scenario: Config loads without error

- **WHEN** `herdr server reload-config` runs after the change is applied
- **THEN** herdr SHALL load the config with no parse or unknown-key errors

#### Scenario: Managed in the repo

- **WHEN** the edit is made
- **THEN** it SHALL be made at `home/.config/herdr/config.toml` in the dotfiles repo, consistent with the `dotfile-linking` capability
- **AND** because that path is symlinked into `$HOME`, the repo file and the live config SHALL be one inode — there is no apply step and no drift to reconcile
