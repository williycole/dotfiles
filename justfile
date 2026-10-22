# dotfiles — one interface over every setup/verify/maintenance task.
#   just              list all recipes
#   just doctor       verify the whole box (green/red) — start here when unsure
# Recipes are thin wrappers over the scripts in nobara/ (desktop + machine setup) and bin/. The scripts stay
# the source of truth; this file is just the memorable front door.

repo := justfile_directory()
# Optional extension: a directory with its own `overlay/` (layered last by
# bin/dots), `packages.yaml` (read after this repo's) and `justfile` (its
# `update`, `doctor`, `desktop` and `pull` recipes run after this repo's).
# Absent by default; nothing here requires it.
extra := env_var_or_default("DOTS_EXTRA", home_directory() / ".local" / "share" / "dots" / "extra")
# If the extension ships bin/with-polkit, commands that raise a password
# dialog run through it (install-packages honours POLKIT_WRAP).
export POLKIT_WRAP := if path_exists(extra / "bin" / "with-polkit") == "true" { extra / "bin" / "with-polkit" } else { "" }

# show all recipes (default)
default:
    @just --list

# ── verify ──────────────────────────────────────────────────────────────────

# full health check: runtimes, tools, GUI apps, desktop wiring (+ the extension's checks when present)
doctor:
    #!/usr/bin/env bash
    # This repo's bin/doctor, then the extension's `doctor` recipe when it is
    # present. Fails if either fails.
    rc=0
    bash {{repo}}/bin/doctor || rc=1
    if [ -f {{extra}}/justfile ]; then just --justfile {{extra}}/justfile doctor || rc=1; fi
    exit $rc

# `just diff` is gone. Under symlinks the repo file and the live file are one
# inode, so there is nothing to diff — that was the whole point. Use `git diff` for
# uncommitted edits and `just status` for the wiring.

# what differs between ~ and the repo: missing, severed, foreign links + mode drift
status:
    @bash {{repo}}/bin/dots status

# ── install / update ────────────────────────────────────────────────────────

# CLI tools + GUI apps from packages.yaml (mise/uv/npm/flatpak --user, no admin)
install:
    @bash {{repo}}/bin/install-packages

# full new-machine bootstrap: mise + clone + link + runtimes + tools + provision
bootstrap:
    @bash {{repo}}/nobara/bootstrap.sh

