#!/usr/bin/env python3
"""PreToolUse guard: block mutating `git` commands inside a Jujutsu (jj) repo.

jj owns the git backend in a colocated repo, so raw `git commit/rebase/reset/...`
forks history and leaves detached-HEAD messes. This blocks those for the agent's
Bash tool calls (not the user's own terminal) and points at jj instead.
Read-only git (status/log/diff) and all `jj git ...` commands are allowed.
"""
import sys, json, re, os, subprocess

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

if data.get("tool_name") != "Bash":
    sys.exit(0)

cmd = (data.get("tool_input") or {}).get("command", "") or ""
if not cmd:
    sys.exit(0)

# Mutating git verbs only. Negative lookbehind excludes `jj git ...` (the correct
# way to push a jj repo). \b avoids matching inside words like "legit".
MUTATING = re.compile(
    r"(?<!jj )\bgit\s+(?:-C\s+\S+\s+)?"
    r"(?:commit|rebase|reset|checkout|switch|merge|cherry-pick|revert|push|stash|am|apply|branch\s+-[Dd])\b"
)
if not MUTATING.search(cmd):
    sys.exit(0)

# Which directory does the git command act on? Prefer `git -C X`, then `cd X &&`.
target = None
m = re.search(r"git\s+-C\s+(\S+)", cmd) or re.search(r"\bcd\s+(\S+)", cmd)
if m:
    target = m.group(1).strip("'\"")
target = os.path.expanduser(target) if target else os.getcwd()
if not os.path.isdir(target):
    target = os.getcwd()

try:
    in_jj = subprocess.run(["jj", "root"], cwd=target,
                           capture_output=True, text=True).returncode == 0
except FileNotFoundError:
    in_jj = False

if in_jj:
    print(
        "Blocked: this is a Jujutsu (jj) repo — jj owns the git backend, so raw "
        "git writes fork history. Use jj instead: `jj commit` / `jj rebase` / "
        "`jj bookmark set` / `jj git push`. See ~/.claude/CLAUDE.md.",
        file=sys.stderr,
    )
    sys.exit(2)
sys.exit(0)
