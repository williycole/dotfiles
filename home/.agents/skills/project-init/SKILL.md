---
name: project-init
description: Scaffold a new agentic project — drops the OpenSpec skeleton, generic AGENTS.md, and playwright .mcp.json, then hands off to /opsx:explore. Use when starting a new project/repo, "init a project", "new project", "spin up a project", or turning an idea into a working repo.
license: MIT
metadata:
  author: local
  version: "1.0"
---

# project-init

Scaffold a new project's agentic setup from this skill's own `templates/`, then start
exploring the first idea. Lays down the per-project OpenSpec skeleton — copies canonical
files; does not improvise structure.

## Template location

Resolve the template dir (one canonical store, symlinked into each agent):
```bash
TPL=~/.agents/skills/project-init/templates
```

## 1. Interview

Ask the user (accept answers inline; use sensible defaults):
- **Project name** (required) → `{{PROJECT_NAME}}`
- **Target dir** (default `~/Repos/<name>`)
- **Test command** (optional; e.g. `mix test`, `npm test` — leave blank to keep `# TODO`)
- **Forge** — `github` (default) / `gitlab` / `none`
- **git init?** — y/N

## 2. No-clobber guard

```bash
[ -e "$TARGET/openspec" ] && { echo "Refusing: $TARGET already has openspec/"; exit 1; }
mkdir -p "$TARGET"
```

## 3. Scaffold

```bash
cp -R "$TPL/openspec"   "$TARGET/openspec"
cp    "$TPL/AGENTS.md"  "$TARGET/AGENTS.md"
cp    "$TPL/CLAUDE.md"  "$TARGET/CLAUDE.md"
cp    "$TPL/mcp.json"   "$TARGET/.mcp.json"
cp -R "$TPL/dot-claude" "$TARGET/.claude"
```

Then substitute, across `$TARGET` (use the actual project name):
- `{{PROJECT_NAME}}` → the name — in `openspec/config.yaml`, `openspec/README.md`,
  `openspec/work-order.md`, `AGENTS.md`.
- If a test command was given, fill the `## Stack` TODO in `AGENTS.md`.

(Use `find`+`sed` or edit the files directly. Verify substitutions before moving on.)

## 4. Optional git

```bash
[ "$GIT" = y ] && { cd "$TARGET" && git init -q && git add -A && git commit -q -m "chore: scaffold agentic project"; }
```

## 5. Hand off

Print a short summary (what was created, forge). Then:
> "Scaffolded **{name}** at {target}. Next: describe your first idea and I'll run
> `/opsx:explore` to write it into `openspec/explore/`."

If the user gives an idea now, invoke the **`/opsx:explore`** skill in `$TARGET` for it.

## Notes

- Copies canonical scaffold files only; never improvises structure.
- Local `work-order.md` is the change queue; `openspec/README.md` documents the workflow.
