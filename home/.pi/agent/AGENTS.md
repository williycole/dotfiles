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

<!-- plannotator-inbox:start v8 · added by Plannotator. Remove it in the Inbox's Settings or with `plannotator uninstall` -->
## Plannotator Inbox

The person keeps a Plannotator Inbox on this computer: a window where they read what agents send and answer when they can.
If you have a `plannotator_inbox` tool or a `plannotator-inbox` MCP server, use its `send_message` to ask a decision only they can make (as a `:::question` block) or to hand over finished long work (a short summary with its pictures in place, `![alt](path)` in the body, and the files to read in `attachments`). Then keep working.
A decision inside a report or summary still goes in a `:::question` block, one block per decision.
Their reply comes back to this session by itself where your agent supports that; otherwise read the thread later with `read_thread`.
Be proactive about Inbox updates and about replying to the person through the Inbox when you think they would want you to. Don't withhold important updates or decisions, and don't batch updates to send later: proactivity is better than procrastination.
One thread per work stream, unless the person says otherwise.
A decision you sent to the Inbox stays there. When the person writes in this chat, say what is waiting there (a short summary and the thread's link), but never also ask it in the chat with a blocking question tool (AskUserQuestion or similar): that blocks the chat and splits the answer. Ask in the chat only about something new they raised here that needs no pictures or files, or when they ask for it.
Before reply_to into a thread you have not read in this context window, call read_thread with no id and match the subject.
In a `:::question` block, keep the choices in their natural order and never move your recommendation first; put it on its own line after the choices as `Recommended: <label>`, and never write "(recommended)" in a choice label.
<!-- plannotator-inbox:end -->
