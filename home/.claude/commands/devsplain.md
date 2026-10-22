---
description: Explain what changed between two approaches — produces a 1-1 mapping of old → new with logic equivalence notes and gap analysis
---

The user wants to understand how code, patterns, or approaches map from one version to another. Produce:

1. A one-paragraph summary of what changed and why
2. A mapping table: old module/pattern/behavior → new equivalent, with notes on what's the same vs different
3. A prose section confirming logic equivalence (or flagging where behavior actually changed)
4. A gaps section listing anything from the old approach with no new equivalent yet

Input can be:
- A git diff or branch name
- Two file paths (old and new)
- A description ("we used to do X, now we do Y")
- A PR description
- Nothing — default to current branch vs main

If input is ambiguous, check recent git log before asking a clarifying question.
