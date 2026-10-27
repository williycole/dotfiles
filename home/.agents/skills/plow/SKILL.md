---
name: plow
description: "The single front door for coding work, from a bare idea to a sealed change. Picks the lane first — /wayfinder when the route is unclear and spans sessions, /grill-with-docs or /grilling for a one-sitting decision, /opsx:propose once the decisions are made — then drives the change: reads where it sits (openspec status --json), asks how you want to work it (per-phase gate, one section per iteration, autonomous panes), and runs that loop. Implement a `## N.` section, gate it, route the diff to human review, AI review, or back for a redo when it is unreviewable, seal only on a clean review. Autonomous decides and logs, parking only when an action reaches outside the repo or only a non-developer seat can judge it. Ends by printing what needs human eyes and what parked. Use for 'plow this', 'what should I work on', 'plan this', 'work <change>', 'implement <change>', 'apply the next phase', 'herd these', 'no gates on these'. Coding work only — `/brief` writes the outward view."
license: MIT
compatibility: Requires the openspec CLI. Autonomous mode also requires Herdr and a jj-colocated repo.
metadata:
  author: local
  version: "1.1"
---

# plow

The steering wheel over work that already has a home. OpenSpec owns the artifacts and the
lifecycle, `just` owns the gates, `openspec-ralph-apply` owns the loop, plannotator owns review.
plow decides **which of them runs, in what order, with what loaded** — and nothing else.

**Coding work only.** Never ask which job the developer meant; the command name already answered
that. `/brief` produces the outward view. If the request is that, say so and stop.

**Read facts, ask intent.** Anything a tool can answer, plow reads without asking: where the
change sits, which tasks are unchecked, which files a diff touches, what the gate said. Only how
the developer wants to work right now gets asked. Asking about a fact the tool already knows is
how an interview becomes a chore people skip; guessing at intent is worse, because a wrong guess
stays invisible until the work comes back in the wrong shape.

## 0. Pick the lane

**plow is the one front door, so the first question is "what are we doing?", not "which change?".**
Everything below section 0 assumes a change already exists, and for most of a project's life it
does not yet. Reaching the right planning tool should not depend on remembering it exists.

Read what you can before asking. A change slug in the request answers this outright, and so does
`openspec list --json` when the developer names work already on the board. Ask only when the
request is genuinely new work.

| What is in front of the developer | Lane | Why this one |
|---|---|---|
| An effort too big for one session, and the route is unclear | `/wayfinder` | Charts which decisions are needed before any of them is made. Multi-session by definition. |
| Settles in one sitting, but the answer depends on what the codebase already does | `/grill-with-docs` | Grilling with the code loaded. Most "should we do X here" questions are this. |
| Settles in one sitting, a pure product call | `/grilling` | No codebase lookup needed. Cheapest path to a decision. |
| The decisions are already made | `/opsx:propose` | Writes the artifacts. It still inspects the code to ground them; it must not invent product decisions. |
| It belongs to a change that already exists | `/opsx:update` | Not a new change and not a build. Fold the answer into the plan that owns the subject, and keep its artifacts coherent. |
| A change already exists and is ready to build | Section 1 below | The loop plow has always driven. |
| An idea nobody is working yet | `/backlog` | A note, not a change. Promote it later with `just promote`. |
| The work turns out to be already done | **Say so and stop.** | Verify before routing. Planning finished work is worse than doing nothing, because the artifact then lies about the code. |

**Session count is the split between the first three**, not project size. If it fits in one
conversation, grilling is cheaper and better; `/wayfinder` is slower and denser for that case.

**Check whether the subject already has a change before opening a new lane.** `openspec list
--json` plus a look at the matching change's `proposal.md` is cheap, and the common shape of a
small question is that some existing plan already owns its subject and simply never answered it.
Grilling it standalone produces a decision with nowhere to live; `/opsx:update` puts it where the
builder will read it. *Found 2026-10-20 testing this table: asked whether a resources row should
show a derived scope or a literal, the right answer was to fold it into `source-customer-scoping`,
and this table had no row for that.*

A cleared `/wayfinder` map does not hand off to a build. It hands off to `/opsx:propose`, which
reads the decided map. Lanes chain: `/wayfinder` → `/grilling` per ticket → `/opsx:propose` →
section 1.

**plow runs none of these itself.** It picks which one, and gets out of the way. Routing is the
whole job; the moment plow starts doing a lane's work instead of naming it, the "and nothing else"
above has stopped being true.

## 1. Read the state

Never ask the developer where things stand. Derive it:

