# Page rules

The contract Claude Code's built-in `artifact-design` skill enforces, vendored
(2026-11-02) so a page written in pi is equal to one written in Claude Code.

## File

- One self-contained `.html`: `<!doctype html>`, `<meta charset="utf-8">`,
  `<meta name="viewport" content="width=device-width, initial-scale=1">`.
- `<title>` is a NAME, two to four words (`Weekly Brief`, `Access Model`). Never
  "Name: explainer". The explanation goes in the publish `description`.
- CSS and JS inline. External scripts only from `cdnjs.cloudflare.com`
  (preferred), `cdn.jsdelivr.net/npm/`, `unpkg.com`, `cdn.tailwindcss.com`,
  `code.jquery.com`. Stylesheets only from Google Fonts. Nothing else loads.
- Rendered page 16 MB or smaller; embedded `data:` URIs count.

## Theme

- Every color is a token on `:root`.
- Dark mode is defined twice, same tokens:

```css
:root { --bg: #fff; --fg: #111; --muted: #666; --accent: #2563eb; --line: #e5e7eb; }
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) { --bg: #111; --fg: #eee; --muted: #999; --accent: #60a5fa; --line: #333; }
}
:root[data-theme="dark"] { --bg: #111; --fg: #eee; --muted: #999; --accent: #60a5fa; --line: #333; }
body { background: var(--bg); color: var(--fg); }
```

- `body` gets an explicit background. Never rely on the browser default.

## Layout

- Works at phone width: 16px side gutter, no horizontal page scroll, a centered
  `max-width` container (about 720px for prose, wider for dashboards).
- System font stack or one Google Font. Comfortable line length, real headings.

## Content

- Lead with the answer or outcome. The reader did not watch the work.
- Numbers go in a table or a stat tile, not in prose.
- Charts: inline SVG, or one cdnjs library. Same palette tokens, legible in both
  themes, labeled axes.
- Parallel items are a list. A single argument is prose.

## Browser storage

- `localStorage` and friends are per viewer, per browser, and may throw or come
  back empty. Wrap every read and write in `try/catch`; the page must render
  without it. Use it only for per-viewer conveniences (a remembered tab), never
  for anything shared or anything the author must read back.

## Never

- No page that imitates a real person or organization (name, logo, byline,
  domain), no fabricated records or receipts presented as genuine, no forms that
  collect credentials or payment details. Claude Code refuses to publish these.
