# Development Guidelines

## Version control: detect jj vs git before ANY VCS operation

- If a `.jj/` directory exists (repo root or an ancestor), it is a **Jujutsu**
  repo, usually colocated with git. Use `jj` for every history operation:
  `jj new`, `jj commit`, `jj describe`, `jj rebase`, `jj bookmark`, `jj git push`,
  `jj undo`. Do **not** run mutating `git` commands (`git commit/checkout/
  branch/merge/rebase/reset/worktree`): jj owns the git backend, and stray git
  writes fork history.
- Else if `.git/` exists, use `git`. Never mix the two in one operation.
- `jj log` shows only recent mutable commits by default; `jj log -r ::` shows
  everything. A short `jj log` is normal, not a broken repo.

## Working on a change (jj)

- **Never edit on top of `main` directly.** Start with `jj new main` so the
  work is its own change; `main` only moves when the work is done.
- **Bookmarks are plain names**, no `feature/` or `feat/` prefix: `jj bookmark
  set <name> -r @-` after committing.
- **Commit messages** are plain, with no attribution lines. Write them to a
  temp file and pass that; never put backticks on the command line.
- **Finish by moving the bookmark and pushing**: `jj bookmark set main -r @-`
  then `jj git push --bookmark main`. Report the commit, not a merge command.
- **Parallel work** uses `jj workspace add ../<name>`, not `git worktree`.

## Workflow

1. **Assess**: `jj status` and `jj log`.
2. **Start a change**: `jj new main` (or `jj new <bookmark>`).
3. **Work**: edit, run the repo's gate (`just gate` when it exists).
4. **Commit**: `jj commit` with a message from a temp file.
5. **Report**: what changed, how to verify, what was decided alone.
