# Pick a Gemma 4 size per machine for local AI

Source: owner, 2026-11-05, after asking whether Gemma 4 runs well on either
plow. Nothing is broken today; backlog.

pi points at local Ollama on littleplow, and `provision-user.sh` pins
`qwen3-coder:30b`. Gemma 4 comes in E2B, E4B, 12B (added 2026-06-03), 26B A4B
(a MoE with about 4B active params per token) and 31B dense. Q4_K_M files are
about 3.4, 5.3, 7.4, 16.8 and 18.7 GB. Researched from search snippets on
2026-10-07; none of these numbers were measured on our machines:

- **littleplow** (HX 370, 890M iGPU, 23 GB visible): 12B for daily use. 26B A4B
  runs about 23-25 tok/s on the older 780M through llama.cpp Vulkan, but at
  16.8 GB it only fits with the browser closed. 31B does not fit usefully.
- **bigplow** (4080 16 GB, 32 GB RAM): 26B A4B at Q3, fully in VRAM, or at Q4
  with a small spill to system RAM. 12B when speed or long context matters.
  31B spills too much (6-9 tok/s).

Ollama would need the weights pulled through the admin, the same way as the
current Qwen pull. `provision-user.sh` also still says "the Gaming PC has no
local AI", which is no longer true once bigplow gets the same setup.

- Depends on / UI home: `nobara/provision-user.sh` step 4, `~/.pi/agent/models.json`
- Promote after the 4080 is in bigplow and someone has run Gemma 4 next to
  `qwen3-coder:30b` in pi on a real task.
