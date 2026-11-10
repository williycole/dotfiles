#!/usr/bin/env python3
"""Build a guided review page from guide.json and a unified git-format patch.

    build_guide.py guide.json change.patch out.html [--fragment]

Refuses a guide that misses, repeats or invents a changed file. --fragment
leaves out the document wrapper, for hosts that add their own. Standard
library only.
"""
import html
import json
import pathlib
import re
import sys

RISK = {"attention": "ATTENTION", "check": "CHECK", "safe": "SAFE"}
ORDER = {"attention": 0, "check": 1, "safe": 2}
OPEN_LINE_LIMIT = 400  # attention diffs longer than this start closed, to keep the page scannable


def die(problems):
    print("build_guide: guide refused:", file=sys.stderr)
    for p in problems:
        print("  - " + p, file=sys.stderr)
    sys.exit(1)


def inline(text):
    s = html.escape(text, quote=False)
    s = re.sub(r"`([^`]+)`", r"<code>\1</code>", s)
    return re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", s)


def md(text):
    out = []
    for block in re.split(r"\n\s*\n", (text or "").strip()):
        lines = [l.strip() for l in block.splitlines() if l.strip()]
        if lines and all(l.startswith("- ") for l in lines):
            out.append("<ul>" + "".join(f"<li>{inline(l[2:])}</li>" for l in lines) + "</ul>")
        elif lines:
            out.append(f"<p>{inline(' '.join(lines))}</p>")
    return "".join(out)


def unquote(path):
    if path.startswith('"') and path.endswith('"'):
        raw = path[1:-1].encode("latin-1", "backslashreplace").decode("unicode_escape")
        return raw.encode("latin-1", "replace").decode("utf-8", "replace")
    return path


def parse_patch(text):
    files = {}
    for block in re.split(r"(?m)^(?=diff --git )", text):
        if not block.startswith("diff --git "):
            continue
        head, _, rest = block.partition("\n")
        m = re.match(r'diff --git ("?a/.*"?) ("?b/.*"?)$', head)
        if not m:
            die([f"cannot parse patch header: {head}"])
        a, b = unquote(m.group(1))[2:], unquote(m.group(2))[2:]
        moved = re.search(r"(?m)^rename from ", rest[:600])
        state = ("NEW" if re.search(r"(?m)^new file mode", rest[:300]) else
                 "DEL" if re.search(r"(?m)^deleted file mode", rest[:300]) else
                 "REN" if moved else "MOD")
        # Headers end at the first hunk. Past it, "--- x" is a deleted line "-- x".
        all_lines = rest.split("\n")
        first = next((i for i, l in enumerate(all_lines) if l.startswith("@@")), len(all_lines))
        lines = all_lines[first:]
        files[b] = {
            "path": b, "from": a, "state": state, "lines": lines,
            "adds": sum(l.startswith("+") for l in lines),
            "dels": sum(l.startswith("-") for l in lines),
        }
    return files


def validate(guide, files):
    problems = []
    for key in ("title", "range", "tldr", "provenance"):
        if not str(guide.get(key) or "").strip():
            problems.append(f"missing {key}")
    for key in ("chapters", "decisions", "checks"):
        if key not in guide:
            problems.append(f"missing {key} (decisions may be an empty list)")
    chapters = guide.get("chapters") or []
    if not 1 <= len(chapters) <= 10:
        problems.append(f"{len(chapters)} chapters; use 1 to 10")
    seen = {}
    for ch in chapters:
        name = ch.get("title") or "(untitled chapter)"
        if not ch.get("title"):
            problems.append("a chapter has no title")
        if not str(ch.get("overview") or "").strip():
            problems.append(f"chapter '{name}' has no overview")
        for f in ch.get("files") or []:
            seen.setdefault(f.get("path"), []).append(name)
            if f.get("risk") not in RISK:
                problems.append(f"{f.get('path')}: risk must be attention, check or safe")
            if not str(f.get("why") or "").strip():
                problems.append(f"{f.get('path')}: no why")
    for u in guide.get("unplaced") or []:
        seen.setdefault(u.get("path"), []).append("unplaced")
        if not str(u.get("reason") or "").strip():
            problems.append(f"{u.get('path')}: unplaced with no reason")
    problems += [f"changed file not placed: {p}" for p in files if p not in seen]
    problems += [f"not in the patch: {p}" for p in seen if p not in files]
    problems += [f"placed more than once: {p} ({', '.join(w)})" for p, w in seen.items() if len(w) > 1]
    for d in guide.get("decisions") or []:
        for key in ("group", "title", "problem", "recommendation"):
            if not str(d.get(key) or "").strip():
                problems.append(f"decision '{d.get('title', '?')}' has no {key}")
    svg = guide.get("diagram_svg") or ""
    if re.search(r"<\s*script|\son\w+\s*=|javascript:|href\s*=\s*[\"']https?:", svg, re.I):
        problems.append("diagram_svg may not contain scripts, event handlers or external links")
    if problems:
        die(problems)


