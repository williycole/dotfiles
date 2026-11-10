#!/usr/bin/env python3
"""Self-check for build_guide.py: python3 -I test_build_guide.py"""
import json
import pathlib
import subprocess
import sys
import tempfile

BUILD = pathlib.Path(__file__).resolve().parent / "build_guide.py"
PATCH = """diff --git a/app/core.py b/app/core.py
index 111..222 100644
--- a/app/core.py
+++ b/app/core.py
@@ -1,2 +1,2 @@
 keep
-old <script>alert(1)</script>
--- a deleted sql comment
+++ an added odd line
+new
diff --git a/docs/new file.md b/docs/new file.md
new file mode 100644
index 000..333
--- /dev/null
+++ b/docs/new file.md
@@ -0,0 +1 @@
+hello
diff --git a/old.txt b/moved.txt
similarity index 100%
rename from old.txt
rename to moved.txt
"""


def guide(**over):
    g = {"title": "T <b>", "range": "main → work", "tldr": "Short `code`.", "provenance": "Read all.",
         "checks": {"done": ["gate"], "pending": ["live"]},
         "decisions": [{"group": "Before merging", "title": "Pick", "problem": "P", "recommendation": "R"}],
         "chapters": [{"title": "Core", "overview": "Why.\n\n- one\n- two", "files": [
             {"path": "app/core.py", "risk": "attention", "why": "W"},
             {"path": "docs/new file.md", "risk": "safe", "why": "W"}]}],
         "unplaced": [{"path": "moved.txt", "reason": "rename only"}]}
    g.update(over)
    return g


def build(g, *flags):
    with tempfile.TemporaryDirectory() as d:
        p = pathlib.Path(d)
        (p / "g.json").write_text(json.dumps(g))
        (p / "c.patch").write_text(PATCH)
        r = subprocess.run([sys.executable, "-I", str(BUILD), str(p / "g.json"), str(p / "c.patch"), str(p / "o.html"), *flags],
                           capture_output=True, text=True)
        return r.returncode, r.stderr, (p / "o.html").read_text() if r.returncode == 0 else ""


rc, err, page = build(guide())
assert rc == 0, err
assert page.startswith("<!doctype html>")
assert "<script" not in page, "patch text must be escaped"
assert "&lt;script&gt;" in page
assert "--- a deleted sql comment" in page and "+++ an added odd line" in page, "body lines that look like headers stay"
assert "+++ b/app/core.py" not in page, "patch headers stay out"
assert "T &lt;b&gt;" in page and "<code>code</code>" in page and "<li>one</li>" in page
assert "http://" not in page and "https://" not in page, "the page loads nothing external"
assert page.count('class="file"') == 3
assert "old.txt → moved.txt" in page and 'class="badge new"' in page
assert "<details" in page and 'open><summary>' in page, "a short attention diff starts open"

rc, _, page = build(guide(), "--fragment")
assert rc == 0 and "<!doctype" not in page and page.startswith("<title>")

rc, _, page = build(guide(decisions=[]))
assert rc == 0 and "None are open." in page


def refused(want, **over):
    rc, err, _ = build(guide(**over))
    assert rc == 1 and want in err, (want, rc, err)


one = [{"path": "app/core.py", "risk": "safe", "why": "W"}]
ok_rest = [{"path": "docs/new file.md", "risk": "safe", "why": "W"}]
refused("changed file not placed: docs/new file.md", chapters=[{"title": "C", "overview": "O", "files": one}])
refused("not in the patch: ghost.py", chapters=[{"title": "C", "overview": "O", "files": one + ok_rest + [{"path": "ghost.py", "risk": "safe", "why": "W"}]}])
refused("placed more than once: app/core.py", chapters=[{"title": "C", "overview": "O", "files": one + ok_rest + one}])
refused("risk must be", chapters=[{"title": "C", "overview": "O", "files": [{"path": "app/core.py", "risk": "scary", "why": "W"}] + ok_rest}])
refused("no why", chapters=[{"title": "C", "overview": "O", "files": [{"path": "app/core.py", "risk": "safe"}] + ok_rest}])
refused("has no overview", chapters=[{"title": "C", "files": one + ok_rest}])
refused("use 1 to 10", chapters=[])
refused("has no recommendation", decisions=[{"group": "G", "title": "D", "problem": "P"}])
refused("missing provenance", provenance=" ")
refused("may not contain scripts", diagram_svg="<svg><script>x</script></svg>")
print("ok")
