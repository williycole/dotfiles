#!/usr/bin/env bash
# nobara/bootstrap.sh — one-shot bootstrap for the daily (non-admin) account on Nobara.
#
# Turns a bare account into the full dev environment:
#   mise installed → dotfiles linked (desktop config, rotation, shell) →
#   `just dev-tools` then installs runtimes + CLI tools + provisions the account.
#
# NO sudo. The admin/Phase-2 system setup must already be done (Erlang build
# deps — see README.md). No desktop packages: the desktop is Plasma, which Nobara
# already ships. Safe to re-run (idempotent).
#
# Run as the daily account:
#   bash ~/Repos/dotfiles/nobara/bootstrap.sh
set -uo pipefail

REPO_SSH="git@github.com:williycole/dotfiles.git"
REPO_DIR="$HOME/Repos/dotfiles"
GIT_EMAIL="${GIT_EMAIL:-64283810+williycole@users.noreply.github.com}"
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

say() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }

# ── 1. mise (runtime manager) ─────────────────────────────────────────────────
say "1/4  mise"
if command -v mise >/dev/null; then echo "  already installed."; else
  curl -fsSL https://mise.run | sh
fi

# ── 2. (chezmoi used to be installed here) ────────────────────────────────────
# Nothing to install. Config reaches $HOME as symlinks made by bin/dots, which is
# plain bash and ships in the repo — so step 3's clone is the only prerequisite.
hash -r

# ── 3. dotfiles clone (needs dev's own GitHub SSH key) ────────────────────────
say "3/4  dotfiles → $REPO_DIR"
if [ -f "$REPO_DIR/install.sh" ]; then
  echo "  already cloned."
else
  # Ensure an SSH key exists and is registered on GitHub before cloning.
  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
  [ -f "$HOME/.ssh/id_ed25519" ] || ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$HOME/.ssh/id_ed25519" -N ""
  ssh-keyscan -t ed25519 github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null || true
  sort -u "$HOME/.ssh/known_hosts" -o "$HOME/.ssh/known_hosts" 2>/dev/null || true

  auth_out="$(ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 || true)"
  if ! grep -q "successfully authenticated" <<<"$auth_out"; then
    echo
    echo "  ✋ This account's SSH key is NOT on your GitHub yet. Add it, then re-run this script:"
    echo "     → https://github.com/settings/keys   (New SSH key)"
    echo "     ---------------------------------------------------------------"
    cat "$HOME/.ssh/id_ed25519.pub"
    echo "     ---------------------------------------------------------------"
    exit 1
  fi
  echo "  GitHub authenticated — cloning."
  rm -rf "$REPO_DIR"; mkdir -p "$(dirname "$REPO_DIR")"
  git clone "$REPO_SSH" "$REPO_DIR"
fi

# ── 4. link the dotfiles, then provision ──────────────────────────────────────
# install.sh links home/ + os/linux/ into $HOME, applies modes.conf and fetches
# externals. It never overwrites a file it does not own, so if this account already
# has real config files it reports them and continues rather than clobbering them —
# `just migrate` is the deliberate path for that case (see README).
say "4/4  link dotfiles"
bash "$REPO_DIR/install.sh"

# Runtimes + CLI tools + account provisioning. Replaces chezmoi's run_once script.
# Stamped by its own script hash, so re-running this bootstrap is a no-op here.
say "     dev-tools (runtimes + tools + provision)"
bash "$REPO_DIR/bin/dev-tools"

say "bootstrap done."
echo "  • Fast runtimes (node/go/python/rust) are installed."
echo "  • Erlang/Elixir compile in the BACKGROUND — follow with:"
echo "      tail -f ~/.cache/dev-bootstrap/mise-beam.log"
echo "  • Log out, then log into the 'Plasma (Wayland)' session."
echo "  • Then run: just desktop   (10 desktops, keymap, launchers, tiling)"
