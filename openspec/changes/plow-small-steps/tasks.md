All edits are to repo files that are symlinked into `$HOME`, so they go live on save. Work on one jj change. Before task 1.1, commit the unrelated edits already in `@` (as of 2026-11-04: `home/.agents/skills/plow/SKILL.md`, `home/.claude/settings.json`, `home/.pi/agent/AGENTS.md`) as their own change, so they never mix into this one; the line numbers in `design.md` come from that edited `SKILL.md`. Rollback for any task: `jj restore --from <base> home/.agents/skills/plow`. Before the first edit, run `HOME=/tmp/fakehome bin/dots link` and confirm `/tmp/fakehome/.agents/skills/plow/SKILL.md` and `references/autonomous.md` resolve to the repo files; repeat after the last task.

## 0. Human review

- [ ] 0.1 Human review of this change: read `proposal.md`, `design.md`, `specs/` and this file, and approve them in plannotator with zero annotations. Only the human checks this box. An agent running apply stops at this unchecked task and never checks it. Verify: the human checked the box.

## 1. Step loop in gated mode

- [ ] 1.1 Rewrite `SKILL.md` section 3 so the unit is one task-sized step: `jj new` per step, step stays dirty in `@` until reviewed clean, section sealed when all its commits are clean. Verify: `grep -n 'jj new' SKILL.md` hits section 3, and the "one commit per section is the floor" text is gone.
- [ ] 1.2 Update Q1's per-phase gate option and section 4's end-of-run text to describe per-step review. Verify: no remaining text in `SKILL.md` says a human reviews a whole section at once (`grep -n -i 'section' SKILL.md`, read each hit).

- [ ] 1.3 Add the hand-fix rule to section 3: when the human edits a file during a step, plow rereads the changed files, keeps the edit in that step's commit, and never reverts it unless asked. Verify: `grep -n -i 'hand' SKILL.md` hits section 3.

## 2. Size limit

- [ ] 2.1 Add the size rule to step 5: count added plus removed lines, default about 300, configurable, repo check wins when present, over the limit means `unreviewable` (split or redo, never a human). Verify: step 5 names the default, the override, and the redo route.
- [ ] 2.2 Replace the 3000-line seal rule in `references/autonomous.md` (rails and roundup) with a pointer to the step limit. Verify: `grep -n 3000 references/autonomous.md` returns nothing.

## 3. Autonomous is mechanical only

- [ ] 3.1 State the mechanical list (dependency bumps, nth copy of a repeated form, bug hunts, backfills) in Q1 and at the top of `references/autonomous.md`; plow declines autonomous for anything else and offers gated. Verify: both files list the same four kinds, and Q1 still says plow never picks autonomous itself.
- [ ] 3.2 Make the user name the category when picking autonomous. Verify: Q1 or `autonomous.md` step 1 asks for it.

## 4. AI review is bugs only

- [ ] 4.1 Reword step 7 in `SKILL.md` and the review rail in `references/autonomous.md` so the AI pass hunts bugs and edge cases only, its design or clarity opinions are dropped, and a clean AI pass never replaces the human in gated mode. Switch step 7 from `/code-review --fix` to `/review`, and collapse the `/review` versus `/code-review` passages in `references/autonomous.md` to one line. Verify: neither file says the AI review approves or stands in for the human on design, and `grep -n 'code-review' SKILL.md references/autonomous.md` returns nothing.

## 5. No waterfall

- [ ] 5.1 Replace step 3's "say so and stop" boundary text with a per-step prompt: did this step change what `design.md` or `tasks.md` should say; if so, propose the edit. Verify: the prompt appears once in section 3, and the guardrail about contradicting the proposal still exists.

## 6. Plain output and wrap-up

- [ ] 6.1 Add a short output rule near the top of `SKILL.md`: plain short English, result first, step report fits one screen before the diff. Verify: the rule is under ten lines.
- [ ] 6.2 Run `openspec validate plow-small-steps --strict` and the fakehome link check from the top of this file. Verify: both pass, and `jj diff --stat` over this change's own commits lists only the two plow files and this change's directory.
