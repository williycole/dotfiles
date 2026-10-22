---
name: openspec-ralph-apply
description: Run the OpenSpec Ralph Apply loop as one-task-at-a-time subagent iterations with persistent handoff notes in ralph.md. Optional --fast/--quick mode batches one major section per iteration.
license: MIT
compatibility: Requires openspec CLI and subagent support.
metadata:
  author: local
  version: "1.2"
---

# OpenSpec Ralph Apply

Execute OpenSpec implementation using a RALPH LOOP.

The RALPH LOOP is an iterative workflow:

- Main agent orchestrates the loop.
- Each iteration runs in a SUB AGENT.
- Default: each subagent implements exactly one next sequential task.
- Fast mode (--fast / --quick): each subagent implements one major section (all unchecked tasks in that section).
- tasks.md is updated immediately after that unit of work is complete.
- ralph.md is maintained as rolling handoff context for the next iteration.

## Input

- Optional change name (e.g., my-change). If omitted, infer from context or ask user to choose.
- Optional mode flag: --fast or --quick (aliases; either enables fast mode).

## Mode Selection

Determine mode from the user request before starting the loop:

| Mode | Trigger | Iteration unit |
|---|---|---|
| Standard (default) | `/openspec-ralph-apply`, "run the openspec ralph loop", or no fast/quick signal | One checkbox task |
| Fast | `/openspec-ralph-apply --fast`, `/openspec-ralph-apply --quick`, "fast mode", "quick mode", or equivalent | One major `## N.` section |

Rules:
- `--fast` and `--quick` are equivalent; treat either as fast mode.
- Fast mode is opt-in only. Never use section batching unless the user explicitly requested fast/quick mode.
- Announce at loop start: `Using change: <name>` and `Mode: standard` or `Mode: fast (one section per iteration)`.
- Change name and mode flag may appear together, e.g. `/openspec-ralph-apply --fast my-change`.

## Section Model (fast mode only)

Major sections in tasks.md are level-2 headings numbered sequentially:

```
## 1. First Section Title
- [ ] 1.1 subtask ...
- [ ] 1.2 subtask ...

## 2. Second Section Title
- [ ] 2.1 subtask ...
```

Rules for identifying sections:
- A major section starts at a `## <N>. ...` heading where `<N>` is a positive integer.
- All checkbox tasks (`- [ ]` / `- [x]`) until the next `## <N>. ...` heading belong to that section.
- Subtask numbers (e.g. 1.1, 2.3) are hints only; section membership is determined by heading boundaries.
- If fast mode is requested but tasks.md has no `## N.` section headings, fall back to standard one-task-per-iteration behavior and note the fallback in the announcement.

## Core Rules

- One subagent iteration = one unit of work:
  - Standard: exactly one checkbox task.
  - Fast: exactly one major section (all unchecked tasks in that section).
- Always process work units in sequential order from tasks.md.
- At the start of each iteration, read:
  - `./openspec/changes/<change>/tasks.md`
  - `./openspec/changes/<change>/ralph.md` (if present)
  - OpenSpec context files discovered via CLI (proposal/spec/design/tasks depending on schema)
  - The module contract of every module the unit touches: that module's `usage-rules.md` in
    full, plus the `Use it` and `Don't` sections of each module named in its `## Calls into`.
    One hop, deduped — some modules reference each other, so a transitive walk loops.
- At the end of each successful iteration:
  - Standard: mark only that task as done (`- [ ]` -> `- [x]`).
  - Fast: mark every task in the completed section as done.
  - Update ralph.md with only useful carry-forward context.
  - Remove stale/noisy information from ralph.md as work progresses.
- Loop ends only when all tasks in tasks.md are complete.

## Steps

### 1. Select the change and mode

Parse change name and `--fast` / `--quick` from the user request. If change name is missing, infer from context. If ambiguous, run:

```bash
openspec list --json
```

Then ask user to select a change.

