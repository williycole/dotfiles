---
description: Speak a short, plain-English version of my last reply. /say:full whole reply, /say:on|off auto, /say:quiet this pane, /say:test audio check, /say:stop hush.
---

Condense your previous reply for the ear, not the eye: unslop it, then cut to the TLDR. One to four short spoken sentences, conversational, no jargon, no markdown, no code, no file paths unless essential. Keep the decision or finding and anything I must act on. Drop everything else.

Write that text to `<scratchpad dir>/say-tldr.txt` (scratchpad dir is named in your system prompt), then run `/usr/local/lib/claude/hooks/say-reply.sh --last "<scratchpad dir>/say-tldr.txt"`.

Reply with only the spoken text, prefixed with 🔊.
