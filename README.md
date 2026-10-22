# dotfiles

Config for my Mac and my Linux (Nobara) machines, kept as plain files and
linked into `~` with symlinks. The repo file and the live file are the same
inode, so there is no apply step and no drift.

## Layout

```
home/            shared config at its real path   (home/.config/nvim → ~/.config/nvim)
os/darwin/       macOS only                       (zsh, aerospace, karabiner, sketchybar)
os/linux/        Linux only                       (bash, KDE bits, .desktop files)
host/<name>/     one machine only                 (hardware-specific files)
copy/            the few files an app rewrites, copied instead of linked
bin/             scripts the recipes call (dots, doctor, install-packages, plasma-sync)
nobara/          Linux desktop + machine setup scripts
packages.yaml    every CLI tool and app, by source (brew, dnf, mise, uv, npm, flatpak)
modes.conf       file modes git cannot carry (0600 for secrets-adjacent files)
justfile         the front door; `just` lists everything
```

Layering: `home/` first, then `os/<os>/`, then `host/<hostname>/`. Later wins,
so a file at the same path in `os/linux/` replaces the shared one on Linux.

## Use

```bash
git clone git@github.com:williycole/dotfiles.git ~/Repos/dotfiles
cd ~/Repos/dotfiles
just link       # symlink everything into ~ (never overwrites a real file)
just install    # install packages.yaml
just doctor     # green/red health check
```

Day to day: `just update` pulls, relinks, installs, and checks. `just status`
shows what differs between `~` and the repo. `just` lists the rest.

## Maintain

- **Change a config:** edit it where it lives, in `~` or in the repo. Same file.
  Commit.
- **Add a file:** put it under `home/` at its real path and run `just link`.
  Linux-only or Mac-only files go under `os/<os>/`.
- **Adopt an existing file from `~`:** `just adopt path=.config/foo/bar`.
- **Add a tool:** one line in `packages.yaml`, then `just install`.
- **A file an app keeps rewriting:** put it under `copy/` instead; `just copy`.
- **A file that must be 0600:** add it to `modes.conf`; `just perms`.
- **Agent skills:** real files in `home/.agents/skills/`; `just link` symlinks
  them and `just install` points each agent at them.
- **Check wiring:** `just dots-doctor` reports dangling links.

Rules the scripts follow: nothing deletes in `~`; a failure is reported by
name and the run continues; `home/` is the Mac too, so anything Linux-only
goes in `os/linux/`.

## Extension

Optional. Set `DOTS_EXTRA` (default `~/.local/share/dots/extra`) to a directory
with its own `overlay/` (layered last, same `home/`, `os/`, `host/` shape), a
`packages.yaml` (read after this one), and a `justfile` whose `update`,
`doctor`, `desktop` and `pull` recipes run after this repo's. `just extra
<recipe>` runs any of its recipes. Absent by default; nothing here needs it.
