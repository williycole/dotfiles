## Context

See proposal.md for why. Current state that shapes the approach:

- `SKILL.md` (435 lines) makes a `## N.` section the unit for every mode. Step 3 says "one commit per section is the floor", and step 3 asks for story-order commits, carved with `/jj:split` after the fact when `@` is tangled.
- Step 5 already has an `unreviewable` verdict, but only for scrambled diffs and the `lib/`-only or `test/`-only rule. There is no size rule in gated mode.
- `references/autonomous.md` (248 lines) has a 3000-line per-seal limit, with UI, HEEx, and generated assets exempt. It offers `auto`, `gated`, and `paired` lane modes with no limit on what work may run `auto`.
- Q1 offers four modes: per-phase gate, fast, autonomous, one shot.
- The skill files are symlinked into `$HOME`, so every saved edit is live at once.

## Goals / Non-Goals

**Goals:**

- Make a step small enough to read before it reaches a human.
- Keep the change to the two plow files.

**Non-Goals:**

- Changing `openspec-ralph-apply`, which fast and autonomous mode call. If its section-per-iteration loop no longer fits, that is a follow-up for that skill.
- Deleting the cut candidates listed below. This change only lists them.
- Editing the `/review` command itself.

## Decisions

**A step is one task checkbox, at most.** A task `N.M` in `tasks.md` is the natural step: it already exists, apply already tracks it, and it is about the right size when tasks are written well. A task too big for one step is split into more commits, and plow prompts to split the task in `tasks.md` too. Alternative: let the agent pick step boundaries freely. Rejected because there would be no record of where steps start, and resuming across sessions would get harder.

**Each step is `jj new`, reviewed while it is `@`.** plannotator's review reads `@`, so the step stays dirty in `@` until it is reviewed clean, then `jj new` starts the next one. This keeps plow's existing "leave it dirty and stop" rule; it just applies it per step. Alternative: commit every step and review the stack at the end. Rejected because that is the end-of-section review this change removes.

**Size is changed lines, added plus removed, from `jj diff --stat`.** Simple, matches what a reviewer sees, and needs no tool. The default is 300, not Jurić's 20 to 30, because 300 is the ceiling for "readable at all", not the target size. A repo check, found the same way plow finds the gate, overrides the count. The limit is set in one place; see open questions for where.

**The 300-line limit replaces the 3000-line seal limit in autonomous mode.** Two limits for one question is confusing, and autonomous work is mechanical, so it should split cleanly.

**Autonomous needs a named category.** When the user picks autonomous, plow asks which mechanical category the work is (or reads it from the request) and declines if none fits. Alternative: the change declares its category in its own artifacts. Rejected for now because it adds a field to every change; listed as an open question.

**Every gated step reaches a human.** The router's `human` and `ai` verdicts still run, but in gated mode `ai` no longer means "skip the human". It means the AI bug hunt ran and the human's read can be light (the existing **could** bucket). `human` means the human must read it closely (the **must** bucket). This follows "a human owns every change".

**AI review findings are filtered to bugs.** Plow tells the reviewer to report bugs and edge cases only, and drops any clarity or design opinion it returns rather than applying it. The AI pass runs before the human sees the step, so the human gets a step with known bugs already fixed.

**The AI reviewer is `/review`, in both modes.** The user's dotfiles `/review` is the preferred reviewer (decided 2026-11-04). Gated step 7 switches from `/code-review --fix` to `/review`, and autonomous mode keeps `/review`. The built-in `/code-review` stays installed but plow does not call it.

**Hand fixes are kept.** When the human edits a file during a step, plow rereads the changed files before it continues and treats the edit as part of that step's commit. It never reverts or rewrites a hand fix unless the human asks. This follows Jurić's habit: fix small things yourself, then have the agent refresh its context.

**Plan updates are a prompt, not a stop.** After each step plow asks one question: did this step change what the plan should say? If yes, it proposes the edit to `design.md` or `tasks.md` and includes it in the step's commit or the next one. This replaces the current "say so and stop, then `/opsx:update`" text for the common case.

## Risks / Trade-offs

