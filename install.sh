#!/usr/bin/env bash
#
# Fresh-machine bootstrap. Idempotent — safe to re-run.
#
#     git clone <repo> ~/Repos/dotfiles && ~/Repos/dotfiles/install.sh
#
# Named `install.sh` on purpose: automated environments (Codespaces, devcontainer
# CLI, DevPod) clone a dotfiles repo and run the first of install.sh / bootstrap.sh
# / script/setup they find. If none exists they fall back to symlinking every
# dot-prefixed file into $HOME, which is why this repo stores files at literal
# paths rather than under a prefix scheme.
#
# Does NOT install packages by default — that needs a package manager present.
# Pass --packages to include it.

set -uo pipefail   # not -e; each step reports and the script continues

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WANT_PACKAGES=0
[[ "${1:-}" == "--packages" ]] && WANT_PACKAGES=1

step() { printf '\n\033[1m== %s\033[0m\n' "$*"; }
RC=0
run() { "$@" || RC=1; }

step "link config into \$HOME"
run "$REPO/bin/dots" link

step "copy the copy-set"
run "$REPO/bin/dots" copy

step "enforce declared modes"
run "$REPO/bin/dots" perms

step "fetch vendored externals"
run "$REPO/bin/dots" external

if (( WANT_PACKAGES )); then
    step "packages"
    run bash "$REPO/bin/install-packages"
else
    printf '\n  packages skipped — re-run with --packages, or: just install\n'
fi

step "status"
"$REPO/bin/dots" status || true

if (( RC != 0 )); then
    printf '\n\033[31mOne or more steps reported a failure.\033[0m Each is named above.\n'
    printf 'Nothing in $HOME was deleted. Re-running is safe.\n'
    exit 1
fi
printf '\n\033[32mdone\033[0m\n'
