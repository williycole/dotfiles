# {{PROJECT_NAME}} — Agent Rules

The single source of truth for how agents work in this repo. Read before acting.

## Workflow

Spec-driven via OpenSpec (`openspec/`): `explore → propose → apply → archive`.
See `openspec/README.md`.

## Standards

- **TDD.** Every new module/package gets at least one test written before or alongside
  it. Do not commit implementation without a corresponding test.
- **PONYTAIL MODE.** Shortest working diff. No speculative abstractions, no new deps
  unless the task requires them.
- **Self-review before commit.** Review your own diff; for auth/webhook/external-input
  changes, do a security-focused pass.
- **Commit format.** `#{issue}: {short description}` (or `{type}({scope}): {desc}` when
  not issue-driven).

## Stack

<!-- TODO: language(s), framework(s), how to run/test. -->

## Skills manifest (for sub-agents)

| Task | Skill |
|------|-------|
| Explore an issue | `/opsx:explore` |
| Propose a change | `/opsx:propose` |
| Implement tasks | `/opsx:apply` → `openspec-ralph-apply` |
| Write tests | TDD — before/alongside the code |
| Review before commit | self-review the diff |
| Security review | manual pass on auth/webhook/external-input changes |
| UI verification | playwright MCP (see `.mcp.json`) |

Repo-specific standards (architecture, multitenancy, language idioms) go under
`docs/ai/rules/` and are obeyed by every sub-agent.
