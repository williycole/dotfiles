#!/usr/bin/env bash
# provision-user.sh — Nobara user setup (the OWNER runs this; NO admin needed).
#
# Covers the dev bits that are NOT package-manager installs and so aren't in
# packages.yaml / install-packages:
#   1. Odin compiler      → binary drop to ~/.local (user-level; URL resolved via GitHub API)
#   2. ols + odinfmt      → binary drops to ~/.local/bin (both ship in the ols release zip)
#   3. Neovim ≥0.12       → binary drop (Fedora's rpm lags; refactor.nvim needs 0.12+)
#   4. pi → local Ollama  [Pocket 4 only] → writes ~/.pi/agent/models.json
#   5. tree-sitter CLI config → ~/.config/tree-sitter/config.json (nvim parser builds)
#   6. Aseprite check → ~/Apps/aseprite/bin/aseprite (manual AppImage; paid, Humble login)
#   8. Odin vendor libs → build stb/miniaudio/box2d linux .a on the host
#   9. offline reference mirror → ~/Reference (docs readable with no internet)
#  10. omp (oh-my-pi coding agent) → prebuilt binary drop to ~/.local/bin/omp
#  11. (removed) glow host wrapper — glow is a real host binary via mise now
#  12. Godot editor → binary drop to ~/.local/bin/godot (official godotengine.org build)
#  13. cliamp → terminal music player; replaces the Spotify flatpak, which is a
#      wrapper that downloads Canonical's snap at install time
#  10. offline reference mirror → ~/Reference (n64/odin repos + VR4300 pdf)
#  11. omp (oh-my-pi coding agent) → prebuilt binary drop to ~/.local/bin (config in dot_omp)
#
# Prereqs (run first, all no-admin): `mise install`, then `install-packages`
#   (which installs the CLI tools + compilers + GUI apps, all user-level).
# Needs the internet ON (downloads).
#
# Usage:
#   ./provision-user.sh --dry-run            # preview
#   ./provision-user.sh                      # Odin/ols/odinfmt
#   ./provision-user.sh --pocket4            # also configure pi → local Ollama
#
# Download URLs: Odin's is resolved from the GitHub API each run (its asset names embed
# the version, so no fixed URL works); ols's asset name is stable. Failures are
# non-fatal — they warn and skip that tool; re-run any time to retry.

set -uo pipefail

DRY_RUN=0
POCKET4=0
LOCAL="$HOME/.local"
BIN="$LOCAL/bin"

# Odin's release assets embed the version (odin-linux-amd64-dev-YYYY-MM.tar.gz), so a
# fixed `releases/latest/download/<name>` URL can never work — resolve it from the API.
# ols's asset name IS stable, so its latest/download URL is fine.
ODIN_URL="${ODIN_URL:-$(curl -fsSL https://api.github.com/repos/odin-lang/Odin/releases/latest 2>/dev/null \
  | grep -o 'https://[^"]*odin-linux-amd64[^"]*\.tar\.gz' | head -1)}"
OLS_URL="${OLS_URL:-https://github.com/DanielGavin/ols/releases/latest/download/ols-x86_64-unknown-linux-gnu.zip}"

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --pocket4) POCKET4=1 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown arg: $1"; exit 2 ;;
  esac
  shift
done

c_blue=$'\033[1;34m'; c_grn=$'\033[1;32m'; c_yel=$'\033[1;33m'; c_rst=$'\033[0m'
step() { printf '%s==>%s %s\n' "$c_blue" "$c_rst" "$*"; }
ok()   { printf '  %s✓%s %s\n'  "$c_grn"  "$c_rst" "$*"; }
warn() { printf '  %s!%s %s\n'  "$c_yel"  "$c_rst" "$*"; }
run()  { if [ "$DRY_RUN" = 1 ]; then printf '  [dry-run] %s\n' "$*"; else eval "$@"; fi; }

[ "$DRY_RUN" = 1 ] && step "DRY RUN — no changes will be made"
mkdir -p "$BIN"

# ── 1. Odin (binary drop) ───────────────────────────────────
step "1. Odin compiler → $LOCAL/odin (user-level, no admin)"
if command -v odin >/dev/null 2>&1 && [ "$DRY_RUN" = 0 ]; then ok "odin already on PATH"; elif [ -z "$ODIN_URL" ]; then
  warn "could not resolve Odin release URL from the GitHub API (offline?) — skipping odin"