```bash
openspec status --change "<id>" --json
```

Then, in order:

| What the JSON says | The next step |
|---|---|
| An artifact has `status: "ready"` | Create that artifact — `/opsx:continue`. Planning is not done. |
| An artifact has `status: "blocked"` | Name the artifacts in its `requires` that are not `done` yet. |
| Every id in `applyRequires` is `done` (`skipped` counts as satisfied) | Apply is unblocked. Read progress, below. |

```bash
openspec instructions apply --change "<id>" --json
```

- `progress.remaining > 0` → the next step is the `## N.` section holding the first unchecked task.
- `progress.remaining == 0` → the next step is `/opsx:verify`, then `/opsx:archive`.

Also read `operationGuidance` from that same JSON and **follow it**. It carries the repo's gate
order, review routing, persona rule, and module-contract rule, and it reaches every apply run
whether or not plow invoked it. plow does not carry its own copy of those rules.

State it in one line before asking anything: `<id>: planning done, 5/19 tasks, next is ## 2. Run
modes and the section boundary.`

If no change id was given, `openspec list --json` and ask which one. That is a fact the developer
holds, not one a tool can answer.

## 2. Ask intent

Two questions, in this order. Each is a prompt with two to four options; every option says what
actually happens if it is chosen, and one is marked recommended. **This is data, not a tool call.**
Render it with whatever picker the harness provides, or print it as plain text and read the reply
if it has none. Skip a question whose answer the developer already gave in their request.

**Q1 — How should this run?**

| Option | What happens |
|---|---|
| **Per-phase gate** *(recommended)* | One `## N.` section, gated, reviewed, left dirty in `@`. Seals only on a review with zero annotations. You look at every phase. |
| Fast | `/openspec-ralph-apply --fast` — one `## N.` section per iteration, no stop between them. You look at the sealed stack afterward. |
| Autonomous | One ralph loop per change in its own Herdr pane and jj workspace. `/review` stands in for you on each phase. Relaxes the zero-feedback seal rule; never chosen for you. |
| One shot | A plain `/opsx:apply`. Runs the **whole change** to the end in one go — apply cannot see a `## N.` boundary. One commit, one very late review. |

**Q2 — How many lanes?** *(only when more than one change is in play, or the answer to Q1 was autonomous)*

| Option | What happens |
|---|---|
| **This session** *(recommended)* | One change at a time, right here. You watch and answer inline. |
| A pane per change | A Herdr pane and jj workspace per change, watched with `herdr agent wait`. Lanes in a batch must touch disjoint files or they collide at fold time. |

Autonomous never starts from silence. If Q1 came back autonomous, load
`references/autonomous.md` and follow it; no pane opens before that answer exists.

## 3. Run the loop

The unit is the `## N.` section for every mode. **The single home for that parse is the Section
Model in `~/.agents/skills/openspec-ralph-apply/SKILL.md`** — a section starts at a `## <N>. …`
heading, every checkbox line until the next such heading belongs to it, and the `N.M` subtask
numbers are hints for readers, not the parse. Do not restate those rules as behavior of your own,
and do not write a second parser.

Per-phase gate, one section at a time:

1. **Note the base.** Before touching a file, record the commit this section will sit on top of:

   ```bash
   jj log -r @- --no-graph -T 'change_id.shortest(8)'
   ```

   That id is the only place this section's review bookmark may point. Capture it now — once the
   section seals, `@-` means something else.
2. **Load the contracts.** Read the `contextFiles` from `openspec instructions apply --json`, then
   the `usage-rules.md` of every `lib/` module the section touches, plus the `Use it` and `Don't`
   of each module named in their `## Calls into`. One hop, deduped — `entitlements` and
   `analytics` reference each other, so a transitive walk loops. OpenSpec has no concept of this;
   `contextFiles` covers the change's own artifacts and nothing else.
3. **Implement the section.** TDD on all backend code: failing test first, watch it fail, green.
   Update every comment, `@moduledoc`, and `usage-rules.md` the diff makes stale, in the same diff.

   **Commit in an order that reads as a story, not just in small pieces.** One commit per section is
   the floor, not the target. Where a section does more than one thing — a rename, then the feature
   that needed it, then its test — seal them in that order as separate commits, so a reader can
   follow one thread at a time. `/jj:split` carves a tangled `@` apart. This is what keeps step 5
   from returning `unreviewable`.

   **If the task boundary turns out to be wrong, say so and stop.** `tasks.md` was written before
   any of this code existed, so a task that read as one thing is sometimes three. Do not quietly
   plow through a boundary you no longer believe in and do not silently re-plan either: name what
   the section actually contains, and fold it back with `/opsx:update` so the change's own record
   stays true. Proposing the plan is `/opsx:explore` and `/opsx:propose`; this is only about
   correcting one that has met reality.
