# cross-os-tooling

## Purpose
Provision identical language runtimes (mise) and CLI tools (packages.yaml) across machines, with resilient, idempotent installs.

## Requirements

### Requirement: Declarative language runtimes via mise

The system SHALL define language runtimes (go, node, python, elixir, erlang) in a committed `mise.toml` with pinned versions, so every machine resolves identical runtime versions. Hand-rolled PATH manipulation for `pyenv`, `fnm`, and `~/.elixir-install` SHALL be removed from the shell rc.

#### Scenario: Identical runtimes across machines

- **WHEN** `mise install` runs on any supported machine using the committed `mise.toml`
- **THEN** it SHALL install the pinned versions of each declared runtime
- **AND** the resolved versions SHALL match across machines

#### Scenario: Shell rc no longer hardcodes runtime paths

- **WHEN** the migrated shell rc is applied
- **THEN** it SHALL NOT contain hardcoded `~/.elixir-install/installs/...`, `pyenv init`, or `fnm` PATH lines
- **AND** runtime resolution SHALL be handled by mise

### Requirement: Declarative CLI tool installation

The system SHALL list CLI tools in a declarative `packages.yaml`, each with a per-OS installer field (`brew`/`cask` for macOS, `dnf` for Linux, `npm` for all OSes). A single install script SHALL read this list and invoke the correct package manager per OS. On Linux the installer SHALL target Fedora/Nobara `dnf`; for tools absent from base Fedora repositories it SHALL use a COPR repo or `flatpak --user` fallback, and it SHALL bootstrap the mikefarah `yq` (not Fedora's Python `yq`, whose syntax is incompatible with the parser).

#### Scenario: Same tool installed on every OS

- **WHEN** a tool defines both a `brew` and a `dnf` entry (e.g. `ripgrep`, `fzf`, `bat`, `eza`)
- **THEN** running the install script on macOS SHALL install it via brew
- **AND** running it on Linux SHALL install it via dnf

#### Scenario: OS-scoped tool installed only where applicable

- **WHEN** a tool defines only one OS's field (e.g. `aerospace` mac-only, `iio-sensor-proxy` linux-only)
- **THEN** the install script SHALL install it only on the matching OS
- **AND** SHALL skip it on the non-matching OS

#### Scenario: Tool absent from base Fedora repos uses a fallback

- **WHEN** a Linux tool has no base-repo `dnf` package (e.g. `ghostty`, `lazygit`, `lazydocker`)
- **THEN** the install script SHALL install it via its declared COPR repo or `flatpak --user` fallback
- **AND** SHALL record a failure (not abort) if the fallback is unavailable

#### Scenario: Adding a tool propagates everywhere

- **WHEN** the user adds one entry to `packages.yaml` with both `brew` and `dnf` fields
- **THEN** the next install run on each machine SHALL install that tool
- **AND** no per-OS script SHALL need separate editing

#### Scenario: Mac installer path is unchanged by the Linux retarget

- **WHEN** the install script runs on macOS after the Linux branch is retargeted to `dnf`
- **THEN** it SHALL read only the `brew`/`cask`/`npm` fields and install exactly as before
- **AND** no Mac-applied dotfile or Mac package selection SHALL change

### Requirement: Resilient, idempotent install

The install process SHALL be idempotent and SHALL NOT abort the entire run on a single tool failure. Each tool install SHALL be independent and its outcome logged.

#### Scenario: One failing package does not abort the run

- **WHEN** installing the package list and one package fails
- **THEN** the script SHALL record the failure and continue with the remaining packages
- **AND** SHALL report which packages failed at the end

#### Scenario: Re-running is safe

- **WHEN** the install script runs a second time on an already-provisioned machine
- **THEN** already-installed tools SHALL be detected and skipped or reinstalled idempotently
- **AND** the machine state SHALL be unchanged on a no-op run

### Requirement: Install is an explicit recipe, not an apply-time side effect

The system SHALL expose tooling installation as its own front-door recipe (`just install`, wrapping `bin/install-packages`), separate from linking config into `$HOME` (`just link` / `just sync-apply`). Installing packages and placing dotfiles SHALL be independently runnable, so neither can be triggered as an invisible side effect of the other.

#### Scenario: Package install is run deliberately

- **WHEN** `packages.yaml` changes
- **THEN** the new packages SHALL be installed by running `just install`
- **WHEN** config files change but `packages.yaml` does not
- **THEN** `just link` SHALL place them without installing or re-checking any package

#### Scenario: Linking never installs

- **WHEN** `just link`, `just copy`, or `just sync-apply` runs
- **THEN** no package manager SHALL be invoked, and no network fetch SHALL occur