else
  warn "downloading Odin: $ODIN_URL"
  run "mkdir -p '$LOCAL/odin'"
  run "curl -fsSL '$ODIN_URL' -o /tmp/odin.tar.gz && tar -xzf /tmp/odin.tar.gz -C '$LOCAL/odin' --strip-components=1" \
    && run "ln -sf '$LOCAL/odin/odin' '$BIN/odin'" && ok "odin → $BIN/odin" || warn "odin download failed — verify URL and retry"
fi

# ── 2. ols + odinfmt (both prebuilt, in the SAME release zip) ───────────────
# The zip's binaries are versioned names (ols-x86_64-unknown-linux-gnu, odinfmt-…),
# NOT bare 'ols'/'odinfmt' — match with a glob.
step "2. ols (Odin LSP) + odinfmt → $BIN"
if command -v ols >/dev/null 2>&1 && command -v odinfmt >/dev/null 2>&1 && [ "$DRY_RUN" = 0 ]; then
  ok "ols + odinfmt already on PATH"
else
  warn "downloading ols release (contains odinfmt too): $OLS_URL"
  if run "curl -fsSL '$OLS_URL' -o /tmp/ols.zip && unzip -oq /tmp/ols.zip -d /tmp/ols-extract"; then
    run "install -m 0755 \$(find /tmp/ols-extract -name 'ols-*'     -type f | head -1) '$BIN/ols'"     && ok "ols → $BIN/ols"         || warn "ols install failed (binary not found in zip?)"
    run "install -m 0755 \$(find /tmp/ols-extract -name 'odinfmt-*' -type f | head -1) '$BIN/odinfmt'" && ok "odinfmt → $BIN/odinfmt" || warn "odinfmt install failed (binary not found in zip?)"
  else warn "ols download failed — verify URL and retry"; fi
fi

# ── 3. Neovim ≥0.12 (binary drop) ───────────────────────────
# Fedora's neovim rpm lags stable (0.11.x while 0.12 is out); refactor.nvim
# needs 0.12+. ~/.local/bin precedes /usr/bin on PATH (mise/common.sh), and
# a single drop under $HOME covers everything now that there is no sandbox.
NVIM_URL="${NVIM_URL:-https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz}"
step "3. Neovim (latest stable) → $LOCAL/nvim (shadows the older host rpm)"
if [ "$DRY_RUN" = 0 ] && command -v nvim >/dev/null 2>&1 \
   && nvim --version | head -1 | grep -qE 'v(0\.(1[2-9]|[2-9][0-9])|[1-9])'; then
  ok "$(nvim --version | head -1) already ≥0.12"
else
  warn "downloading Neovim: $NVIM_URL"
  run "curl -fsSL '$NVIM_URL' -o /tmp/nvim.tar.gz && rm -rf '$LOCAL/nvim' && mkdir -p '$LOCAL/nvim' && tar -xzf /tmp/nvim.tar.gz -C '$LOCAL/nvim' --strip-components=1" \
    && run "ln -sf '$LOCAL/nvim/bin/nvim' '$BIN/nvim'" && ok "nvim → $BIN/nvim" || warn "nvim download failed — verify URL and retry"
fi

# ── 4. pi → local Ollama  [Pocket 4 only] ───────────────────
if [ "$POCKET4" = 1 ]; then
  step "4. [Pocket 4] pi → local Ollama (offline AI)"
  PI_DIR="$HOME/.pi/agent"
  # pi ≥0.80 schema: top-level "providers" (the old {"models":[…]} form is rejected
  # at startup with "must have required properties providers"). apiKey is a dummy —
  # Ollama ignores it, but pi hides models whose provider has no key. compat flags:
  # Ollama's OpenAI endpoint understands neither the developer role nor reasoning_effort.
  PI_MODELS='{
  "providers": {
    "ollama": {
      "baseUrl": "http://localhost:11434/v1",
      "api": "openai-completions",
      "apiKey": "ollama",
      "compat": {
        "supportsDeveloperRole": false,
        "supportsReasoningEffort": false
      },
      "models": [
        { "id": "qwen3-coder:30b", "name": "Qwen3 Coder 30B (Local)" }
      ]
    }
  }
}'
  # qwen3-coder:30b = MoE, 3.3B active params — ideal on a bandwidth-limited iGPU
  # (fast like a ~3B, smart like a 30B). 19GB at Q4: fits 32GB unified RAM but don't
  # run it alongside big compiles. Lightweight fallback: qwen2.5-coder:7b (4.7GB).
  # Pull with: ollama pull qwen3-coder:30b  (admin, internet ON).
  if [ "$DRY_RUN" = 1 ]; then
    printf '  [dry-run] mkdir -p %s && write models.json → localhost:11434\n' "$PI_DIR"
    printf '%s\n' "$PI_MODELS" | sed 's/^/      | /'
  else
    mkdir -p "$PI_DIR"
    printf '%s\n' "$PI_MODELS" > "$PI_DIR/models.json"; ok "wrote $PI_DIR/models.json (model = qwen3-coder:30b — change to fit)"
    warn "pull the model in an online window: ollama pull qwen3-coder:30b"
    warn "enable pi's permission-gate (pi runs commands without asking by default)"
  fi
