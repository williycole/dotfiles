# project-scaffolding

## Purpose
Scaffold a new agentic project (OpenSpec skeleton, rules files, tooling wiring) via the project-init skill, wired to the global openspec-pipeline-loop, with an opt-in autonomy layer.

## Requirements

### Requirement: One-invocation project scaffolding via a skill

The system SHALL provide a `project-init` skill that scaffolds a new project's agentic setup from its own bundled `templates/` into a target directory, producing a project ready to run `/opsx:explore` without manual copying.

#### Scenario: Scaffold a fresh project

- **WHEN** the user invokes `project-init` for a new idea and gives a name + target dir
- **THEN** the target dir SHALL contain the `openspec/` skeleton, a generic `AGENTS.md` (+ `CLAUDE.md` redirect), `.claude/` wiring, and `.mcp.json`
- **AND** the skill SHALL offer to start `/opsx:explore` on the first idea

#### Scenario: Refuse to clobber

- **WHEN** the target dir already contains an `openspec/` directory
- **THEN** the skill SHALL stop and report rather than overwrite existing project files

### Requirement: Skill is portable and version-controlled

The `project-init` skill SHALL live in the dotfiles repo at `skills/project-init/` (`SKILL.md` + a self-contained `templates/`) and be deployed into each agent's skill directory (`~/.claude/skills/`, `~/.pi/agent/skills/`). Because those are separate copies rather than links, `SKILL.md` SHALL NOT hard-code one agent's path: it SHALL resolve `templates/` by trying each known location and taking the first that exists, with the repo checkout last, so the same file is correct under every agent and on a machine where only the repo is present.

#### Scenario: Self-contained and backed up

- **WHEN** the skill is installed
- **THEN** its canonical template files SHALL live inside the skill's own `templates/` (no repo-root `templates/` dir, no `bin/` script)
- **AND** the dotfiles repo SHALL carry the canonical copy at `skills/project-init/`, so the skill is version-controlled rather than living only in an agent's skill directory

#### Scenario: Available without the dotfiles repo cloned

- **WHEN** the skill is restored on a machine via the `~/.agents/local` backup + symlinks
- **THEN** it SHALL be invocable from any Claude session
- **AND** SHALL NOT require the dotfiles repository to be checked out to scaffold a project

### Requirement: Layer 1 skeleton always scaffolded

The skill SHALL always scaffold the Layer 1 skeleton: an `openspec/` tree (`config.yaml`, `README.md`, `work-order.md`, and empty `specs/`, `changes/` (with `archive/`), `explore/`, `issues/`), a generic `AGENTS.md` with a `CLAUDE.md` redirect, `.claude/` command wiring, and an `.mcp.json` including playwright.

#### Scenario: Skeleton is complete and valid

- **WHEN** scaffolding completes
- **THEN** `openspec/` SHALL contain the spec-driven directory layout (`specs/ changes/ explore/ issues/` + `config.yaml` + `work-order.md`)
- **AND** `AGENTS.md` SHALL contain the generic baseline (TDD rule, ponytail mode, commit format, skills manifest) with `CLAUDE.md` redirecting to it

#### Scenario: Stack commands are placeholders unless given

- **WHEN** the generic template is scaffolded and the user gave no stack/test command
- **THEN** language- and test-specific commands (e.g. `config.test`) SHALL be left as clearly marked fill-in-the-blank placeholders (`# TODO`)
- **AND** WHEN the user provides a test command in the interview, the skill SHALL fill it in

### Requirement: Layer 2 autonomy is opt-in and points at the global skill

The skill SHALL make the autonomous pipeline opt-in via a single `openspec/pipeline/config.json`, and SHALL NOT copy the loop implementation into the project — the loop is the global `openspec-pipeline-loop` skill.

#### Scenario: Opt in to the loop

- **WHEN** the user chooses to include Layer 2
- **THEN** only `openspec/pipeline/config.json` SHALL be added (no `loop-prompt.md`/sub-agent-template/scripts copied)
- **AND** the project SHALL be runnable via the global pipeline skill with that config

#### Scenario: Decline the loop

- **WHEN** the user declines Layer 2
- **THEN** no `openspec/pipeline/` SHALL be created
- **AND** the project SHALL still support the manual lifecycle (`/opsx:explore → propose → apply → archive`)

### Requirement: Low-friction defaults with documented upgrade path

The scaffolded `config.json` SHALL default to fully-local, low-friction settings (`review:local`, `push:false`, `merge:human`, `workOrderIssue:null`), and the template SHALL document how to upgrade to GitHub + CodeRabbit.

#### Scenario: Defaults are local and human-gated

- **WHEN** a `config.json` is scaffolded with defaults
- **THEN** it SHALL set `review:"local"`, `push:false`, `merge:"human"`, `workOrderIssue:null`
- **AND** the project README SHALL document switching to `forge:"github"`, `review:"coderabbit"`, `push:true`, and a work-order issue number