4. **Gate it.** Run **the repo's own quality gate**, plus `openspec validate <change> --strict` so
   a task id under the wrong `## N.` group fails here. Arrive green.

   **Find the gate, do not assume it.** In order, stopping at the first that answers:

   ```bash
   just --show gate 2>/dev/null        # a `gate` recipe is the convention plow expects
   just --list 2>/dev/null             # some other obviously-named recipe: ci, check, verify
   ```

   Then the repo's own documentation — `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md` — and then the
   package manifest's scripts (`mix.exs` aliases, `package.json` scripts, `Makefile`, `Taskfile`).
   If none of that answers, **ask the developer once and write their answer into the repo's agent
   file**, so the next run finds it at step one instead of asking again.

   Say which one you used the first time you run it. A gate nobody can name is a gate nobody
   trusts, and silently running the wrong command looks identical to passing.

   **The gate runs the tests; it does not judge them.** Read the tests this section added before
   moving on. LLMs are at their worst in tests and documentation, and green says nothing about
   whether a test is worth keeping. Reject and rewrite a test that:

   - asserts on implementation detail instead of behaviour (Ian Cooper, *TDD: Where Did It Go
     Wrong?* — test behaviour, not internals);
   - is slow for no reason: a real case ran 15 seconds for a small service because it never set a
     test-environment timeout;
   - generates a module, process, or fixture per test case when one shared setup would do;
   - passes whether or not the code under it works.

   A suite that grows this way costs more than it protects, and no gate will ever tell you.
5. **Route the diff.** Mechanical, from the diff — never asked, never a judgment call.

   If the repo ships a router (`just review-route` here, found the same way as the gate), run it:
   it prints `review: human|ai` with its reasons and `persona: required|not required`.

   **If it does not, route by the same rule the router encodes**, which is not project-specific:
   a diff goes to a **human** when it deletes a file, removes a public function, touches a
   migration, touches the rules files an agent obeys, or edits one of the repo's declared
   sanctioned paths for a risky job — its doors, however that repo names them. Everything else
   goes to AI review. Say which rule fired.

   `persona: required` means the section is not done until it has been verified as a seat that
   cannot see everything — a `:customer`-scope persona here, whatever the least-privileged real
   user is elsewhere. A privileged actor reads everything and hides the bug.

   **There is a third verdict: `unreviewable`.** Not every diff is fit to be read, and handing a
   reviewer one that isn't wastes the only scarce thing in this loop. The fix is never a more
   careful reviewer, it is a redo. Never route `unreviewable` to a human and never seal it.

   **One case is checked rather than judged: a `feat` or `fix` commit may not touch only `lib/`
   or only `test/`.** Code with no test beside it cannot be verified while you read it; a test
   with no subject cannot be read at all. `scripts/commit-proof.sh` decides it and
   `just review-route` raises it, so it fires whether or not anyone is watching. The
   conventional-commit type is the exemption and the only one — a `refactor`, `chore`, `perf` or
   `style` commit correctly carries no new test and already says so in its own subject. There is
   deliberately no opt-out flag to reach for. A repo with no `lib/` + `test/` layout is skipped,
   not failed.

   The rule is checked because as prose it was ignored. The 2026-10 branch came out with 45
   commits cut along directory lines — "code (analytics)", then "tests (web)" — of which 36
   `feat`/`fix` commits shipped behaviour with nothing proving it. The cause was mechanical, not
   careless: jj's `:builtin` diff editor is a modal TUI an unattended lane cannot drive, so the
   loop chunked by directory because it had no other way to cut.

   **Split with `jj-hunk`, not the builtin editor.** It selects hunks from a query with no editor
   and no keyboard, which is what makes the rule obeyable in a pane nobody is sitting at:

   ```bash
   jj-hunk list  --rev <change-id> --format text
   jj-hunk split --query 'changed(path:glob:"**/analytics/**")' "feat(analytics): …"
   ```

   `/jj:split` stays the interactive route when you are at the keyboard.

   **The other case is still a judgment call**, and stays one: a diff that interleaves unrelated
   work — a little refactoring, then a new field, then more refactoring — so no reader can follow
   one thread through it. Small is not sufficient; a small diff in scrambled order is still
   unreviewable. Saša Jurić's framing, and he is right that the usual cause is an author who did
   not use commits to tell the story.
