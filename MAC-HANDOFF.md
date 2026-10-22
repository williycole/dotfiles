# Mac handoff

The dotfiles were split out into their own repo. Same files at the same paths
as before, so every existing symlink keeps working.

## Switch the existing checkout

```bash
cd ~/Repos/dotfiles && jj log -r 'main ~ ::main@origin' --no-graph    # want: empty (nothing unpushed)
mv ~/Repos/dotfiles ~/Repos/archived_dotfiles
git clone git@github.com:williycole/dotfiles.git ~/Repos/dotfiles
cd ~/Repos/dotfiles && jj git init --colocate && jj bookmark track main@origin
just link && just update && just doctor | tail -3
```

If the first line prints commits, they are not lost: they stay in
`~/Repos/archived_dotfiles` after the move.

## Check

- `just status`: 0 missing, 0 severed, 0 foreign
- `just doctor`: one summary, green
- `/say:test` in Claude Code and the Karabiner stop key work
- the `i` and `I` aliases moved out of `.zshrc`; add them to `~/.secrets`

## Rollback

```bash
mv ~/Repos/dotfiles ~/Repos/dotfiles.new && mv ~/Repos/archived_dotfiles ~/Repos/dotfiles && cd ~/Repos/dotfiles && just link
```

After a week: `rm -rf ~/Repos/archived_dotfiles` and delete this file.