# THE catch-up command: pull, re-link, tools; on Nobara also desktop, the extension, doctor
update:
    #!/usr/bin/env bash
    set -euo pipefail
    # ~/.local/bin holds mise (and through it every tool). An interactive shell
    # gets it from .bashrc; `ssh bigplow 'just update'` does not, and died at
    # "mise: command not found" on 2026-10-08. Don't depend on how we got here.
    # mise SHIMS too: over ssh, node/npm/rg/lazygit and the rest looked missing,
    # install-packages tried to dnf them, lazydocker is not in dnf, and the one
    # failed name sank the whole admin batch (love with it). ~/.bun/bin for bun.
    # mise SHIMS FIRST, ~/.local/bin LAST. Both orders have bitten:
    #   ~/.local/bin first -> its `pi` wrapper (pnpm dlx) shadowed the real pi and
    #                         `pi install` hung for minutes.
    #   everything last    -> /usr/bin/npm (Fedora's) won over mise's, and every
    #                         `npm install -g` died EACCES on /usr/local.
    # Shims first pins node/npm/pi to the mise versions in config.toml.
    export PATH="$HOME/.local/share/mise/shims:$PATH:$HOME/.local/bin:$HOME/.bun/bin"
    cd {{repo}}
    # jj-aware. Both boxes are colocated jj+git, where git sees a DETACHED HEAD,
    # so `git pull --ff-only` fails outright — and a mutating git command in a jj
    # repo forks history behind jj's back. Fetch with jj, then move onto the new
    # head. Falls back to git only if this checkout is genuinely git-only.
    if [ -d .jj ]; then
        # jj auto-snapshots the working copy into a commit, so there is no
        # "uncommitted changes block the pull" failure mode to guard against here.
        #
        # REBASE, not `jj new main@origin`. `jj new` starts a FRESH empty commit on
        # the new head and leaves the old working copy behind as a sibling — so
        # in-progress edits vanish from the tree with only "modified 3 files" as
        # notice, and the steps below then run against the reverted tree.
        # Rebase carries the working copy forward instead. Already up to date is a
        # no-op ("Skipped rebase of commits that were already in place").
        # Recovery either way: `jj undo`, or `jj edit <change>` on the stranded one.
        jj git fetch && jj rebase -r @ -d main@origin
    else
        # git pull --ff-only refuses outright when local edits collide with an
        # incoming commit on the same file (hit on 2026-09-06: peon-ping config
        # and packages.yaml drift blocked a routine pull). Auto-stash around it.
        stashed=0
        if ! git diff --quiet || ! git diff --cached --quiet; then
            git stash push -u -m "just-update: auto-stash before pull"
            stashed=1
        fi
        git pull --ff-only
        if [ "$stashed" = 1 ]; then
            if ! git stash pop; then
                echo "==> auto-stash popped with conflicts — resolve by hand, then: git stash drop" >&2
                exit 1
            fi
        fi
    fi
    # The extension pulls itself, if it has a `pull` recipe.
    if [ -f {{extra}}/justfile ]; then
        just --justfile {{extra}}/justfile pull 2>/dev/null || echo "==> extension pull failed — continuing with what is checked out" >&2
    fi
    bash bin/dots sync-apply
    # ponytail: the mac stops here. Everything below is Nobara — plasma, the admin
    # steps, mise runtimes (the mac keeps brew/pyenv/fnm, see README), doctor.
    if [ "$(uname)" != Linux ]; then
        bash bin/install-packages
        exit 0
    fi
    # Desktop look (colors, panels, pins, shortcuts, wallpaper, KWin), scale kept
    # per device. Applies only when the repo snapshot changed since the last apply
    # here, so an unsaved local tweak is never reverted. Share one: just look-save.
    python3 bin/plasma-sync apply || echo "==> plasma-sync apply failed — look not synced" >&2
    # Chromium bookmarks, same model: applied only when the repo copy changed.
    python3 bin/plasma-sync bookmarks-apply || echo "==> bookmarks not synced" >&2
    # PASSWORD PROMPTS FRONT-LOADED. They (packages, then the extension's update)
    # come back to back in the first minutes; the long no-password
    # work (full mise install incl. any Erlang compile, the Aseprite build) runs
    # after. Before 2026-10-08 the prompts were split around a 15-minute build,
    # and an admin who stepped away came back to a timed-out prompt.
    # Go first, from proxy.golang.org: mise's own Go download uses dl.google.com,
    # which is refused on purpose (it also serves Chrome). See bin/go-toolchain.
    bash bin/go-toolchain || echo "==> go toolchain step failed" >&2
    # Every mise tool EXCEPT erlang/elixir (slow) and go (bin/go-toolchain owns it; naming it makes mise reach for dl.google.com) up front: install-packages needs node,
    # uv, yazi. All prebuilt downloads, quick. erlang (and
    # elixir on top of it) can compile from source, so they wait until after
    # the last password.
    mise install $(python3 -c 'import tomllib,os;t=tomllib.load(open(os.path.expanduser("~/.config/mise/config.toml"),"rb"))["tools"];print(" ".join(k for k in t if k not in ("erlang","elixir","go")))')
    bash bin/install-packages
    # The extension's `update`, then the verdict. Best effort: a declined or
    # absent password must not block the rest; it says how to rerun, and doctor
    # is what reports the gap. Absolute paths: pkexec does NOT inherit this
    # recipe's cwd (observed 2026-09-14 and 2026-10-03).
    if [ -f {{extra}}/justfile ]; then
        just --justfile {{extra}}/justfile update \
            || echo "==> extension update failed. Rerun: just extra update" >&2
    fi
    # ---- no more passwords below this line: the admin can walk away ----
    echo "==> admin steps done — the rest needs no password (may take a while)"
    # NAMED, not bare. Bare `mise install` treats erlang/elixir "latest" as
    # satisfied by whatever is already installed — bigplow stayed on OTP 28 /
    # Elixir 1.19 while littleplow (installed by name) moved to 29 / 1.20,
    # 2026-10-08. Go is the opposite case and is never named; see go-toolchain.
    mise install erlang elixir
    mise install
    # Aseprite: built from source to the latest STABLE release (paid app, no
    # downloadable binary on this box). After install-packages so its
    # admin batch has already installed ninja + libc++. Skips in under a second
    # when current; a patch release only recompiles what changed.
    [ "$(uname)" = Linux ] && { bash bin/aseprite-build || echo "==> aseprite build failed — rerun: bin/aseprite-build" >&2; }
    # Last, and its exit status is the recipe's: green means caught up, red names
    # what is not.
    #
    # Captured rather than final, so the address-lock instructions below still
    # print on a red run. They are needed MOST on a red run: while the lock is
    _doctor_rc=0
    bash bin/doctor || _doctor_rc=1
    if [ -f {{extra}}/justfile ]; then just --justfile {{extra}}/justfile doctor || _doctor_rc=1; fi
    exit $_doctor_rc

