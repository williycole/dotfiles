# plow — autonomous mode (Herdr panes)

> Loaded by the `plow` skill only when the developer picks **autonomous** in the run-mode
> question. It is a mode, not a separate command. Autonomy is opt-in per run, never a
> property of the skill.

Apply one or more OpenSpec changes **autonomously and in parallel**. Each change runs as its own
`openspec-ralph-apply` loop inside a dedicated **Herdr pane** (a real Claude agent). The main session
is the **orchestrator**: it launches the panes, watches them, answers a lane that stalls, and collects
results. The user watches every lane live and can jump in.

This is the opt-in autonomous mode described in `AGENTS.md`. It replaced the old "march."
**The per-phase gate is still plow's default**, so reach for this only when the developer has
explicitly picked autonomous in the run-mode question or asked for it by name ("herd these",
"run ralph on X Y Z", "no gates"). It relaxes the zero-feedback seal invariant, which is why
it must be chosen out loud and never inferred.

Three levels, each with one job: a **pane** runs one change, `openspec-ralph-apply` inside that
pane runs the loop, and ordinary Task subagents inside the loop run each unit. This file is the
top level only. Read `~/.agents/skills/openspec-ralph-apply/SKILL.md` for the inner loop's
contract and its Section Model.

## Preconditions (check first, bail with a clear message if any fail)

- Herdr is running on this machine: `herdr status` succeeds, `herdr agent list` returns JSON.
- The repo is **jj-colocated** (`.jj/` present). File isolation uses jj **workspaces**, never git
  worktrees (a git worktree cuts from stale `main`).
- Each named change exists and validates: `openspec validate <change> --strict` passes.
- Confirm the change list with the user before spawning anything.

## Non-negotiable rails (same as AGENTS.md autonomous mode)

- **TDD + a `/review` gate before every seal.** Each lane runs `/openspec-ralph-apply` — the generic
  worker: failing test first, implement, verify with tests. **This mode adds one thing on top, because it
  skips your per-phase human review:** the lane's task file (step 2.4) requires a **`/review`** pass on
  each phase's diff before sealing — the local, diff-scoped five-axis review (correctness, readability,
  architecture, security, performance); apply every Critical/Important finding, then `jj commit`.
  `/review` stands in for the human reviewer, so it is the compensating control for going gate-free.
  **Not `/code-review`** (a GitHub-PR tool that needs a PR and roams into unrelated files). This lives in
  the conductor's task file — **`openspec-ralph-apply` stays untouched** (a solo run keeps the human gate,
  so it needs no self-review).
- **A lane decides and logs; it does not pause on ambiguity.** Ambiguity is the normal condition of
  a task written before the code existed, so pausing on it stops a lane far more often than it saves
  one. Exactly two conditions stop a lane instead: the action's effect lives **outside the working
  copy** (a migration that actually ran, a push, a write to a live system, or a file the ignore rules
  keep the VCS from snapshotting), or **only a non-developer seat can tell whether it is right**
  (the routing step prints this as `persona: required`). Property and invariant gates stop under
  the second — the agent cannot see the failure it would be proving. Deletions and retirements do
  **not** stop a lane: the VCS recovers them, and a deletion still routes to a human *reviewer*,
  which is a different question from whether the loop halts. Tell each lane this in its launch prompt.
- **A stopped lane parks, it does not fail the run.** It writes `parked.md` in its change (what it
  was doing, which condition fired, what it needs from a person) and exits. Sibling lanes keep going,
  and the end-of-run output lists what parked beside the review list.
- **Never push.** Lanes may `jj commit` (seal) but never `git push` / `jj git push`. Only the user, with
  the exact phrase "push this", authorizes a push.
- **One lane per change, and lanes in a batch must touch DISJOINT files.** The jj workspace isolates
  each lane's working copy so they never collide *while running*, but overlapping edits to the same file
  collide **at fold time**. Before launching a batch, sanity-check that the changes' file scopes don't
  overlap (each change's `## Impact` / touched dirs). If two must share a file, either sequence them (one
  lane, then rebase the next on its result) or plan a `jj split`/rebase resolution at fold — and say so
  up front. Disjoint boundaries make the fold a clean stack; overlap makes it a merge.