def anchor(path):
    return "f-" + re.sub(r"[^a-zA-Z0-9]+", "-", path)


def stat(a, d):
    return f'<span class="add-n">+{a}</span> <span class="del-n">&minus;{d}</span>'


def render_diff(lines):
    out = []
    for l in lines:
        kind =("hunk" if l.startswith("@@") else "add" if l.startswith("+") else
                "del" if l.startswith("-") else "ctx")
        out.append(f'<span class="{kind}">{html.escape(l, quote=False) or " "}</span>')
    while out and out[-1].endswith("> </span>"):
        out.pop()
    return "\n".join(out)


def file_card(f, info, why, risk):
    name = f'{info["from"]} → {info["path"]}' if info["state"] == "REN" else info["path"]
    is_open = " open" if risk == "attention" and len(info["lines"]) <= OPEN_LINE_LIMIT else ""
    body = render_diff(info["lines"]) or '<span class="ctx">(no text diff)</span>'
    return (f'<details class="file" id="{anchor(info["path"])}"{is_open}><summary>'
            f'<span class="path">{html.escape(name)}</span>'
            f'<span class="badge {info["state"].lower()}">{info["state"]}</span>'
            f'<span class="nums">{stat(info["adds"], info["dels"])}</span>'
            f'<span class="tier {risk}">{RISK[risk]}</span></summary>'
            f'<div class="why">{inline(why)}</div><pre class="diff" tabindex="0">{body}</pre></details>')


