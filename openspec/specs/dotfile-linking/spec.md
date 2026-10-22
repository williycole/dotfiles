# dotfile-linking Specification

## Purpose
How this repo manages config files: they live at their literal target paths and reach `$HOME` as
symlinks, so the repo file and the live file are one inode.

That single fact is the point. The previous approach rendered live files as *copies* of a source,
which meant two copies of everything and a manual step to reconcile them — and that step gets
skipped. It was skipped: `openspec config profile` rewrote `~/.config/openspec/config.json` to
twelve workflows while the tracked copy sat at five, and nothing announced it. A symlink deletes the
second copy, so there is nothing to reconcile and no command to forget.

Three things a symlink cannot do, and what covers each: git records only the executable bit, so
`modes.conf` declares the rest; some applications save by replacing a file rather than writing
through it, so `copy/` and `adopt` catch those; and a few applications keep config at different
paths per OS, so `targets.conf` maps them. Both `copy/` and `targets.conf` are empty today, and that
is measured rather than assumed — every CLI tool that writes its own config was tested and writes
through the link.

Two constraints run through all of it, both taken from failures this repo already had. No recipe
aborts halfway: every item is independent, a failure is named and the run continues, and the exit
code reflects it. And nothing in `$HOME` is ever deleted — `link` refuses any target it does not
already own, and the one-time `migrate` displaces a duplicate only when `cmp` proves it identical,
moving it aside rather than removing it.

## Requirements

### Requirement: The repo file and the live file are one inode

Config files SHALL live in the repo at their literal target path and reach `$HOME` as symlinks, so
that the repo copy and the live copy are the same inode. There SHALL be no apply, render, or sync
step for a linked file, and no second copy to reconcile. `git status` in the repo IS the drift
check for every linked file.

Filenames SHALL be the real target names. No prefix, suffix, or attribute encoding is permitted in
a path — permissions, executability, and OS scoping are expressed by the filesystem, by
`modes.conf`, and by the overlay directories, never by renaming a file.

#### Scenario: Editing at either path changes one file

- **WHEN** a linked file is edited at its `$HOME` path
- **THEN** `git diff` in the repo SHALL show the change immediately
- **AND** no command is required to propagate it

#### Scenario: Repo paths are readable target paths

- **WHEN** a config file for `~/.config/nvim/init.lua` is located in the repo
- **THEN** it SHALL be at `home/.config/nvim/init.lua`

#### Scenario: Relinking is idempotent

- **WHEN** `just link` runs against a machine whose links already exist and are correct
- **THEN** it SHALL report no changes and modify nothing

### Requirement: Layered overlays replace templating

Per-machine and per-OS divergence SHALL be expressed by overlay directories applied in a fixed
order, later winning: `home/`, then `os/darwin/` or `os/linux/` selected by `uname -s`, then
`host/<hostname>/`. `home/` SHALL remain the default location for anything meaningful on more than
one machine.

Where a config format supplies a native conditional-include mechanism, divergence SHALL use it
rather than an overlay copy of the whole file. Known mechanisms: gitconfig `[include]`, ssh_config
`Include` and `Match exec`, zsh `[[ $OSTYPE == darwin* ]]` and sourcing a local file, tmux `%if`
and `if-shell`, neovim and wezterm Lua conditionals, alacritty `import`, ghostty `config-file`.
Starship has no include mechanism, so per-machine divergence there SHALL go through
`STARSHIP_CONFIG`.

#### Scenario: OS overlay wins over the shared default

- **WHEN** the same target path exists in both `home/` and `os/darwin/` and `just link` runs on macOS
- **THEN** the link SHALL point at the `os/darwin/` file

#### Scenario: Host overlay wins over the OS overlay

- **WHEN** the same target path exists in `os/darwin/` and `host/<hostname>/`
- **THEN** the link SHALL point at the `host/<hostname>/` file

#### Scenario: Linux-only config is absent on macOS