else
  step "4. pi → local Ollama — SKIPPED (pass --pocket4 to configure; the Gaming PC has no local AI)"
fi

# ── 5. tree-sitter CLI config ─────────────────────────────────
# nvim-treesitter (main branch) compiles parsers via the system tree-sitter CLI,
# which panics on any :TSInstall until ~/.config/tree-sitter/config.json exists.
# The generated file hardcodes $HOME paths, so it's created here, not repo-managed.
step "5. tree-sitter CLI config (parser builds panic without it)"
if [ -f "$HOME/.config/tree-sitter/config.json" ]; then
  ok "~/.config/tree-sitter/config.json present"
elif ! command -v tree-sitter >/dev/null 2>&1; then
  warn "tree-sitter CLI not found — after installing it, run: tree-sitter init-config"
elif [ "$DRY_RUN" = 1 ]; then
  printf '  [dry-run] tree-sitter init-config\n'
else
  tree-sitter init-config >/dev/null && ok "wrote ~/.config/tree-sitter/config.json" \
    || warn "tree-sitter init-config failed — run it by hand"
fi

# ── 6. Aseprite (manual — paid, behind the Humble Bundle login) ─
# Can't be curl'd: the download needs your Humble login. This just checks the
# drop exists where the bashrc alias points and prints instructions if not.
step "6. Aseprite (manual drop — ~/Apps/aseprite/bin/aseprite)"
if [ -x "$HOME/Apps/aseprite/bin/aseprite" ]; then
  ok "aseprite present"
else
  warn "aseprite missing — grab the Linux AppImage from your Humble Bundle library"
  warn "(https://www.humblebundle.com/home/library → Aseprite → Aseprite_*-x64.AppImage), then:"
  warn "  mkdir -p ~/Apps/aseprite/bin && mv ~/Downloads/Aseprite_*-x64.AppImage ~/Apps/aseprite/bin/aseprite && chmod +x ~/Apps/aseprite/bin/aseprite"
fi

# ── 8. Odin vendor libs (stb, miniaudio, box2d) ───────────────
# vendor:raylib ships linux .a/.so; stb/miniaudio/box2d ship darwin+wasm only,
# so their linux .a must be built once. This used to run inside the dev distrobox;
# it builds on the HOST now — gcc/make are Nobara base packages and cmake comes
# from mise. box2d's build script DOWNLOADS its C source — needs the internet ON.
# System-lib bindings (SDL2/3, glfw, enet, lua) come from packages.yaml -devel
# entries; a fresh Odin drop (step 1) wipes these libs — re-run this after.
step "8. Odin vendor libs (stb/miniaudio/box2d linux builds)"
VEND="$LOCAL/odin/vendor"
build_vendor() { # <name> <marker-file> <dir> <cmd>
  if [ -f "$2" ]; then ok "$1 present"
  elif [ "$DRY_RUN" = 1 ]; then printf '  [dry-run] cd %s && %s\n' "$3" "$4"
  elif ( cd "$3" && eval "$4" ) >/dev/null 2>&1; then ok "$1 built"
  else warn "$1 build failed (box2d needs internet; all three need gcc/make on PATH)"; fi
}
if [ ! -d "$VEND" ]; then
  warn "odin vendor tree missing — run step 1 first"
else
  build_vendor stb       "$VEND/stb/lib/stb_image.a"                "$VEND/stb/src"       "./build_stb.sh"
  build_vendor miniaudio "$VEND/miniaudio/lib/miniaudio.a"          "$VEND/miniaudio/src" "./build_miniaudio.sh"
  build_vendor box2d     "$VEND/box2d/lib/box2d_other_amd64_sse2.a" "$VEND/box2d"         "./build_box2d.sh"
fi