Announce:
```
Using change: <name>
Mode: standard  OR  Mode: fast
```

### 2. Validate and locate artifacts

```bash
openspec status --change "<name>" --json
```

Determine schema and confirm the task artifact path. Resolve:
- `TASKS_PATH=./openspec/changes/<name>/tasks.md`
- `RALPH_PATH=./openspec/changes/<name>/ralph.md`

### 3. Main-agent loop driver

Repeat until all tasks are checked:

1. Read tasks.md.
2. Find the next work unit:
   - Standard: next unchecked checkbox task in order.
   - Fast: next major section (`## <N>. ...` order) with at least one unchecked task.
3. If none remain: stop and report completion.
4. Read ralph.md (if file exists). If missing, treat as empty context.
5. Start a SUB AGENT for exactly one iteration (pass the active mode explicitly).

### 4. Subagent iteration contract (strict)

**Standard mode — subagent must:**
1. Run `openspec status` and `openspec instructions apply` (see below).
2. Read all `contextFiles`.
3. Read the module contracts for the modules this task touches (see Core Rules).
4. Re-read tasks.md and ralph.md.
5. Select the same next unchecked sequential task.
6. Implement only that task's scope.
7. Verify implementation sufficiently for that task.
8. Mark only that task complete in tasks.md.
9. Rewrite ralph.md for the next iteration.

**Standard mode — subagent must NOT:**
- Start or complete additional tasks.
- Reorder tasks.

**Fast mode — subagent must:**
1. Run `openspec status` and `openspec instructions apply` (see below).
2. Read all `contextFiles`.
3. Read the module contracts for the modules this section touches (see Core Rules).
4. Re-read tasks.md and ralph.md.
5. Select the same next sequential section with unchecked tasks.
6. Implement all unchecked tasks in that section.
7. Verify implementation sufficiently for the whole section.
8. Mark every task in that section complete in tasks.md.
9. Rewrite ralph.md for the next iteration.

**Fast mode — subagent must NOT:**
- Start or complete tasks from a different section.
- Reorder sections.
- Leave any task in the target section unchecked.

**Both modes must NOT:**
- Skip `openspec status --change "<name>" --json`
- Skip `openspec instructions apply --change "<name>" --json`
- Write or call into a module without first reading its `usage-rules.md`.
- Leave ralph.md unmaintained after finishing.

## Required ralph.md Structure

**Standard mode:**

```markdown
# Ralph Loop Notes

## Current Change
<change-name>

## Mode
standard

## Last Completed Task
- Task: <verbatim task text>
- Key files changed: <paths>
- Validation performed: <tests/checks run or "not run">

## Next Task
- Task: <next unchecked task text or "None">
- Dependencies/context needed: <only relevant carry-forward notes>

## Open Risks / Follow-ups
- <only unresolved items that affect future tasks>
```

**Fast mode:**

```markdown
# Ralph Loop Notes

## Current Change
<change-name>

## Mode
fast

## Last Completed Section
- Section: <verbatim ## heading text>
- Tasks completed: <list subtask lines or count, e.g. 1.1–1.3>
- Key files changed: <paths>
- Validation performed: <tests/checks run or "not run">

## Next Section
- Section: <verbatim ## heading text or "None">
- Tasks pending: <list unchecked subtask lines in that section>
- Dependencies/context needed: <only relevant carry-forward notes>

## Open Risks / Follow-ups
- <only unresolved items that affect future sections>
```

Cleanup rule: delete completed, irrelevant, or noisy notes every iteration.

## Progress and Completion Reporting

After each iteration, main agent reports:
- Standard: completed task; progress N/M; next task preview.
- Fast: completed section (heading + subtasks); progress N/M; next section preview.

When all tasks are complete, report change name, final M/M progress, tasks.md fully checked, and ralph.md saved.

## Subagent Prompt Templates

**Standard mode:**

