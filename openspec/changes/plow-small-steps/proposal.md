## Why

Plow's review unit is a whole `## N.` section, and a section can be far too big to read. The last per-phase review was one section at +1228 −68 lines across 23 files. A diff that size gets rubber-stamped, not reviewed, so the human gate plow exists to provide is not really there.

The fix follows two talks the plow user has adopted as their way of working: Zach Daniel, "Exoskeletons, not Autopilots" (ElixirConf US 2026), and Saša Jurić on code quality (Elixir Wizards S15E05). Both say a human owns every change, reviews it in small pieces (Jurić: about 20 to 30 lines per commit), and keeps the agent on a short leash. Autonomy is for mechanical work only, design may change mid-build, and AI review finds bugs but does not judge clarity or design.

## What Changes

- **BREAKING** The review unit becomes one commit per task-sized step, not one section. Within a section the agent does one step, commits it with `jj new`, and the human reviews that commit before the next step starts. A section is sealed when every commit in it has been reviewed clean. Plow no longer splits a section's blob into story commits at the end.
- A step's diff over a size limit (default about 300 changed lines, configurable) gets the `unreviewable` verdict and goes back for a split or redo, never to a human. A repo can supply its own size check, and plow uses it when present. This extends plow's existing redo lane and replaces the 3000-line seal limit in autonomous mode.
- **BREAKING** Autonomous mode (ralph per Herdr pane, auto-seal, no check-ins) is limited to an explicit list of mechanical work: dependency bumps, the nth copy of a repeated form, bug hunts, and backfills. Feature work always runs gated. The user picks the mode; plow never picks autonomous for them.
- Plow's AI review lane hunts bugs and edge cases only. It never approves clarity or design; that stays with the human. The reviewer is the dotfiles `/review` in both modes.
- A hand fix made during a step is kept: plow rereads the changed files and carries the edit in that step's commit.
- No waterfall: when a finished step teaches something new, plow prompts to update the change's `design.md` or `tasks.md` before the next step, and a step may make that update.
- Plow's prompts and reports default to short, plain English. Sections of plow that could be cut or simplified are listed in `design.md` as candidates. This change does not delete them.

## Capabilities

### New Capabilities

- `plow-review-loop`: how the plow skill sizes, routes, and seals work for review, which work may run autonomously, what AI review may judge, and how plow keeps the plan current and its output short.

### Modified Capabilities

None. No existing spec covers plow.

## Impact

- Files: `home/.agents/skills/plow/SKILL.md` and `home/.agents/skills/plow/references/autonomous.md`. Both are linked into `$HOME`, so an edit is live the moment it is saved.
- Behavior: every plow run in every repo that uses it. Gated runs get more, smaller review stops. Autonomous runs refuse feature work.
- Out of scope: any intlxintelligence repo file (its `just review-route` size check is a separate change there), other skills (including `openspec-ralph-apply`, `code-review`, `review`, `jj:split`), and plugins. Plow changes which reviewer it calls, but `/review` itself is not edited.