def render(guide, files):
    css = (pathlib.Path(__file__).resolve().parent.parent / "assets" / "guide.css").read_text()
    chapters = guide["chapters"]
    decisions = guide["decisions"]
    adds = sum(f["adds"] for f in files.values())
    dels = sum(f["dels"] for f in files.values())
    o = [f'<title>{html.escape(guide["title"])}</title>',
         '<meta name="claude:viewport-fit-sides" content="cover">', f"<style>{css}</style>",
         '<nav class="toc" aria-label="Guide"><a href="#tldr">TL;DR</a>'
         f'<a href="#decisions"><strong>Decisions ({len(decisions)})</strong></a>']
    o += [f'<a href="#ch{i}"><span class="n">{i + 1}</span> {html.escape(c["title"])}</a>' for i, c in enumerate(chapters)]
    o.append('<a href="#checks">Tested and not</a><a href="#provenance">How this was made</a></nav><main>')
    o.append(f'<header><p class="eyebrow">Guided review · {html.escape(guide["range"])}</p>'
             f'<h1>{html.escape(guide["title"])}</h1>'
             f'<p class="meta">{len(files)} files · {stat(adds, dels)} · {len(decisions)} decisions open</p></header>')
    o.append(f'<div class="tldr" id="tldr">{md(guide["tldr"])}</div>')
    if guide.get("stats"):
        o.append('<div class="stats">' + "".join(
            f'<div><b>{html.escape(str(s["value"]))}</b><span>{html.escape(s["label"])}</span></div>'
            for s in guide["stats"]) + "</div>")
    o.append('<section id="decisions"><h2>Decisions you need to make</h2>')
    if not decisions:
        o.append("<p>None are open.</p>")
    groups = []
    for d in decisions:
        if d["group"] not in groups:
            groups.append(d["group"])
    n = 0
    for g in groups:
        o.append(f'<h3>{html.escape(g)}</h3><div class="decisions">')
        for d in (x for x in decisions if x["group"] == g):
            n += 1
            opts = f'<div class="opts"><b>Options</b>{md(d["options"])}</div>' if d.get("options") else ""
            o.append(f'<article><span class="num">{n}</span><div><h4>{inline(d["title"])}</h4>{md(d["problem"])}'
                     f'{opts}<div class="rec"><b>Recommendation</b>{md(d["recommendation"])}</div></div></article>')
        o.append("</div>")
    o.append("</section>")
    if guide.get("diagram_svg") or guide.get("before"):
        o.append('<section id="picture"><h2>The picture</h2>')
        if guide.get("diagram_svg"):
            cap = html.escape(guide.get("diagram_caption") or "")
            o.append(f'<figure>{guide["diagram_svg"]}<figcaption>{cap}</figcaption></figure>')
        if guide.get("before"):
            o.append(f'<div class="ba"><div><b>Before</b>{md(guide["before"])}</div>'
                     f'<div><b>After</b>{md(guide.get("after"))}</div></div>')
        o.append("</section>")
    attention = sorted((f["path"] for c in chapters for f in c.get("files") or [] if f["risk"] == "attention"))
    if attention:
        o.append('<section><h2>Read these whole</h2><div class="chips">' + "".join(
            f'<a href="#{anchor(p)}">{html.escape(p)}</a>' for p in attention) + "</div></section>")
    for i, c in enumerate(chapters):
        fs = sorted(c.get("files") or [], key=lambda f: (ORDER[f["risk"]], f["path"]))
        a = sum(files[f["path"]]["adds"] for f in fs)
        d = sum(files[f["path"]]["dels"] for f in fs)
        o.append(f'<section id="ch{i}"><h2><span class="n">{i + 1}</span> {html.escape(c["title"])}</h2>'
                 f'<p class="meta">{len(fs)} files · {stat(a, d)}</p><div class="prose">{md(c["overview"])}</div>')
        if c.get("example"):
            o.append(f'<div class="example"><b>Example</b>{md(c["example"])}</div>')
        if c.get("warning"):
            o.append(f'<div class="warning">{md(c["warning"])}</div>')
        o += [file_card(f, files[f["path"]], f["why"], f["risk"]) for f in fs]
        o.append("</section>")
    if guide.get("unplaced"):
        o.append("<section><h2>Not placed in a chapter</h2>")
        o += [file_card(u, files[u["path"]], u["reason"], "safe") for u in guide["unplaced"]]
        o.append("</section>")
    checks = guide["checks"]
    o.append('<section id="checks"><h2>Tested and not</h2><div class="ba"><div><b>Checked</b><ul>')
    o += [f"<li>{inline(t)}</li>" for t in checks.get("done") or []]
    o.append("</ul></div><div><b>Not run yet</b><ul>")
    o += [f"<li>{inline(t)}</li>" for t in checks.get("pending") or []]
    o.append("</ul></div></div></section>")
    o.append(f'<section id="provenance"><h2>How this was made</h2><div class="prose">{md(guide["provenance"])}'
             "<p>The diffs are generated from the patch. The words and the tiers are the author's judgement.</p>"
             "</div></section></main>")
    return "\n".join(o)


def main(argv):
    args = [a for a in argv if a != "--fragment"]
    if len(args) != 3:
        sys.exit(__doc__)
    guide = json.loads(pathlib.Path(args[0]).read_text())
    files = parse_patch(pathlib.Path(args[1]).read_text(errors="replace"))
    if not files:
        die(["the patch has no files"])
    validate(guide, files)
    page = render(guide, files)
    if "--fragment" not in argv:
        page = ('<!doctype html><html lang="en"><head><meta charset="utf-8">'
                '<meta name="viewport" content="width=device-width, initial-scale=1"></head><body>\n'
                + page + "\n</body></html>")
    pathlib.Path(args[2]).write_text(page)
    print(f"{args[2]}: {len(files)} files, {len(guide['chapters'])} chapters, "
          f"{len(guide['decisions'])} decisions, {len(page) // 1024} KB")


if __name__ == "__main__":
    main(sys.argv[1:])
