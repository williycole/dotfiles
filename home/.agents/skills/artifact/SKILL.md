---
name: artifact
description: "Publish an HTML page as a private claude.ai artifact from ANY agent. Use for 'make an artifact', 'publish this as a page', 'give me a link', or any brief / report / dashboard someone else will open. Inside Claude Code the Artifact tool does it directly. Inside pi, or any host without that tool, the skill writes the page and hands the publish to a Claude Code pane, because headless Claude Code (the Agent SDK path pi-claude-bridge uses) has no Artifact tool at all."
license: MIT
---

# /artifact — page here, publish there

The `Artifact` tool exists only in an interactive Claude Code session. `claude -p`,
the Agent SDK, and therefore `pi-claude-bridge` never load it (verified 2026-11-02,
Claude Code 2.1.287). So the work splits: whoever has the content writes the page;
an interactive Claude Code publishes it.

## 0. Which host am I in

- **`Artifact` is in your tool list** (interactive Claude Code): write the page per
  `page-rules.md`, call `Artifact` with `file_path`, `icon`, `description`, then run
  `open <url>` from Bash (the tool's own open action does not reach the browser) and
  print the link. Done, skip the rest.
- **No `Artifact` tool** (pi, headless, anything else): steps 1 to 3.

## 1. Write the page

```bash
mkdir -p ~/Repos/artifacts
```

- Path: `~/Repos/artifacts/<slug>.html`. Slug = 2 to 4 kebab words naming the page
  (`weekly-brief`, `access-model`). Same slug later = update the same artifact.
- Content follows `page-rules.md` in this skill. It is the same contract Claude
  Code's built-in `artifact-design` skill enforces, vendored so the page is equal
  whoever writes it.
- Never paste the HTML into chat. The file is the deliverable.

## 2. Hand the publish to Claude Code

Write the prompt to a file first; it avoids every quoting problem:

```bash
cat > ~/Repos/artifacts/<slug>.prompt <<'EOF'
Publish ~/Repos/artifacts/<slug>.html as a private artifact with the Artifact tool.
icon: <one generic word>. description: <one sentence>.
Do not change the page content.
Then write the resulting URL, and nothing else, to ~/Repos/artifacts/<slug>.url,
and run: open <url>
EOF
```

If `~/Repos/artifacts/<slug>.url` already exists, add one line to the prompt:
`Update the existing artifact at <that url> in place (pass it as url); do not create a new one.`
and read that URL before deleting the file below.

**With Herdr** (`HERDR_ENV=1`): the user watches the pane and answers its
permission prompt there.

```bash
rm -f ~/Repos/artifacts/<slug>.url
pane=$(herdr pane split --current --direction right --cwd "$HOME/Repos/artifacts" --no-focus | jq -r .result.pane.pane_id)
herdr agent start artifact-publisher --kind claude --pane "$pane"
herdr agent wait artifact-publisher --until idle --timeout 60000
herdr agent prompt artifact-publisher "$(cat ~/Repos/artifacts/<slug>.prompt)" --wait --timeout 240000
for i in $(seq 1 60); do [ -s ~/Repos/artifacts/<slug>.url ] && break; sleep 2; done
cat ~/Repos/artifacts/<slug>.url
```

- Start `claude` bare, then `agent prompt`. Passing the prompt after `--` fails
  with `agent arguments cannot be encoded safely for the target shell`.
- `agent start` may return `agent_not_ready` while Claude Code's startup hooks
  run; that is why the `wait --until idle` is there. Ignore the error and wait.
- No URL after the loop: `herdr agent get artifact-publisher`. `blocked` means the
  pane is waiting on the user (permission dialog). Say so and stop; do not answer
  the dialog yourself and never `send-keys` around a refusal.
- Close the pane once the URL is in hand: `herdr pane close "$pane"`. Leave it
  open only if the user asked to keep tweaking the page there.

**Without Herdr**: print this one command for the user and stop.

```bash
cd ~/Repos/artifacts && claude "$(cat ~/Repos/artifacts/<slug>.prompt)"
```

## 3. Report

The link, one line. Nothing else.

## Rules

- A link is an external publish. Only do it when the user asked for an artifact
  or a link in this conversation.
- No page that imitates a real person or organization, no fabricated records
  presented as genuine. The Artifact tool refuses these; do not route around it.
- Keep `~/Repos/artifacts/<slug>.url`. It is the memory that makes the next run an
  update instead of a second artifact.
