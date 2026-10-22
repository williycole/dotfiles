# nobara/ — desktop and machine setup

| File | What it does | Recipe |
|---|---|---|
| `bootstrap.sh` | fresh account: mise, clone dotfiles, link, tools | `just bootstrap` |
| `plasma-desktop.sh` | Plasma look, desktops, keymap, launchers, tiling | `just desktop` |
| `provision-user.sh` | user dev tools: Odin, nvim, Godot, cliamp, references | `just provision` |
| `rotation.sh` + `dist/` | Pocket 4 screen rotation (hwdb, touchscreen, KWin script) | `pkexec nobara/rotation.sh` |
