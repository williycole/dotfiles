# OpenSpec — {{PROJECT_NAME}}

Spec-driven workflow: describe a change as docs *before* writing code, build against
them, then fold the result into a permanent spec library.

**Mental model:** `specs/` = now · `changes/` = becoming · `explore/` = maybe.

## Layout

```
openspec/
├── config.yaml          # schema: spec-driven + project context
├── work-order.md        # the queue: planned / doing / next
├── specs/               # WHAT IS — capabilities now (auto-updated on archive)
├── changes/             # WHAT'S CHANGING — one folder per in-flight change
│   └── archive/         #   completed changes, dated; delta folds into specs/
├── explore/             # WHAT YOU'RE THINKING — free-form notes before a proposal
└── issues/              # issue tracking (optional)
```

## Lifecycle

```
explore → propose → apply → archive → sync
 (note)   (change)  (build)  (move)    (fold delta into specs/)
```

- `/opsx:explore` — think through an idea → note in `explore/`
- `/opsx:propose` — generate a full change (proposal + design + specs + tasks)
- `/opsx:apply` — implement tasks, ticking `tasks.md`
- `/opsx:archive` — finalize: move to `archive/`, fold deltas into `specs/`