6. **Say so in the commit, if it routed to a human.**

   An agent reads every commit. The question left over is narrower — *what must the developer
   read on top of that* — and the commit answers it itself, with a trailer:

   ```
   feat(analytics): the row guard checks the declared field, on both read paths

   Review: you — touches a door
   ```

   Three buckets decide whether it gets one:

   | | | |
   |---|---|---|
   | **must** | the developer, no substitute | a door, a migration, deleted code |
   | **could** | agent already read it; open it if curious | ordinary code, docs, specs |
   | **agent** | never needs the developer | templates, CSS, JS, images |

   Only **must** gets the trailer, and the reason is the first line `just review-route` printed.

   **A trailer, not a bookmark. This was learned the hard way.** The obvious move is to bookmark
   each must-read and let the picker be the to-do list. It does not work: a review tool's commit
   list shows subjects, not bookmarks, so while you are actually reading, 119 bookmarks tell you
   nothing. They answer "where does this range start", which is a different question asked once.
   Worse, a bookmark is a pointer that needs its own cleanup and goes stale the moment a commit
   is rewritten.

   A trailer travels inside the commit. It survives every rebase, it is greppable
   (`jj log -r 'main..@' -T description | grep -c 'Review: you'`), it needs no cleanup, and it
   is visible in the one place the developer is already looking.

   Bookmarks stay for what they are good at: naming a range, so `r/<LL>.<NN>` can still mark a
   lane boundary when a branch needs one. They are not the review signal.

   ```bash
   jj bookmark set r/<LL>.<NN>-<slug> -r <base-from-step-1>
   ```

   `LL` is the lane's position on the branch, `NN` the section's position inside it, `slug` at
   most 14 characters of the subject. `r/03.07-every-wall`. The name says *where*, not *why* —
   the router already printed the reason, and repeating it in the slug spends the column width
   that makes the thing findable.

   **What counts as a door is the repo's to say, and the repo says it in the code.** A door
   declares itself with a `plow:door` marker in the module's doc comment, or in a directory's
   `usage-rules.md` to cover everything beneath it. plow finds them with
   `grep -rl 'plow:door'` and needs no path list, no config file and no per-repo bolt-on.

   This matters more than it looks. A hardcoded path list is a second source of truth that fails
   *open*: rename a security-critical file and it silently stops routing to a human, with nothing
   to notice. A marker travels inside the file. A repo that marks nothing still gets the other
   two must conditions, since migrations and deleted code mean the same thing everywhere.

   **The number leads, and that is the whole point.** A picker gives you lexicographic sort and
   nothing else, so putting position first is what makes alphabetical order equal reading order.
   The earlier `plow-review/<lane>/<long-slug>` form sorted by lane *name*, which put lane 09
   above lane 01, and ran to 73 characters so the useful half was truncated away. Two-part
   numbering beats a flat index because inserting a section renumbers one lane, not the branch.

   **On the base, never the tip.** plannotator's Line-of-work mode diffs `<FROM>..@` and its
   FROM-picker lists bookmarks only, so a bookmark on the tip yields an empty diff and a blank UI.
   `-r @` *is* the tip: jj moves a bookmark along with every working-copy amend, so one set on `@`
   before the work ends up on top of the work. Use the step-1 id, or set it retroactively on any
   change id — jj bookmarks never auto-advance. A consequence worth stating: the bookmark names
   the section it *opens* while sitting on the commit before it, which reads as off-by-one in
   `jj log` and is the price of a range with no "to".

   Keep the first reason line the routing step produced; it is what the end-of-run list shows.
   A section the router cleared gets **no** bookmark, which is what keeps the FROM-picker showing
   only work that actually needs reading. That sentence has been here from the start and was
   never implemented — 151 bookmarks accumulated on one branch with nothing pruning them. Create
   one only when the verdict is `human`.
7. **Review.** `ai` → `/code-review --fix`, resolve what it surfaces. `human` → leave the section
   **dirty in `@`** and stop. The developer runs `/plannotator-review`, which reads `@`, so the
   diff has to still be there.

   **Present it easiest-to-validate first, with the diff last.** A reviewer who starts in the diff
   spends their sharpest attention on the hardest-to-judge thing, and arrives at "does this
   actually work" with none left. Order:

   1. **See it run.** A UI change gets screenshots or the running app. Nothing to look at is itself
      an answer, so say so rather than skipping the rung.
   2. **What changed**, in plain language. What behaves differently now.
   3. **What the agent decided alone** — the decisions list, and `checked.md` if the change has one.
      Short by construction; if it is long, that is the finding.
   4. **What was asked for**, ticked against the tasks with evidence.
   5. **The diff**, line by line. Last, because by here the reviewer already knows what they are
      looking at and can spend the attention on the code instead of on orientation.
