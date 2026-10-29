# Mac handoff: switch to the shared Claude settings

For the Claude session that opens this repo on the Mac. Do the steps, verify,
then delete this file, commit, push. Written on littleplow, 2026-10-29.

## What changed and why

`home/.claude/settings.json` is now the ONE Claude Code settings file for every
machine. Every hook path says `$HOME`, so it links unchanged on macOS and Linux.
It is the Mac's curated file plus the Linux plugins; nothing work-specific.

On 2026-10-28 the Mac's live `~/.claude/settings.json` (absolute `/Users` paths,
the work org's auto-mode block, a hook copying live -> repo) was committed into
`home/`. That broke `just update` on Linux and put work hostnames into this
public repo. The hook, the `os/darwin` copy, and the work block are gone from
the repo. The Mac's live file still has them; this handoff retires it.

The repo path on the Mac is wherever this checkout lives; the mirror hook named
`~/personal/dotfiles`.

## Steps

1. Pull and put the working copy on the remote tip:

   ```bash
   jj git fetch && jj rebase -r @ -d main@origin
   ```

2. Move the live file aside and link the shared one. `just update` runs
   `dots sync-apply`, which refuses to overwrite a real file, hence the `mv`:

   ```bash
   mv ~/.claude/settings.json ~/.claude/settings.json.pre-share && just update
   ls -la ~/.claude/settings.json      # want: symlink into this repo
   grep -c '/Users/' ~/.claude/settings.json   # want: 0
   ```

3. Restart Claude Code so it reads the new file.

4. Personal plugins the shared file does not carry yet, enable them from inside
   Claude Code so the change lands in the shared file (it is a symlink now):
   add the `mattpocock/skills` marketplace, then enable
   `mattpocock-skills@mattpocock` and `plannotator@plannotator`.

5. Work-only config goes in the WORK repo, never here. From
   `~/.claude/settings.json.pre-share` copy the `autoMode` object (its
   `environment` and `soft_deny`) and the `atlassian-mcp@anthropic-plugin-directory`
   plugin entry into `<work repo>/.claude/settings.local.json`. That file is
   per-project and gitignored there. Claude Code merges it over user settings,
   so the Mac loses nothing.

6. Verify: open a session in the work repo and in a personal repo. Peon sounds,
   `/say:test`, and the status line work in both; the auto-mode environment
   shows only in the work repo. `just status` reports 0 missing, 0 severed.

## Cleanup

```bash
rm ~/.claude/settings.json.pre-share
jj file untrack MAC-HANDOFF.md 2>/dev/null; rm MAC-HANDOFF.md
jj commit -m "mac: on the shared Claude settings; handoff done" && jj bookmark set main -r @- && jj git push --bookmark main
```

Plain commit message, no attribution lines. If the live file ever turns back
into a real file (a tool rewrote it instead of writing through the symlink),
`just status` shows it as severed; diff it against the repo, keep what is
wanted, and relink with `just link`.

Still open, for the owner, not this session: the two public commits that carry
the work hostnames (d55f1a7, 38373fa) are only removable by rewriting history.
