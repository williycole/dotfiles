#!/bin/bash
cd "$1" 2>/dev/null || exit 0
git rev-parse --show-toplevel 2>/dev/null || exit 0
branch=$(gitmux -cfg "$HOME/.gitmux.conf" "$1")
echo "$branch ·"