# ── 9. Offline reference mirror → ~/Reference ────────────────
# Repos + PDFs for airgapped game dev (see README.md). Shallow clones;
# idempotent. Toolchain installs (rustup/embeddedgo/libdragon image) are the
# doc's "online prep" section — too interactive/version-y to script blindly.
step "9. offline reference mirror → ~/Reference"
if [ "$DRY_RUN" = 1 ]; then
  printf '  [dry-run] clone n64 repos + odin examples; fetch VR4300 pdf\n'
else
  mkdir -p "$HOME/Reference/n64" "$HOME/Reference/odin" "$HOME/Reference/pdf"
  while read -r repo dest; do
    d="$HOME/Reference/$dest"
    if [ -d "$d" ]; then ok "$dest present"
    elif git clone -q --depth 1 "https://github.com/$repo" "$d"; then ok "$dest cloned"
    else warn "$dest clone failed ($repo)"; fi
  done <<'EOF'
dragonminded/libdragon n64/libdragon
clktmr/n64 n64/n64
clktmr/gopher-kart n64/gopher-kart
rust-n64/nust64 n64/nust64
lemmy-64/n64-systemtest n64/n64-systemtest
rust-console/rrt0 n64/rrt0
command-tab/awesome-n64-development n64/awesome-n64-development
odin-lang/examples odin/examples
raysan5/raylib raylib
EOF
  PDF="$HOME/Reference/pdf/VR4300-cpu-manual.pdf"
  if [ -f "$PDF" ]; then ok "VR4300 manual present"
  else curl -fsSL -o "$PDF" 'http://datasheets.chipdb.org/NEC/Vr-Series/Vr43xx/U10504EJ7V0UMJ1.pdf' \
    && ok "VR4300 manual fetched" || warn "VR4300 pdf fetch failed"; fi
fi

# ── 10. omp (oh-my-pi coding agent, prebuilt binary drop) ─────
# Not a package-manager tool — official installer drops the prebuilt binary to
# ~/.local/bin (its default INSTALL_DIR = $BIN). --binary forces the prebuilt
# path for a deterministic drop (skips the bun/source build even when bun is
# present at ~/.bun). Config lives in the repo at home/.omp/agent — this
# only supplies the missing binary.
step "10. omp (oh-my-pi) → $BIN/omp"
if command -v omp >/dev/null 2>&1 && [ "$DRY_RUN" = 0 ]; then
  ok "omp already on PATH"
else
  warn "installing omp (prebuilt binary)"
  run "curl -fsSL https://omp.sh/install.sh | sh -s -- --binary" \
    && ok "omp → $BIN/omp" || warn "omp install failed — retry: curl -fsSL https://omp.sh/install.sh | sh"
fi

# ── 11. (removed) glow host wrapper ───────────────────────────
# glow used to be a dnf package inside the dev distrobox, with an exported
# wrapper so the `cat *.md` override in common.sh could reach it from the host
# shell. glow comes from mise now and is a real host binary, so there is nothing
# left to export. Step number kept so the surrounding numbering still lines up.

echo
# NB: not ${DRY_RUN:+…} — that expands whenever the var is set, including DRY_RUN=0.
# ── 12. Godot editor (official build, NOT the flatpak) ────────
# The owner wants the build from godotengine.org, not Flathub (decided 2026-08-20),
# so this is a binary drop like Odin/ols/nvim above rather than a packages.yaml
# flatpak entry.
#
# WATCH OUT: Nobara may already ship `godot-runner` as a dependency. That is a
# RUNTIME for playing Godot games — "Shared binary to play games and run servers
# developed with the Godot engine" — and provides no editor. Seeing it installed
# is not evidence that Godot is; that mistake is why this step exists.
GODOT_VER="${GODOT_VER:-4.7.1}"
GODOT_URL="${GODOT_URL:-https://github.com/godotengine/godot/releases/download/${GODOT_VER}-stable/Godot_v${GODOT_VER}-stable_linux.x86_64.zip}"
step "12. Godot $GODOT_VER → $BIN/godot"
if [ "$DRY_RUN" = 0 ] && command -v godot >/dev/null 2>&1 \
   && godot --version 2>/dev/null | grep -q "^${GODOT_VER}\."; then
  ok "godot $GODOT_VER already installed"
else
  warn "downloading Godot: $GODOT_URL"
  run "curl -fsSL '$GODOT_URL' -o /tmp/godot.zip \
       && unzip -o -q /tmp/godot.zip -d /tmp/godot-extract \
       && install -m 0755 '/tmp/godot-extract/Godot_v${GODOT_VER}-stable_linux.x86_64' '$BIN/godot' \
       && rm -rf /tmp/godot.zip /tmp/godot-extract" \
    && ok "godot → $BIN/godot" || warn "godot download failed — verify URL and retry"