- **WHEN** `just link` runs on macOS
- **THEN** no link SHALL be created for any path that exists only under `os/linux/`

### Requirement: A narrow copy set covers files a symlink cannot survive

Files that macOS or an owning application rewrites in place SHALL be copied rather than linked, and
SHALL be listed explicitly in `copy/`. This set exists because `cfprefsd` caches and rewrites
`~/Library` plists regardless of the path, and because some editors replace a file on save rather
than writing through it, which severs a symlink and leaves an untracked real file behind.

The copy set SHALL remain small and explicit. Adding to it requires an observed failure, not a
precaution.

`just adopt <path>` SHALL pull the current live version of a copy-set file back into the repo, so
that a file edited through its owning application can be captured without hand-copying.

#### Scenario: Copy-set file is copied, not linked

- **WHEN** `just link` runs and a target path is listed in the copy set
- **THEN** a regular file SHALL be written at the target
- **AND** no symlink SHALL be created for it

#### Scenario: A severed link is reported

- **WHEN** a path that should be a symlink is found to be a regular file
- **THEN** `just status` SHALL report it by name as a candidate for the copy set

#### Scenario: Adopting captures the live version

- **WHEN** `just adopt <path>` runs against a copy-set file that the application has modified
- **THEN** the repo copy SHALL be updated to match the live file
- **AND** the command SHALL print what it changed

### Requirement: Per-OS target paths are declared where they differ

Applications that place the same config at different paths per OS SHALL be declared in
`targets.conf`, mapping one repo source to a per-OS target. Everything else SHALL follow the mirror
convention without an entry.

#### Scenario: A declared file resolves to the per-OS target

- **WHEN** `just link` runs on macOS for a source declared in `targets.conf`
- **THEN** the link SHALL be created at the declared macOS target path
- **AND** running on Linux SHALL create it at the declared Linux target path

#### Scenario: Undeclared files need no entry

- **WHEN** a config uses the same path on both machines
- **THEN** it SHALL require no `targets.conf` entry

### Requirement: Permissions are enforced explicitly

Because git records only the executable bit, target modes other than 644 and 755 SHALL be declared
in `modes.conf` and applied by `just perms`. `modes.conf` SHALL cover directories as well as files.

`just perms` SHALL be safe to re-run and SHALL be invoked by `just sync` and by the bootstrap path,
so that a fresh clone does not leave a restricted file world-readable.

#### Scenario: A declared file gets its mode

- **WHEN** `just perms` runs after a fresh clone
- **THEN** every path declared in `modes.conf` SHALL have its declared mode

#### Scenario: Drifted modes are reported

- **WHEN** a declared path's mode differs from `modes.conf`
- **THEN** `just status` SHALL report the path, the declared mode, and the actual mode

### Requirement: No recipe aborts halfway and no recipe deletes in `$HOME`

Every recipe SHALL process each item independently. A failure on one item SHALL NOT prevent
unrelated items from being processed. Each failure SHALL be reported by name, and the run SHALL
exit non-zero so a failure is not silent.

No recipe SHALL delete a file or directory in `$HOME`. Recipes create links, copy the declared set,
and set modes. Removal is a deliberate manual act.

#### Scenario: One failure does not skip the rest

- **WHEN** linking one path fails during `just link`
- **THEN** the remaining paths SHALL still be linked
- **AND** the output SHALL name the path that failed
- **AND** the command SHALL exit non-zero

#### Scenario: Nothing is deleted from the home directory

- **WHEN** any recipe runs against a `$HOME` containing untracked files
- **THEN** no untracked file SHALL be removed

#### Scenario: Dry run is the default for the reconciling recipe

- **WHEN** `just sync` runs without the acting variant
- **THEN** it SHALL print the actions it would take and change nothing

### Requirement: Run-once work is stamped and idempotent

One-time setup steps SHALL record a stamp only after the step succeeds, and SHALL be skipped when
the stamp is present. Steps that must re-run when their input changes SHALL store a hash of that
input alongside the stamp and re-run when it differs.

