---
name: backlog
description: "Capture a not-yet-planned idea as a free-form note in openspec/backlog/ without derailing the current work. Use for 'backlog this', 'add to backlog', 'someday we need X', 'note this for later', or a batch of 'eventually' ideas that come up mid-conversation. NOT for starting real work — never creates an openspec change."
---

# backlog

Drop an idea into `openspec/backlog/` and get back to what you were doing. A sidequest: you wandered off to talk about something else for a minute, this parks it so the wandering costs nothing, then you return.

Backlog is the "maybe" pile. It is not a change and not a spec. `specs/` = now, `changes/` = becoming, `backlog/` = maybe. This skill only ever touches `backlog/`.

## The one rule that matters

**Never create an openspec change.** No `openspec new change`, no `just promote`, no `changes/` edits, no proposal/spec/task scaffolding. Promotion from backlog to a real change is a deliberate human call made later. Your job is capture, not planning. If the idea clearly deserves to be worked now, say so in one line and let the user decide — do not promote it yourself.

## What a backlog note is

A single free-form markdown file at `openspec/backlog/<slug>.md`. **No YAML frontmatter, no acceptance-criteria checklist, no ceremony** — that scaffolding belongs to changes, not backlog. Just a short readable note. Match the notes already in the folder; read one first if unsure of the house voice.

Shape (keep it short — a few sentences, not a document):

```markdown
# <Human title>

Source: <who>, <date>. <one-line priority/scope note, e.g. "Not needed for X; backlog.">

<1–3 short paragraphs: what it is, why it might matter. Plain language.>

- Depends on / UI home: <related change slug(s) or component, if known>
- Promote after <the condition that would make this worth planning>.
```

The `Source`/`Promote after` lines are the useful discipline — they say where it came from and what has to be true before it graduates. Keep them.

## Steps

1. Find the backlog dir. Resolve the nearest `openspec/backlog/` (repo root, or the active store). If there is no `openspec/` here, say so and stop — this is an openspec-only skill.
2. Slug it: `<area>-<short-descriptor>`, kebab, lowercase, a few words. Match sibling filenames.
3. Write `openspec/backlog/<slug>.md` in the shape above. Fill `Source` with who raised it and today's date. Cross-link a related change/backlog slug when you know one.
4. Batch: if the user threw several ideas at once, write one file per idea in a single pass.
5. Report back as a short list: each file written + its one-line gist. Then return to whatever was interrupted — do not expand into planning any of them.

## Don't

- Don't create or edit anything under `changes/` or `specs/`.
- Don't add frontmatter or an acceptance-criteria template to a backlog note.
- Don't turn a one-line idea into a design doc. If it needs real thinking, that is `/opsx:explore`, not this.