8. **Seal only on a clean review, and drop the bookmark with it.** Zero annotations *is* the
   approval: `jj commit -m "…"` and move to the next section, no extra "go" needed. Any feedback
   means apply it, re-present the dirty `@`, and get reviewed again. Never seal off a review that
   had feedback. Once a section is reviewed and sealed clean, `jj bookmark delete
   r/<LL>.<NN>-<slug>` — the bookmark's only job was "this is waiting to be read", and a read one
   left behind just pads the picker. **This deletion is part of sealing, not a later sweep.**
   Skipping it is how a picker reaches 151 entries that all look equally urgent.
9. Mark the section's tasks `- [x]` in `tasks.md` as you finish them. Those checkboxes are apply's
   only state, so the change resumes correctly across sessions with no bookkeeping.

Fast mode runs steps 1–6 and 9 per section via `/openspec-ralph-apply --fast <change>`, with review
deferred to the sealed stack — the bookmarks are what make deferring it survivable, so they still
get set. Autonomous mode is `references/autonomous.md`; its lanes each run in their own jj
workspace, so `<FROM>..@` resolves against whichever workspace you review from — review a lane from
its own workspace, or walk the sealed stack with `/jj:review-stack`.

## 4. Finish with the review list

Every run ends by printing what needs human eyes, and nothing else:

```
needs human review:
  r/02.02-roadmap-file   ## 2. Roadmap file   touches a door
  r/02.04-page-render    ## 4. Page render    adds or changes a migration

  /plannotator-review → Line of work → pick the bookmark as FROM.

parked:
  source-customer-scoping  ## 6. i360 values   outside the repo (needs a DB grant)
```

**Parked lanes print beside the review list, never instead of it.** A parked lane is not a
failure and not a question waiting for an answer — it is work that stopped itself on one of the
two stop conditions while its siblings kept going. One row each: the change, the section, and
which condition fired. Its `parked.md` holds what a person needs to finish it. An empty parked
list prints nothing at all, not an empty header.

One row per bookmark, with the one-line reason the routing step gave for it. An empty list is a
real result, not a missing one — say so in one line and print no table. It is the *normal* ending
for gate mode, where each section was read and its bookmark dropped as it sealed. The list earns
its keep in fast and autonomous mode, where review is deferred and the bookmarks pile up.

The developer then runs `/plannotator-review`, picks a bookmark off the FROM list, and reads that
line of work. Sections that went to `/code-review --fix` never appear, because they never got a
bookmark.

## Guardrails

- Never push. `jj commit` is normal work; `jj git push` needs the exact phrase "push this".
- **A review bookmark lives exactly as long as its section is unread.** It is created when the
  router says human, and deleted the moment that section comes back reviewed and approved — which
  in gate mode is the same breath as the seal. Everything else is a backstop sweep for one that
  escaped: `jj bookmark delete 'glob:r/*'` before any push (`jj git push --all` ships every
  bookmark to origin, review scaffolding included), again once the work merges or the change
  archives, and once at the top of a plow run to clear leftovers from a change that already
  shipped. `jj bookmark list 'glob:r/*'` shows what is outstanding. The `r/` prefix exists for
  exactly this: one glob deletes the lot, and the `/` keeps it clear of the slug-named bookmark a
  change ships under. It is two characters because the prefix is column width spent before any
  information starts, and a picker shows roughly forty.
- Autonomous **decides and logs**; it does not pause on ambiguity. Two conditions stop a lane and
  nothing else: the action's effect lives **outside the working copy** (a migration that ran, a
  push, a write to a live system, or a file the ignore rules keep the VCS from snapshotting), or
  **only a non-developer seat can tell whether it is right** (the routing step prints
  `persona: required`). Property and invariant gates stop under the second, because the agent
  cannot see the failure it would be proving. Deletions and retirements do not stop a lane — the
  VCS recovers them — though a deletion still routes to a human *reviewer*, which is a separate
  question. A stopped lane writes `parked.md` and exits without failing the run; siblings keep going.
- Don't squash-fold mid-loop. Folding empties `@` and breaks the next phase's plannotator read —
  and it rewrites the bases the review bookmarks point at, which jj follows, so a bookmark that
  named a real diff silently starts naming an empty one.
- If the implementation contradicts the proposal, design, or specs, stop and ask whether to update
  the artifacts. Don't quietly build the other thing.