#### Scenario: A completed step does not repeat

- **WHEN** a stamped run-once step is invoked again
- **THEN** it SHALL be skipped

#### Scenario: A failed step is not stamped

- **WHEN** a run-once step fails
- **THEN** no stamp SHALL be written
- **AND** the next invocation SHALL retry it

#### Scenario: Changed input re-runs the step

- **WHEN** the tracked input of an onchange step differs from the recorded hash
- **THEN** the step SHALL run again

### Requirement: Vendored external files are declared and refreshed on request

Files fetched from outside the repo SHALL be declared in `external.conf` with a pinned source, and
refreshed only by `just external`. Refresh SHALL be explicit; there is no automatic refresh
interval.

#### Scenario: An external file is fetched on a fresh machine

- **WHEN** bootstrap runs on a machine without a declared external file
- **THEN** that file SHALL be fetched to its declared location

#### Scenario: Refresh is explicit

- **WHEN** an upstream external file changes and `just external` has not been run
- **THEN** the local copy SHALL remain unchanged

### Requirement: Secrets are referenced at runtime, never stored in the repo

No secret value SHALL be committed, in plaintext or encrypted. Config SHALL reference secrets at
runtime instead of containing them, using a gitignored local file, a native include of a
machine-local path, or a secret-manager read.

Secret material SHALL be resolved once at bootstrap into a gitignored local file which shells then
source, rather than by calling a secret manager on every shell start.

The atuin data directory SHALL be excluded from the repo, since its history database contains every
command entered on the machine.

#### Scenario: A secret-bearing path is not tracked

- **WHEN** the repo is inspected for tracked files
- **THEN** no file containing a credential, token, or private key SHALL be present

#### Scenario: Shell startup does not call a secret manager

- **WHEN** a new interactive shell starts
- **THEN** it SHALL source an already-resolved local file rather than invoking a secret-manager read

### Requirement: A fresh machine comes up from one command

The repo SHALL provide `install.sh` at its root that brings a fresh machine to a working state:
links, modes, externals, and packages. It SHALL be idempotent and safe to re-run.

The entry point SHALL be named so that automated environments which look for a bootstrap script
find it, and repo paths SHALL be literal so that environments which instead fall back to symlinking
dot-prefixed files also work.

#### Scenario: Fresh clone bootstraps

- **WHEN** `install.sh` runs on a machine with only the repo cloned
- **THEN** links, declared modes, and declared externals SHALL be in place

#### Scenario: Re-running changes nothing

- **WHEN** `install.sh` runs a second time on the same machine
- **THEN** it SHALL report no changes

### Requirement: Omarchy removed from the Linux target

The Linux target is Nobara/Fedora, not Omarchy. The shell rc SHALL NOT source Omarchy's rc, and
Omarchy-specific configs (`.config/omarchy`, `branding`) SHALL NOT be managed by this repo. `hypr`
remains the managed Linux-only window-manager config and carries to Nobara unchanged.

Mac-only and Linux-only separation is provided structurally by the `os/darwin/` and `os/linux/`
overlays defined in this capability; this requirement covers only what is specific to retargeting
the Linux machine from Omarchy to Nobara.

#### Scenario: Omarchy configs are not linked on Nobara

- **WHEN** `just link` runs on Linux
- **THEN** `os/linux/` SHALL supply `.config/hypr`
- **AND** no link SHALL be created for `.config/omarchy` or `branding`

#### Scenario: Shell rc does not source Omarchy

- **WHEN** the linked shell rc is read on Nobara
- **THEN** it SHALL NOT contain a `source ~/.local/share/omarchy/...` line

#### Scenario: Mac is unaffected by the Linux retarget

- **WHEN** `just status` runs on macOS after the Omarchy-to-Nobara retarget
- **THEN** it SHALL report zero differences for any Mac-linked file