- **Distinct boundaries, ≤3000 lines per seal (HARD).** The whole point of this mode is that the user
  reviews only the finished commits, so each seal must be reviewable on its own. Every sealed commit
  MUST (a) stay within **one distinct code boundary** — one module/domain/concern; do not mix unrelated
  files in a single seal — and (b) be **≤3000 changed lines**. Exception: UI/HEEx and generated assets
  (a big template or asset diff is expected and does not count against the limit). If a task's diff
  would break either rule, the lane splits it into multiple boundary-aligned seals **before moving on**;
  a non-UI phase that blows past 3000 lines means the `tasks.md` phase was too coarse — split the phase,
  re-seal. Tell each lane this in its launch prompt, and verify it at roundup (see step 5).

## Lane modes — per-lane autonomy (auto | gated | paired)

A single `/plow` run can launch several lanes at **different hands-on levels**. Tag each lane with a
mode; the mode changes how the lane runs and how much the user touches it while it works. The point of
the skill is that these compose on one Herdr board — an `auto` lane plows while the user answers a
`gated` lane's checkpoint and actively pairs on a `paired` lane. Three tabs, three worktrees, three
hands-on levels at once.

- **`auto`** — fully headless. Runs the worker + the `/review` gate per phase and seals straight
  through; the user reviews the sealed stack afterward. Use for independent, autonomous-safe work with
  no design dependency and nothing that trips either stop condition. (e.g. `soft-delete`,
  `11-circuit-breaker`)
- **`gated`** — headless BUT stops at declared checkpoints for a yes/no, then resumes. Either stop
  condition is an automatic checkpoint (see the rail above); a change may also name
  its own. The lane surfaces the checkpoint, the orchestrator relays it to the user, and it continues
  only on approval. Use for mostly-mechanical work with one or two real decisions or isolation gates.
  (e.g. `publish-deploy`, `account-settings`, `shell-change-history`)
- **`paired`** — NOT headless. plow only **provisions** the lane (jj workspace + named tab + branch from
  tip); the user and main session drive it interactively in that tab under the normal per-phase human
  gate. No `/review`-gate loop. Use for design/shell work where the human is in the loop the whole time.
  (e.g. `4-design-system`, `6-console-shell`, `8-lineage-graph`, `shell-facets`)

Ask the user for the per-lane modes when confirming the change list (step 1). The specific
change→mode triage for a given epic lives in that epic's tracker (e.g. `openspec/loop-readiness.md`),
not here — this skill stays change-agnostic.

## Orchestration steps

### 1. Resolve the change list
From the user's request or `openspec list --json`. Confirm the set with the user. Note the current `@`
tip commit id (`jj log -r @ -T change_id.shortest(8)`) — lanes branch from there so they see the latest
specs, not stale `main`.

### 2. Per change, create an isolated lane
For each change `C`:

1. **jj workspace** (file isolation): `jj workspace add --name <C> <path-to-workspace-dir> -r <tip>`.
   Name the dir `<repo>-ws-<C>` — the `-ws-` is what the teardown guard in step 4 keys on, so a dir
   named anything else will not be cleaned up. A jj workspace has its own working copy and `.jj`, no
   `.git`, so **anything in the toolchain that expects a git dir breaks there**: in an Elixir repo
   that is dev-only `git_hooks`, fixed by running mix as `MIX_ENV=test`
   (see `[[feedback_herdr_command_center]]`); in another stack it will be a different tool. Find the
   repo's equivalent once, and put it in the lane's launch prompt.
