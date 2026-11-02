# Linux handoff: catch up with what the Mac changed

Written on the Mac, 2026-11-02, after the Mac handoff was carried out. The Mac is
on the shared `home/.claude/settings.json`; nothing more to do there. The Linux
machines need the three things below. Delete this file when they are done.

## What changed and why

- **Peon hooks use `$HOME`.** The shared `settings.json` had 13 hook commands
  hard-coded to `/home/dev/.claude/hooks/peon-ping/...`. They now read
  `$HOME/.claude/hooks/peon-ping/...`, which resolves on both machines. Same
  files, same place, only the spelling of home.
- **One hook was quoted so `$HOME` never expanded.** The `SessionStart` hook
  `bash '$HOME/.claude/hooks/herdr-agent-state.sh' session` failed with "No such
  file or directory" on every Claude Code start. The single quotes are gone. If
  Herdr pane state for Claude sessions looked dead on Linux, this was why.
- **Two personal plugins live in the shared file now:** `mattpocock-skills@mattpocock`
  (plus the `mattpocock` marketplace entry) and `plannotator@plannotator`. Claude
  Code installs them on first start; nothing to do by hand.
- **New skill `artifact`** in `home/.agents/skills/artifact/`. From pi it writes
  an HTML page to `~/Repos/artifacts/<slug>.html` and hands the publish to an
  interactive Claude Code pane, because headless Claude Code has no Artifact tool.
  Needs `jq`, `herdr`, and `claude` on PATH.

## Steps

1. Pull and relink:

   ```bash
   cd ~/Repos/dotfiles && just update
   ```

2. Point the agents at the new skill (the symlink step of `just install`, done by
   hand so it does not reinstall every package):

   ```bash
   for d in ~/.claude/skills ~/.pi/agent/skills; do
     [ -e "$d/artifact" ] || ln -s ~/.agents/skills/artifact "$d/artifact"
   done
   mkdir -p ~/Repos/artifacts
   ```

3. Restart Claude Code. Verify: no `herdr-agent-state.sh: No such file` line at
   startup, peon sounds fire, `/artifact` shows in the skill list in both Claude
   Code and pi.

## Cleanup

```bash
rm LINUX-HANDOFF.md
jj commit -m "linux: caught up with the Mac changes; handoff done" && jj bookmark set main -r @- && just push
```
