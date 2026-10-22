#!/usr/bin/env bash
# claude-workflow.sh
# Bootstraps the dual Claude profile setup (ccw / ccp).
# Safe to re-run — all steps are idempotent.

set -euo pipefail

CLAUDE_SRC="$HOME/.claude"
WORK_DIR="$HOME/.claude-work"
PERSONAL_DIR="$HOME/.claude-personal"
ZSHRC="$HOME/.zshrc"

# ── 1. Create profile dirs ────────────────────────────────────────────────────
echo "→ Creating profile directories..."
mkdir -p "$WORK_DIR" "$PERSONAL_DIR"

# ── 2. Wire settings into both profiles ──────────────────────────────────────
# settings.json is SYMLINKED so both profiles always track ~/.claude/settings.json
# (statusline, hooks, plugins) — tooling shared, no drift. That file is owned and
# rewritten by Claude Code itself; this repo stopped managing it (see the
# dotfiles-plain-file-linking change, task 3.10). This script only needs it to
# exist, so nothing here changed.
# settings.local.json stays a per-profile COPY: local/account overrides live here
# and must not be shared. Seeded once, never clobbered on re-run.
echo "→ Wiring settings into profiles..."
for dir in "$WORK_DIR" "$PERSONAL_DIR"; do
    if [ -f "$CLAUDE_SRC/settings.json" ]; then
        ln -sf "$CLAUDE_SRC/settings.json" "$dir/settings.json"
        echo "  Linked settings.json → $(basename "$dir")"
    fi
    if [ -f "$CLAUDE_SRC/settings.local.json" ] && [ ! -e "$dir/settings.local.json" ]; then
        cp "$CLAUDE_SRC/settings.local.json" "$dir/settings.local.json"
        echo "  Seeded settings.local.json → $(basename "$dir")"
    fi
done

# ── 3. Share skills + commands across both profiles ──────────────────────────
# Claude reads $CLAUDE_CONFIG_DIR/{skills,commands}, so a per-profile copy means
# a skill installed under one profile is invisible to the other — and any
# installer that hardcodes ~/.claude writes somewhere nothing scans. Symlink
# both profiles at the shared ~/.claude copy: one source, every profile.
# Accounts stay separate — .claude.json (auth/history) is untouched.
echo "→ Sharing skills + commands across profiles..."
for dir in "$WORK_DIR" "$PERSONAL_DIR"; do
    for sub in skills commands; do
        # a pre-existing real dir would be silently shadowed — move it aside, don't destroy it
        if [ -d "$dir/$sub" ] && [ ! -L "$dir/$sub" ]; then
            mv "$dir/$sub" "$dir/$sub.pre-consolidate"
            echo "  Moved existing $sub aside → $sub.pre-consolidate ($(basename "$dir"))"
        fi
        ln -sfn "$CLAUDE_SRC/$sub" "$dir/$sub"
        echo "  Linked $sub → $(basename "$dir")"
    done
done

# ── 4. Done ──────────────────────────────────────────────────────────────────

echo ""
echo "Done."
echo "  ccw → ~/.claude-work   (work account)"
echo "  cp  → ~/.claude-personal   (personal account)"
echo ""
echo "Ensure your shared shell config is sourced to load aliases."