fi

# ── 12b. Godot → nvim as the script editor ────────────────────
# NOT SCRIPTED, on purpose. Three reasons, and they all point the same way:
#
#  1. There is no supported API for it. EditorInterface.get_editor_settings()
#     is only available inside an EditorPlugin, not a command-line script, so
#     the "proper" route does not exist from out here.
#  2. Writing editor_settings-*.tres directly races the editor. Godot holds
#     those settings in memory and rewrites the whole file on exit, so an
#     external edit made while Godot is open is silently discarded — the same
#     failure shape as Plasma's appletsrc.
#  3. It is three fields, once per machine, in a GUI the owner is already in.
#
# Godot 4.7 ships auto-detected flags for emacs, geany, kate and VS Code only,
# so nvim is a "Custom" entry either way.
# ── 13. cliamp (terminal music player, Spotify via librespot) ──
# REPLACES the Spotify flatpak, and that is the point rather than a side effect.
# Flathub's "Spotify" is not a Spotify build: it is a wrapper that downloads
# Canonical's SNAP from api.snapcraft.io at install time. A box that refuses
# arbitrary downloads should not have one of those as its music player.
#
# cliamp embeds go-librespot and IS a Spotify Connect device, so nothing else
# has to be running — unlike spotify-tui, which only remote-controlled the
# desktop app. Needs Spotify PREMIUM: the free tier has no audio-stream API.
#
# Binary drop from the GitHub release, not `curl https://cliamp.stream/... | sh`:
# that domain does not resolve here, and a checksum-verified release asset
# is better than a piped installer regardless.
CLIAMP_VER="${CLIAMP_VER:-v2.3.0}"
step "13. cliamp $CLIAMP_VER → $BIN/cliamp"
if [ "$DRY_RUN" = 0 ] && command -v cliamp >/dev/null 2>&1 \
   && cliamp --version 2>/dev/null | grep -q "$CLIAMP_VER"; then
  ok "cliamp $CLIAMP_VER already installed"
elif ! command -v gh >/dev/null 2>&1; then
  warn "gh not on PATH — install cliamp by hand from github.com/bjarneo/cliamp/releases"
else
  _tmp=$(mktemp -d)
  # Verify the checksum. The release ships checksums.txt; a truncated download
  # would otherwise install as a binary that runs and then fails oddly.
  if run "gh release download '$CLIAMP_VER' --repo bjarneo/cliamp -p cliamp-linux-amd64 -p checksums.txt -D '$_tmp'" \
     && run "cd '$_tmp' && grep 'cliamp-linux-amd64\$' checksums.txt | sha256sum -c -" \
     && run "install -m 0755 '$_tmp/cliamp-linux-amd64' '$BIN/cliamp'"; then
    ok "cliamp → $BIN/cliamp"
  else
    warn "cliamp download or checksum failed — verify the release and retry"
  fi
  rm -rf "$_tmp"
fi
echo "   First run: cliamp setup → Spotify. Register your own client_id at"
echo "   developer.spotify.com (redirect URI http://127.0.0.1:19872/login) —"
echo "   the built-in one is shared worldwide with librespot and spotify-player"
echo "   users and returns 429 when that pool is busy."

step "12b. Godot editor settings"
# The settings themselves now travel as a COPY-SET file, not a symlink:
# copy/os/linux/.config/godot/editor_settings-4.7.tres. Godot rewrites that file wholesale
# on exit, which severs a symlink — exactly the case bin/dots grew copy/ for.
# `just update` writes it out, and only when the repo copy is NEWER, so local
# tweaks are not clobbered.
#
# Carried in it: the nvim hand-off, Kanagawa-Wave syntax, the Custom interface
# preset matching ghostty, and language_server/use_thread (which godot-neovim
# needs for `gd`).
echo "   settings travel via copy/os/linux/.config/godot/editor_settings-4.7.tres"
echo "   apply with: just sync-apply   (with Godot CLOSED — it rewrites the file on exit)"
echo
echo "   Per-PROJECT, not per-machine — addons live in <project>/addons/:"
echo "     godot-neovim   vim motions in Godot's own editor + shader editor"
echo
echo "   Godot only rescans text_editor_themes/ at startup, so a new machine"
echo "   needs one restart before Kanagawa-Wave appears in the theme list."

step "provision-user.sh done$([ "$DRY_RUN" = 1 ] && echo ' (dry-run)'). Ensure $BIN is on PATH (mise/common.sh handles this)."