```
RALPH LOOP ITERATION - ONE TASK ONLY (STANDARD MODE)

Change: <name>
Mode: standard
Tasks path: ./openspec/changes/<name>/tasks.md
Ralph notes path: ./openspec/changes/<name>/ralph.md

Instructions:
1) Run openspec status and openspec instructions apply for this change.
2) Read all contextFiles from instructions.apply.
3) Read the module contract of every module this task touches: that module's
   usage-rules.md in full, plus the `Use it` and `Don't` of each module named in its
   `## Calls into`. ONE hop, deduped — modules reference each other, so a transitive
   walk loops. Do this before writing any code.
4) Read tasks.md and ralph.md.
5) Identify the next sequential unchecked task.
6) Implement ONLY that task. Do not start another task.
7) Mark only that task complete in tasks.md.
8) Update ralph.md (standard template).
9) Return: task completed, files changed, validation run, module contracts read, next task, blockers (if any).
```

**Fast mode:**

```
RALPH LOOP ITERATION - ONE SECTION ONLY (FAST MODE)

Change: <name>
Mode: fast
Tasks path: ./openspec/changes/<name>/tasks.md
Ralph notes path: ./openspec/changes/<name>/ralph.md

Instructions:
1) Run openspec status and openspec instructions apply for this change.
2) Read all contextFiles from instructions.apply.
3) Read the module contract of every module this section touches: that module's
   usage-rules.md in full, plus the `Use it` and `Don't` of each module named in its
   `## Calls into`. ONE hop, deduped — modules reference each other, so a transitive
   walk loops. Do this before writing any code.
4) Read tasks.md and ralph.md.
5) Identify the next sequential major section (## N. ...) with unchecked tasks.
6) Implement ALL unchecked tasks in that section only.
7) Mark every task in that section complete in tasks.md.
8) Update ralph.md (fast template).
9) Return: section completed, files changed, validation run, module contracts read, next section, blockers (if any).
```

## Guardrails

- Default to standard one-task-per-iteration unless `--fast`, `--quick`, or explicit fast/quick mode was requested.
- Standard: never batch multiple tasks in one iteration.
- Fast: never span multiple major sections in one iteration; always complete every unchecked task in the target section.
- Always re-read tasks.md and ralph.md at each iteration start.
- Always fetch fresh context with `openspec instructions apply --change "<name>" --json` and read `contextFiles`.
- Keep changes scoped to the selected task or section only.
- **Decide and log; do not pause on ambiguity.** Ambiguity is the normal condition of a task
  written before the code existed, so pausing on it stops the loop more often than it saves it.
  Make the call, keep going, and record it in the end-of-run decisions list with what you would
  otherwise have asked. Exactly two conditions stop a lane instead:
  1. **The action's effect lives outside the working copy** — a migration that actually ran, a
     push, a write to any live system, or a file the repo's ignore rules keep the VCS from
     snapshotting (`.env`, secrets, local databases). Version control can undo work inside the
     repo; it can undo none of this.
  2. **Only a non-developer seat can tell whether the work is right.** A privileged actor reads
     everything, so an isolation or permission failure is invisible from where the agent sits.
     Property and invariant gates stop here, because the agent cannot see the failure it would
     be proving.
  Everything else decides, **deletions and retirements included** — the VCS recovers them, and a
  deletion still routes to a human *reviewer*, which is a separate question from whether the loop
  halts.
- **End every run with a decisions list**, one line per call made alone and the question you would
  otherwise have asked. It is a required output, not a courtesy: it is the only record of what the
  loop chose on the developer's behalf, and it is what they read instead of the diff. A run that
  decided nothing emits an empty list saying so, rather than omitting the section.
- A stopped lane **parks**: write `parked.md` in the change (what it was doing, which condition
  fired, what it needs from a person) and exit without failing the run. Sibling lanes keep going.
- If implementation uncovers spec/design inconsistency, report and ask whether to update artifacts before continuing.
- Maintain deterministic sequential progression.