# Pushes the bookmarks jj already tracks; it does NOT move `main` for you. Commit
# the way you normally do (`jj describe` + `jj bookmark set main -r @`), then run
# this. If it says nothing changed, the bookmark is still behind your commit.

# push committed work to origin (jj-aware — a git push here would fork history)
push:
    @cd {{repo}} && if [ -d .jj ]; then jj git push; else git push; fi

# ── dotfile linking ─────────────────────────────────────────────────────────
#
# See openspec/changes/dotfiles-plain-file-linking/. Config files live at literal
# paths in home/, os/<uname>/ and host/<hostname>/, and reach ~ as symlinks — so
# the repo file and the live file are one inode and editing either edits the same
# bytes. There is no apply step and nothing to reconcile.
#
# Only `dots-doctor` keeps a prefix, because `doctor` is the whole-box check.
#
# Every recipe honours $HOME, so `HOME=/tmp/fakehome just link` is a real dry run
# against a throwaway tree.

# symlink home/ + os/<uname>/ + host/<hostname>/ into ~ (later layer wins)
link:
    @bash {{repo}}/bin/dots link

# write the copy-set — files macOS or an app rewrites, where a symlink cannot survive
copy:
    @bash {{repo}}/bin/dots copy

# apply modes.conf (git carries only the exec bit)
perms:
    @bash {{repo}}/bin/dots perms

# refresh vendored files from external.conf
external:
    @bash {{repo}}/bin/dots external

# pull a live copy-set file back into the repo: just adopt path=.config/foo/bar
adopt path='':
    @test -n "{{path}}" || { echo "usage: just adopt path=<path relative to ~>"; exit 2; }
    @bash {{repo}}/bin/dots adopt {{path}}

# dangling links pointing into the repo at files that no longer exist
dots-doctor:
    @bash {{repo}}/bin/dots doctor

# ONE-TIME CUTOVER. The only recipe that removes a file from $HOME, and only when
# that file is byte-identical to the repo copy replacing it — identical means the
# symlink points at the same bytes, so there is nothing to lose. Anything that
# differs is named and left alone. Refuses to run without a backup tarball in
# ~/.cache/dotfiles-migration/.
#
# preview the cutover: what would be replaced, what needs a decision
migrate:
    @bash {{repo}}/bin/dots migrate

# do the cutover (link + replace identical files)
migrate-apply:
    @bash {{repo}}/bin/dots migrate-apply

# DRY RUN — show what link+copy+perms would do, change nothing
sync:
    @bash {{repo}}/bin/dots sync

# actually do it (link + copy + perms)
sync-apply:
    @bash {{repo}}/bin/dots sync-apply

# fresh-machine bootstrap; add --packages to include package installs
fresh *args:
    @bash {{repo}}/install.sh {{args}}

# Replaces the chezmoi run_once_ script, which did this invisibly on every apply.
# Stamped by script hash, so a second run is a no-op and editing the script
# re-arms it. `just dev-tools --force` runs it regardless.
#
# Linux first-run provisioning: runtimes + CLI tools + account (stamped, no-op on mac)
dev-tools *args:
    @bash {{repo}}/bin/dev-tools {{args}}

# ── desktop (Plasma) ────────────────────────────────────────────────────────

# NOTE: ends by telling you to log out. Global shortcuts are read only when KWin
# starts, so the bindings it writes are inert until then.
#
# provision/repair the Plasma desktop (desktops, keymap, launchers, tiling, displays)
desktop:
    @bash {{repo}}/nobara/plasma-desktop.sh
    @# the extension's launchers + shortcuts, registered after the look (when present)
    @test -f {{extra}}/justfile && just --justfile {{extra}}/justfile desktop || true

# ── provisioning (user-level, no admin) ─────────────────────────────────────

# Odin/ols/odinfmt/nvim/etc. for the daily account
provision:
    @bash {{repo}}/nobara/provision-user.sh

# same, plus configure pi → local Ollama (Pocket 4)
provision-pocket4:
    @bash {{repo}}/nobara/provision-user.sh --pocket4