2. **Herdr pane** in that workspace dir. Split direction per the user's standing preference: open with
   `--direction right` (VERTICAL, side-by-side) or a **new tab** — never a horizontal (`--direction
   down`) split first; horizontal only after a vertical. Capture the returned `pane_id` from the JSON.
   ```bash
   split=$(herdr pane split <current_pane> --direction right --cwd <workspace-dir> --no-focus)
   pane_id=$(printf '%s\n' "$split" | jq -r '.result.pane.pane_id')
   ```
   (Or `herdr tab create --cwd <workspace-dir>` and take `.result.root_pane.pane_id`.)
   **Name the tab/agent `<mode>:<C>`** (e.g. `auto:soft-delete`, `gated:publish-deploy`,
   `paired:6-console-shell`) so the board reads at a glance — mode first tells the user how hands-on
   that tab is; the change name tells them which lane. Use the agent name (`herdr agent start <mode>:<C>`)
   and, if `herdr tab` supports a title, set it too.
3. **Start the agent**: `herdr agent start <C> --kind claude --pane "$pane_id"`. A fresh pane may not be
   at its shell prompt yet — if `agent start` errors once, wait briefly and retry.
4. **Prompt it.** Long prompts paste unreliably, so write the task to a file and send a SHORT pointer.
   The task file tells the lane: `cd` into its workspace, run `/openspec-ralph-apply <C>` (add `--fast`
   only if the user asked), obey the rails above (TDD, decide-and-log, park on the two stop
   conditions, never push, plus whatever step 1 found this repo needs to build inside a workspace),
   and end with a decisions list. **The task file MUST spell out the review gate
   explicitly** (this is the autonomous-mode addition on top of the worker, and the only place it lives):
   *"After each phase's tests pass, run `/review` on that phase's diff, apply every Critical/Important
   finding, and only then seal the phase's `jj commit`. Use `/review` — never `/code-review` (a
   GitHub-PR tool that roams with no PR)."*
   ```bash
   herdr agent prompt <C> "Read <abs-path-to-task-file> and execute it exactly."
   herdr agent send-keys <C> enter   # Claude Code's vim input often eats the auto-Enter; this submits
   ```
   Confirm it moved to `working` with `herdr agent read <C>`.

### 3. Watch every lane (push, not poll)
For each lane, arm a background wait:
```bash
herdr agent wait "<pane_id>" --until idle --until done --until blocked
```
Run it **in the background** so the harness re-invokes you the moment that lane settles. **Wait on the
full set (idle, done, blocked), never `--until blocked` alone** — blocked detection only fires on a
recognized approval/question screen, so a real stall can surface as `idle`. Whole-board snapshot any
time: `herdr agent list` or `herdr api snapshot`.

### 4. When a lane settles
- **blocked / idle-but-waiting:** `herdr agent read <C>` to see the dialog. Answer with
  `herdr agent send-keys <C> <key>` (`enter`, `esc`, `up`, etc.). Do **not** blind-`agent prompt` a
  blocked agent — it returns `agent_blocked` and refuses input; `send-keys` is the deliberate path. If
  the lane hit a stop condition and is asking for the human gate, surface it to the user, do not
  auto-approve. Re-arm the wait afterward. A lane that **parked** needs no answer at all: read its
  `parked.md`, carry it into the end-of-run list, and leave the sibling lanes running.

  **Answer it yourself when the standing list covers it.** The point of autonomous mode is that the
  user is not the queue. Escalating a question they have already answered is the failure, not the
  block. Decide these without them:

  - **Dead code** (only remaining callers are tests): delete it and its tests. Never
    relocate-and-rename.
  - **Migrations / schema**, where nothing is deployed: proceed. Dropping a table checks for rows in
    every environment first, then drops.
  - **Tool or dependency bumps, generated artifacts, gitignore**: proceed.
  - **A guardrail fires mid-change**: fix it in scope. Never allowlist-punt to ship faster.
  - **A bug found outside the current task**: fix it, in its own commit, as its own concern — never
    folded into the task's commit.
  - **UI fidelity uncertainty**: render the design and drive it. Never infer from its source or from
    memory.
  - **A follow-on finding that looks like new work**: it goes in the CURRENT change. Never
    `openspec new change` for it.

  Escalate only these: pushing anything (needs the exact phrase "push this"), deleting data that
  exists in a real environment, a security or isolation **tradeoff** (bugs get fixed; tradeoffs get
  asked), scope growing past the change's stated boundary, and any fork where two readings produce
  materially different work and both are defensible.

  **When you do escalate, actually reach them** — do not assume they are watching the board:
  ```bash
  herdr notification show "<lane> needs a call" --body "<the one-line question>" --sound request
  ```
  plus a `PushNotification` for the macOS level, so it lands outside Herdr too. One line, no repo
  content. Reserve it for a real decision, the run finishing, or a stop that stranded a dirty working
  copy — never for phase boundaries or routine progress, or they stop reading them.
