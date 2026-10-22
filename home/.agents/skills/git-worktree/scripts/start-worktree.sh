#!/bin/bash
# Create a new git worktree with a new branch

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <feature-name> [base-branch]"
    echo "  feature-name: Short name for the feature (e.g., 'my-feature')"
    echo "  base-branch: Branch to base on (default: main)"
    exit 1
fi

FEATURE="$1"
BASE="${2:-main}"
WORKTREE_PATH="../${FEATURE}"
BRANCH="feature/${FEATURE}"

# Check if already on main/master
CURRENT=$(git branch --show-current 2>/dev/null || echo "")
if [ "$CURRENT" = "main" ] || [ "$CURRENT" = "master" ]; then
    echo "Currently on $CURRENT - creating worktree..."
elif [ -z "$CURRENT" ]; then
    echo "Not in a git repository?"
    exit 1
else
    echo "Already on branch '$CURRENT' - creating worktree..."
fi

# Check if worktree already exists
if [ -d "$WORKTREE_PATH" ]; then
    echo "Worktree already exists at $WORKTREE_PATH"
    echo "To remove: git worktree remove $WORKTREE_PATH"
    exit 1
fi

# Create worktree with new branch
git worktree add "$WORKTREE_PATH" -b "$BRANCH"

echo ""
echo "Created worktree at: $(realpath $WORKTREE_PATH)"
echo "Branch: $BRANCH"
echo ""
echo "To work in it: cd $WORKTREE_PATH"
echo "To merge when done: git merge --no-ff $BRANCH"