# ── extension ───────────────────────────────────────────────────────────────

# run any recipe of the extension from here: just extra <recipe> [args]
extra *args:
    @test -f {{extra}}/justfile || { echo "no extension at {{extra}}" >&2; exit 1; }
    @just --justfile {{extra}}/justfile {{args}}

# cliamp (terminal Spotify) on this machine: your own Spotify app id, then sign in.
# The id is public (PKCE, no secret) but stays out of the repo with the rest of
# the cliamp config. Make one at developer.spotify.com/dashboard: app "cliamp",
# redirect http://127.0.0.1:19872/login, tick Web API, copy the Client ID.
# Spotify's login needs Google's captcha. If the extension has a `google-gate`
# recipe (a network that normally keeps that host closed), it opens it first.
cliamp-setup client_id='':
    #!/usr/bin/env bash
    set -euo pipefail
    id="{{client_id}}"
    if [ -z "$id" ]; then
      echo "usage: just cliamp-setup <client_id>"
      echo "  get one: developer.spotify.com/dashboard -> Create app 'cliamp'"
      echo "           redirect http://127.0.0.1:19872/login, tick Web API, copy the Client ID"
      exit 2
    fi
    case "$id" in *[!0-9a-fA-F]*) echo "that does not look like a Spotify client id (hex only)"; exit 2 ;; esac
    cfg="$HOME/.config/cliamp/config.toml"
    mkdir -p "$(dirname "$cfg")"
    [ -f "$cfg" ] || printf '[spotify]\nbitrate = 320\n' > "$cfg"
    grep -q '^\[spotify\]' "$cfg" || printf '\n[spotify]\nbitrate = 320\n' >> "$cfg"
    if grep -q '^client_id' "$cfg"; then
      sed -i "s|^client_id = .*|client_id = \"$id\"|" "$cfg"
    else
      sed -i "/^\[spotify\]/a client_id = \"$id\"" "$cfg"
    fi
    chmod 600 "$cfg"
    echo "==> client id set in $cfg"
    cliamp spotify reset
    if [ -f {{extra}}/justfile ] && just --justfile {{extra}}/justfile --summary 2>/dev/null | grep -qw google-gate; then
      echo "==> opening www.google.com for the Spotify sign-in (15 min)"
      just --justfile {{extra}}/justfile google-gate 15 || echo "   did not open - the sign-in page may just say 'Oops'"
    fi
    if [ -t 0 ] && [ -t 1 ]; then
      echo "==> starting cliamp - select Spotify, approve the sign-in link it shows"
      exec cliamp
    fi
    echo "==> now run 'cliamp' in a terminal, select Spotify, approve the sign-in link (gate open 15 min)"

# ── host helpers ────────────────────────────────────────────────────────────


# ── offline docs ────────────────────────────────────────────────────────────

# Worth having on disk: offline docs survive any network, and the N64 set is
# small. Bounded per site and re-runnable. Bounded per site and re-runnable — wget skips what it
# already has. libdragon's own API docs and examples/ are NOT mirrored: they ship
# inside the source clone `libdragon init` makes, so they are offline already.
# Godot's official offline zip is skipped for the same kind of reason: it lives
# behind nightly.link, which redirects into Azure blob storage on a hostname that
# changes per run — permitting that is a wildcard, so the docs site is mirrored.

# mirror N64 + Godot docs for offline reading (default: ~/Documents/gamedev-docs)
gamedev-docs out='':
    @bash {{repo}}/bin/gamedev-docs {{out}}

# ── gamedev ─────────────────────────────────────────────────────────────────

# ares is a flatpak and flatpak's export dir is not on PATH, so there is no bare
# `ares` command — this is the wrapper. Homebrew Development Mode is a GUI
# setting in ares and has to be turned on there once; the N64brew wiki says to.

# run a ROM in ares (N64 emulator): just ares ~/Repos/n64/hello/hello.z64
ares rom='':
    @flatpak run dev.ares.ares {{rom}}

# `just update` applies the saved look on every machine; scaling stays per device.
# save THIS machine's desktop look (colors, panels, pins, shortcuts, wallpaper) to the repo, then commit
look-save:
    @python3 {{repo}}/bin/plasma-sync save

# save THIS machine's Chromium bookmarks, then commit. 
# they go to the extension's overlay when one is here (plasma-sync picks that path itself).
bookmarks-save:
    @python3 {{repo}}/bin/plasma-sync bookmarks-save
