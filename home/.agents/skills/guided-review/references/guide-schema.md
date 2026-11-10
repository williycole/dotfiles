# guide.json

The builder reads one JSON object. Text fields take a small markdown subset: blank line for a new paragraph, `- ` bullets, `` `code` ``, `**bold**`. Everything else is escaped.

| Field | Required | Holds |
| --- | --- | --- |
| `title` | yes | What the change does, as one line |
| `range` | yes | `base → tip`, shown in the header |
| `tldr` | yes | Two or three sentences a reader could stop after |
| `chapters` | yes | 1-10 chapters, most important first |
| `decisions` | yes | May be `[]`; the page then says none are open |
| `provenance` | yes | Text from step 7 |
| `checks` | yes | `{"done": [...], "pending": [...]}` |
| `unplaced` | no | `[{"path", "reason"}]` for pure noise; should be rare |
| `stats` | no | `[{"value", "label"}]`, only figures you verified |
| `before`, `after` | no | Text for a side-by-side comparison |
| `diagram_svg` | no | Raw inline `<svg>` using the page's CSS variables, with `diagram_caption`. Scripts are refused |

**Chapter:** `title` (a concept, not a file name), `overview` (required), `example`, `warning`, `files`.

**File:** `path` (exact, as in the patch), `risk` (`attention`, `check` or `safe`), `why` (one or two sentences on what this file contributes).

**Decision:** `group` (for example "Before merging"), `title`, `problem`, `options`, `recommendation`.

Coverage is a hard rule: each path in the patch appears exactly once across `chapters[].files` and `unplaced`. A renamed file uses its new path.