- **done:** the lane finished its change. Collect its result (sealed commit stack + decisions list) via
  `herdr agent read <C>` and note it for the roundup.

### 5. Roundup and cleanup
When all lanes are done, **verify the boundary rule before reporting**: `jj diff --stat -r <each seal>`
per lane. Any non-UI seal over ~3000 changed lines, or one that mixes unrelated boundaries, gets split
(`jj split`) before it reaches the user — the review-only promise depends on it. Then report each
change's sealed stack + decisions list so the user reviews commit-by-commit (`jj diff -r <each>`) or via
`/jj:ship`. Fold each workspace's commits into the main history as the user directs, then — once a lane's
work is merged (or discarded) — **fully tear it down.** A half-teardown leaves stale `*-ws-*` dirs and
orphan Herdr tabs piling up, so do all three, in order:

1. `herdr tab close <tab_id>` — closes the lane's tab (and kills the agent running in it).
2. `jj workspace forget <C>` — un-tracks the workspace from jj.
3. **Remove the on-disk dir — guarded.** `jj workspace forget` does **not** delete the directory. Remove
   ONLY the exact path you captured when you ran `jj workspace add` in step 2 — never a reconstructed,
   globbed, or guessed value — and guard it so a wrong/empty value can't nuke something real:
   ```bash
   ws="<the exact workspace path from step 2>"
   case "$ws" in
     *-ws-*)
       if [ -d "$ws/.jj" ]; then rm -rf "$ws"; else echo "refusing: $ws has no .jj — not a workspace"; fi ;;
     *) echo "refusing to rm: '$ws' is not a *-ws-* workspace path" ;;
   esac
   ```
   The guard requires the path to be a `*-ws-*` dir that actually contains a `.jj`; anything else is
   refused. Both halves matter and neither is the project's name: the suffix says *we* made it (step 2
   names workspaces `<repo>-ws-<change>`), and the `.jj` says it is really a workspace. A guard keyed to
   one project's prefix silently refuses to clean up in every other repo. If the path is ever in doubt,
   **skip the rm** and just tell the user the dir to remove by hand.

Never push; wait for "push this".

## Reviewing a finished batch (how the user actually reviews)

Isolation means each lane is its own jj stack; review them **one lane at a time, guided by triage** —
not as one giant blob:

1. **Orchestrator pre-review (triage).** When an `auto`/`gated` lane finishes, the main session runs
   `/review` (or a reviewer subagent) over every sealed commit and hands the user a **ranked "look here"
   list** — which commits carry the risk, which are docs/tests to skim. The user reviews the triage, not
   raw diffs. This is the thing that keeps human review from being the bottleneck.
2. **Fold the lane into the user's local trunk** (`jj rebase`/duplicate onto it) so its commits live in
   one place.
3. **`/jj:review-stack`** walks each sealed commit through plannotator one at a time (phase-by-phase =
   the decisions-list granularity). Deep-read the triaged-risky commits; skim docs/tests/infra.
4. Approve → ship later (only on "push this"). Changes requested → the lane or main session fixes,
   re-seals, and only the touched commit is re-reviewed.

**Never squash before review** — the phase commits + the lane's decisions list are the review map. Squash
only for the final *merge* unit, after review, if a cleaner trunk history is wanted (2–3 by concern beats
one 1700-line blob).

## Notes
- Gate mode (the default) is a conversation in the main session, not this file. Don't reach for this
  unless the developer opted into autonomous.
- If Herdr is not available, say so and offer the fallback: run the changes one at a time via
  `openspec-ralph-apply` in the main session (no parallel panes, no live-watch), or keep the per-phase
  gate.