- [More review stops slow the user down] → Steps are small, so each stop is short. Mechanical work can still run autonomous.
- [Line count is a crude measure; a 250-line step can still be unreadable] → The existing judgment call for scrambled diffs stays. The count only catches the obvious case.
- [Lockfiles and generated files blow the limit for no reason] → See open questions; a dependency bump with a big lockfile is exactly the mechanical case.
- [Edits are live as they are saved] → Do the edits on one jj change in one sitting. Rollback is `jj restore --from <base> home/.agents/skills/plow` or `jj undo`.

## Migration Plan

No data to migrate. Changes in flight keep their existing commits. The next plow run on them uses the new step loop from the next unchecked task. Rollback is restoring the two files from the change's base.

## Open Questions

1. **Which AI reviewer.** Resolved 2026-11-04: `/review` in both modes (see Decisions).
2. **Where the size limit is configured.** Options: an env var, a line in the repo's agent file (`AGENTS.md`), or the repo check alone. The spec only requires that it be configurable.
3. **What the size count excludes.** Autonomous mode today exempts UI, HEEx, and generated assets. Lockfiles and generated code may need the same. An exempt list weakens the rule; no exempt list makes dependency bumps always `unreviewable`.
4. **Does the mechanical list grow.** The list is the four named kinds. `autonomous.md`'s standing answers also treat generated artifacts and gitignore edits as safe. Whether those join the list is the user's call.
5. **Where the mechanical category is recorded.** At the mode question only, or also in the change's artifacts so a later run can check it.
6. **Fast and one-shot modes.** Fast reviews a sealed stack afterward, and one shot runs the whole change with one late review. Both conflict with per-step review and with "never waterfall". Drop them, keep them only for mechanical work, or keep them as they are.
7. **Lane modes in autonomous.md.** With autonomy limited to mechanical work, `gated` and `paired` lanes are close to the normal gated mode in a pane. Whether to keep three lane modes or one.
8. **Who runs the commit.** Saša Jurić: "I don't allow it to commit. I commit myself" (S15). Today plow runs `jj commit` and seals only after a zero-annotation human review. Recommendation: keep plow running the command with the per-step human approval as the gate, since that already means nothing lands unread; have plow hand the commit to the user instead if a commit ever lands without that read.

## Cut candidates

Parts of plow that could be cut or simplified. Listed only; this change deletes none of them.

`SKILL.md`:

- The frontmatter `description` is one long paragraph. It could be two sentences.
- Section 0: the dated "Found 2026-10-20" note (lines 54 to 56).
- Step 2 "Load the contracts" names `lib/`, `usage-rules.md`, `entitlements`, and `analytics`, which belong to one repo. That repo's `operationGuidance` already carries its rules (section 1).
- Step 3 "Commit in an order that reads as a story" and its `/jj:split` advice: replaced by one commit per step.
- Step 4 gate-finding ladder: could be one sentence and one code block.
- Step 5 history of the `lib/` plus `test/` rule (the 2026-10 branch story, lines 221 to 225), and the `scripts/commit-proof.sh` and `just review-route` names, which are one repo's tools.
- Step 6 is about 100 lines. The "learned the hard way" bookmark story, the 151-bookmark and 292-commit anecdotes, the numbering rationale, and the off-by-one explanation could shrink to the rules they produced.
- Step 6 `★` subject marker: a second signal beside the trailer, which has to be stripped before push.
- Step 7 review presentation order: could be a five-item list without the paragraph of justification.
- The bookmark-lifetime guardrail repeats steps 6 and 8.
- The autonomous stop-condition guardrail repeats `autonomous.md`.

`references/autonomous.md`:

- The stop conditions are stated here and in `SKILL.md`. One home is enough.
- The three lane modes (see open question 7).
- `[[feedback_herdr_command_center]]` is a link into private notes. The repo is public and the link means nothing to anyone else.
- The pane split-direction preference is one user's habit, written as a rule.
- "Reviewing a finished batch" overlaps "Roundup and cleanup".
- The `/review` versus `/code-review` passages, which collapse to one line now that `/review` is the reviewer.
- The 3000-line rule, replaced by the step limit.
