---
name: guided-review
description: "Guided review: turn a branch, PR or diff range into one self-contained page that walks a human through the design, every file's diff, and the decisions they still owe. Use for 'guided review', 'walk me through this change', 'make a review artifact', or reviewing a change too large to read in file order."
---

Build a page a reviewer can trust: chapters in order of importance, the complete diff, every claim checked against the code, and every open decision named.

This orients and verifies. It is separate from a bug hunt: pair it with `code-review` when the change needs one. For a quick tour inside Plannotator's own diff viewer, its built-in Guided Review is faster; reach for this skill when the change carries decisions or the reviewer has to sign off on it.

## 1. Capture the change

Detect the VCS (`.jj/` means `jj`), then write the patch to a scratch file:

```bash
jj diff --from <base> --to <tip> --git > change.patch   # or: git diff <base>...<tip> > change.patch
```

Done when the patch exists and you can name the base, the tip, and the file count.

## 2. Build the promise ledger

Read what the change was meant to do: spec, design, task list, issue, PR body, commit messages, notes left by whoever built it. Write down each promise and each "done" claim as a line in a scratch ledger.

Done when every source is read, or you have recorded that none exists.

## 3. Read the diff

Read every hunk of every hand-written file. For generated, vendored or lock files, confirm that they are generated and how. Read large patches in chunks.

Done when each changed file is marked **read** or **skimmed, because...**. The page's provenance section reports these marks as they stand.

## 4. Write the chapters

- **Order by importance.** The part that unlocks the rest comes first, so the reviewer can stop after any chapter having seen what matters most. Glue and generated files go last under a plain title.
- **Chunk by logical change.** Three files changed for one reason form one chapter. Use 2-6 chapters, 10 at most.
- **Every overview does three jobs:** what changed, why this way and not another, and what it now implies for people and systems. Say plainly which chapter deserves the slowest read. Add a concrete example where the behavior is hard to picture.
- **Every file gets a tier and a reason.** `attention`: decides what users, data or privileges can reach, or runs with privilege, so read it whole. `check`: worth a look. `safe`: tests, docs, generated data.
- Write for a capable reader new to this codebase. Spell out project shorthand the first time it appears.

Field names and rules are in [references/guide-schema.md](references/guide-schema.md).

Done when each changed file sits in exactly one chapter or in `unplaced`. The builder refuses anything else.

## 5. Check every claim

Be relentless, because this step is where the guide earns trust. Assume your draft is wrong.

- **Receipts:** run a command for every number, and for every "all", "only", "every" and "never" in your text. Fix what fails, or cut the claim.
- **Ledger against code:** for each promise, find the code that keeps it. A task marked done with a smaller build behind it is a finding, and so is a verification step that never ran.
- **Blast radius:** for each new limit or removal, ask who or what stops working the day this ships. Trace the reviewer's own workflow too, including how this very change gets reviewed and merged.

Done when each claim has a receipt, each ledger line is marked kept, changed or unverified, and each mismatch is fixed in the text or carried into step 6.

## 6. Name the decisions

List what a human must settle, grouped by when: before merging, before rollout, or just to confirm. Choices the author made alone that the spec left open belong here too. Each decision gets the problem, the real options, and one recommendation. Mark it as needing the human when you cannot judge it alone.

Done when each ledger mismatch and open question appears as a decision, or the page states that there are none.

## 7. Write the provenance

State how the page was made: what was read in full, what was skimmed, which checks ran and which did not, and that the tiers are your judgement. Keep tested-here and needs-a-live-run in separate lists.

Done when a reader can tell which sentences to trust least.

## 8. Build and deliver

```bash
python3 -I "$SKILL_DIR/scripts/build_guide.py" guide.json change.patch review.html
```

`$SKILL_DIR` is this skill's directory. The builder enforces coverage, escapes all text, and emits a single page with no scripts and no external loads, so it renders with JavaScript off and offline. It fails loudly and names the problem; fix `guide.json` and rerun.

Deliver through whatever this host offers. With an artifact tool, build with `--fragment` and publish that, private by default. Otherwise hand over the file path. Keep this session free: a viewer that blocks until a browser tab closes runs in the background. Confirm the human can actually open the page where they read it, since local pages may be blocked on managed browsers.

End your reply with the link, the decision count, the top decisions, and what you did not read or run.
