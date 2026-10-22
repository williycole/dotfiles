---
name: git-worktree
description: Git worktree management. Use when creating branches, worktrees, or switching contexts. Essential for pi package development to isolate changes.
---

# Git Worktree Skill

## When to Use

- Before making ANY edits, ensure not on main/master
- When working on features that need isolated testing
- For pi packages where you want to test changes independently

## Quick Reference

### Check Current Branch
```bash
git branch --show-current
```

### Create a New Worktree + Branch
```bash
git worktree add ../worktree-name -b feature/your-feature
```

### Create Branch Only (no worktree)
```bash
git checkout -b feature/your-feature
```

### List Worktrees
```bash
git worktree list
```

### Remove Worktree
```bash
git worktree remove ../worktree-name
```

### Switch to Main and Update
```bash
git checkout main && git pull
```

## Common Workflows

### Feature Development
```bash
# 1. From main, create worktree
git worktree add ../my-feature -b feature/my-feature

# 2. Work in ../my-feature directory

# 3. After testing, merge:
git merge --no-ff feature/my-feature
```

### Hotfix
```bash
git worktree add ../hotfix -b hotfix/issue-description
# ... fix ...
git merge --no-ff hotfix/issue-description
```

### Pi Package Development
```bash
# Always use worktree for packages
cd /path/to/pi-package
git worktree add ../pi-package-test -b test/my-change

# Test changes in ../pi-package-test
# Rebuild/reinstall as needed
```
