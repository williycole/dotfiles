# Global rules

## Version control: detect jj vs git before ANY VCS operation
Before running a version-control command, check what manages the repo:

- If a `.jj/` directory exists (repo root or an ancestor), it's a **Jujutsu** repo —
  usually colocated with git. Use `jj` for all history ops (commit, rebase, bookmark,
  push, undo). Do **not** run mutating `git` commands (`git commit/rebase/reset/
  checkout/merge`): jj owns the git backend, so stray git writes fork history and
  leave detached-HEAD messes that need manual `jj rebase` recovery.
- Else if `.git/` exists, use `git`.
- Never mix the two within one repo in a single operation. When unsure which is in
  use, ask before touching history.

Read-only inspection (`git status`, `git log`) is harmless in either, but prefer the
matching tool's own commands (`jj status`, `jj log`). Note `jj log` shows only recent
mutable commits + context by default (revset `present(@) | ancestors(immutable_heads().., 2) | trunk()`);
`jj log -r ::` shows full history. A short `jj log` is normal, not a broken/small repo.

## Reply formatting: use the markdown the terminal colors
Claude Code only syntax-colors code fences and diffs; plain prose is one flat color.
Inline code, bold, headers, links and bullets pick up theme tokens, so format every
reply this way, consistently, at every length:

- Every identifier, file path, command, flag, module, function, setting key in `backticks`.
- **Bold** the lead-in words of each bullet and paragraph.
- Bullets for anything parallel; a short `##` header on replies longer than a few paragraphs.
- Links as bare URLs.

This overrides any "keep code out of prose / one identifier per sentence" house style.
Token cost is negligible. Terse wording rules (caveman) still apply to the words;
formatting is additive.
