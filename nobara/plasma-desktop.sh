#!/usr/bin/env bash
# plasma-desktop.sh — provision the owner's Plasma desktop.
#
#   bash ~/Repos/dotfiles/nobara/plasma-desktop.sh            # apply
#   bash ~/Repos/dotfiles/nobara/plasma-desktop.sh --dry-run
#
# NO ADMIN NEEDED. Everything here is per-user config.
#
# Provisions the Plasma desktop that Nobara ships. The keymap is ported from
# the owner's own prior overrides, not from any upstream defaults - that is the
# muscle memory that matters.
#
# ─────────────────────────────────────────────────────────────────────────────
# THREE STORAGE MODELS, and they behave differently. Learned at the machine
# 2026-08-16; do not assume one mechanism covers Plasma config:
#
#   1. KConfig files (kwinrc, kglobalshortcutsrc) - scriptable with
#      kwriteconfig6. Safe to manage in the repo.
#   2. KWin-owned state (kwinoutputconfig.json) - KWin REWRITES IT ON EXIT, so
#      an edit is silently lost across a relog. Must be set through System
#      Settings. The auto-rotate policy lives here; see the manual steps below.
#   3. Runtime objects (virtual desktops) - not a config value at all. Setting
#      Desktops/Number in kwinrc does NOTHING, and neither does Desktops/Rows.
#      They must be created one at a time over D-Bus, and the row count set
#      through the D-Bus property; KWin writes both back to kwinrc itself.
#
# AND: global shortcuts are only loaded when KWin STARTS. `qdbus org.kde.KWin
# /KWin reconfigure` does not reload them - verified. So this script writes the
# config and tells you to log out; the bindings arrive on the next login.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY=0
[ "${1:-}" = "--dry-run" ] && DRY=1

c_b=$'\033[1;34m'; c_y=$'\033[1;33m'; c_0=$'\033[0m'
step() { printf '%s==>%s %s\n' "$c_b" "$c_0" "$*"; }
warn() { printf '%s !%s %s\n' "$c_y" "$c_0" "$*"; }
run()  { if [ "$DRY" = 1 ]; then printf '  [dry-run] %s\n' "$*"; else eval "$@"; fi; }
have() { command -v "$1" >/dev/null 2>&1; }

if [ "$(id -u)" -eq 0 ]; then
  echo "run as the OWNER, not root — this is per-user config" >&2
  exit 1
fi

# Per-screen virtual desktops landed in Plasma 6.7. Below that, switching a
# desktop moves every monitor at once, which is the one thing that made this
# migration a non-starter before.
PLASMA_VER=$(plasmashell --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)
step "Plasma $PLASMA_VER"
if [ -n "$PLASMA_VER" ] && [ "$(printf '%s\n6.7\n' "$PLASMA_VER" | sort -V | head -1)" != "6.7" ]; then
  warn "Plasma $PLASMA_VER is below 6.7 — per-screen virtual desktops are missing."
  warn "Multi-monitor workspaces will switch every screen at once. Continuing anyway."
fi

DESKTOPS=10
DESKTOP_ROWS=2

step "1. $DESKTOPS virtual desktops in $DESKTOP_ROWS rows (D-Bus — kwinrc's Number key does nothing)"
# Rows is what shapes the pager added in step 8: it draws KWin's desktop grid
# and has no layout setting of its own, so 10 desktops / 2 rows is the 2x5 block
# in the panel. Set it here and the pager comes out right on a fresh machine.
#
# Rows is storage model 3, same as the desktops themselves — kwriteconfig6 on
# Desktops/Rows plus `reconfigure` leaves the runtime value untouched (verified
# 2026-09-07: file said 5, D-Bus still reported 2). The D-Bus property is
# readwrite and KWin writes the new value back to kwinrc itself.
if [ "$DRY" = 1 ]; then
  printf '  [dry-run] createDesktop x%d + rows=%d via org.kde.KWin.VirtualDesktopManager\n' "$((DESKTOPS-1))" "$DESKTOP_ROWS"
else
  have=$(gdbus call --session --dest org.kde.KWin --object-path /VirtualDesktopManager \
    --method org.freedesktop.DBus.Properties.Get org.kde.KWin.VirtualDesktopManager count 2>/dev/null \
    | sed -E 's/.*uint32 ([0-9]+).*/\1/')
  have=${have:-1}
  if [ "$have" -lt "$DESKTOPS" ]; then
    for i in $(seq "$have" $((DESKTOPS-1))); do
      gdbus call --session --dest org.kde.KWin --object-path /VirtualDesktopManager \
        --method org.kde.KWin.VirtualDesktopManager.createDesktop "$i" "Desktop $((i+1))" >/dev/null 2>&1 || true
    done
  fi
  gdbus call --session --dest org.kde.KWin --object-path /VirtualDesktopManager \
    --method org.freedesktop.DBus.Properties.Set org.kde.KWin.VirtualDesktopManager rows \
    "<uint32 $DESKTOP_ROWS>" >/dev/null 2>&1 || true
  vd() { gdbus call --session --dest org.kde.KWin --object-path /VirtualDesktopManager \
    --method org.freedesktop.DBus.Properties.Get org.kde.KWin.VirtualDesktopManager "$1" 2>/dev/null \
    | sed -E 's/.*uint32 ([0-9]+).*/\1/'; }
  echo "   desktops: $(vd count) in $(vd rows) rows"
fi

step "2. Meta+1-9,0 switch desktop"
# Ten, not nine: the owner's prior setup bound a tenth workspace and uses it.
#
# ── ONLY THE SWITCH DIRECTION IS BOUND HERE ─────────────────────────────────
# Moving a window to a desktop is NOT set here. Meta+Shift+<digit> cannot be
# bound on this hardware at all, so it lives in a KWin script on Meta+Ctrl -
# see step 6. Everything tried and rejected is recorded there.
for i in 1 2 3 4 5 6 7 8 9; do
  run "kwriteconfig6 --file kglobalshortcutsrc --group kwin --key 'Switch to Desktop $i' 'Meta+$i,none,Switch to Desktop $i'"
done
run "kwriteconfig6 --file kglobalshortcutsrc --group kwin --key 'Switch to Desktop 10' 'Meta+0,none,Switch to Desktop 10'"

step "3. window management, ported from the owner's hypr/bindings.conf"
# Ported from the owner's OWN overrides, not from upstream defaults - Meta+Q
# closes (not Meta+W), vim keys for focus.
#
# F keys are SWAPPED relative to the old hypr config, on request 2026-08-16:
# there Meta+F floated and Meta+Shift+F went fullscreen. Fullscreen is the one
# reached for, so it takes the shorter key.
run "kwriteconfig6 --file kglobalshortcutsrc --group kwin --key 'Window Close' 'Meta+Q,Alt+F4,Close Window'"
run "kwriteconfig6 --file kglobalshortcutsrc --group kwin --key 'Window Fullscreen' 'Meta+F,none,Make Window Fullscreen'"

step "4. application launchers"
# ─────────────────────────────────────────────────────────────────────────────
# A FOURTH STORAGE MODEL, and the one that cost a whole session. App launch
# shortcuts do NOT live in kglobalshortcutsrc. Writing
# [services][foo.desktop] _launch=Meta+X there RECORDS the shortcut - it shows
# up in System Settings, and kglobalaccel's allShortcutInfos reports it live
# with the right keycode - but the key is never grabbed, so nothing happens.
#
# The grab comes from an X-KDE-Shortcuts= line in a desktop file under
# .../kglobalaccel/ (NOT .../applications/). kglobalaccel scans that directory
# and only those entries get a real grab.
#
# Verified 2026-08-16: /usr/share/kglobalaccel/ held exactly ten files, and
# every launch shortcut that worked on this box was one of them (Dolphin Meta+E,
# Spectacle Meta+Shift+S, kcalc). All four that did nothing were absent from it.
# Ten for ten, zero for four.
#
# So: write the desktop files, do not write kglobalshortcutsrc. They are
# generated here rather than shipped in dist/ because each is four lines and
# the shortcut is the only interesting part.
#
# KRunner already ships one, so its file is copied and only the shortcut line is
# swapped - keeping Alt+Space and Alt+F2 as alternates.
#
# These replace external launcher helpers that used to wrap xdg defaults; a
# plain Exec= does the same job with no dependency. The old webapp bindings
# (Meta+Shift+M/A/Y for maps/chatgpt/youtube) are deliberately NOT ported.
ACCEL_DIR="$HOME/.local/share/kglobalaccel"
run "mkdir -p '$ACCEL_DIR'"

# RESOLVE THE BINARY TO AN ABSOLUTE PATH. .desktop files get no shell expansion,
# so a bare `Exec=nvim` is looked up against the LAUNCHER's PATH - which is
# plasmashell's, inherited at session start, and which does not include
# ~/.local/bin. The symptom is "Could not find the program", or worse a terminal
# that opens and immediately dies. environment.d fixes the PATH for anything
# started AFTER it, but a plasmashell already running keeps the old one, so an
# absolute path is what actually makes these robust. Godot and nvim both live in
# ~/.local/bin; anything dropped there later would hit the same wall.
resolve() {
  local bin="${1%% *}" rest="${1#"${1%% *}"}" abs
  abs=$(command -v "$bin" 2>/dev/null) || abs="$bin"
  printf '%s%s' "$abs" "$rest"
}

# launch <basename> <Name> <Exec> <Icon> <shortcut>
launch() {
  if [ "$DRY" = 1 ]; then
    printf '  [dry-run] write %s/%s (Exec=%s, X-KDE-Shortcuts=%s)\n' "$ACCEL_DIR" "$1" "$(resolve "$3")" "$5"
    return
  fi
  set -- "$1" "$2" "$(resolve "$3")" "$4" "$5"
  cat > "$ACCEL_DIR/$1" <<EOF
[Desktop Entry]
Type=Application
Name=$2
Exec=$3
Icon=$4
StartupNotify=false
X-KDE-Shortcuts=$5
EOF
}
launch com.mitchellh.ghostty.desktop "Ghostty"      "ghostty"              "com.mitchellh.ghostty" "Meta+Return"
# Chromium, not Firefox, since 2026-09-29: Firefox was retired and the browser
# policy is managed for Chromium. A Meta+Shift+B still pointing at firefox
# would do nothing.
launch chromium-browser.desktop      "Chromium"     "chromium-browser"     "chromium-browser"      "Meta+Shift+B"
launch org.gnome.Nautilus.desktop    "Files"        "nautilus --new-window" "org.gnome.Nautilus"   "Meta+Shift+E"
# nvim is resolved separately: resolve() only fixes the FIRST word, and here
# nvim is an ARGUMENT that ghostty looks up against its own inherited PATH -
# which is plasmashell's, without ~/.local/bin. Left bare, this opens a terminal
# that dies instantly, which is a worse failure than not launching at all.
launch dev-editor.desktop            "Editor (nvim)" "ghostty -e $(command -v nvim 2>/dev/null || echo nvim)" "nvim" "Meta+Shift+N"

# An extension may add launchers + shortcuts after this script (just desktop
# calls it), so nothing below depends on one being present.

run "sed 's/^X-KDE-Shortcuts=Alt+Space,Alt+F2,Search\$/X-KDE-Shortcuts=Meta+Space,Alt+Space,Alt+F2,Search/' \
  /usr/share/kglobalaccel/org.kde.krunner.desktop > '$ACCEL_DIR/org.kde.krunner.desktop'"

# AND CLEAR THE STALE RECORDS. This is the part that actually fixed it, and the
# reason five earlier attempts failed. kglobalaccel reads X-KDE-Shortcuts only
# when it registers a component for the FIRST time. An existing
# [services][x] _launch entry counts as that first registration, so it shadows
# the desktop file permanently - every later edit is read by nothing. A fresh
# box has no such entries and does not need this; a box where anyone ever wrote
# one does, and cannot be fixed any other way.
for svc in com.mitchellh.ghostty.desktop org.mozilla.firefox.desktop chromium-browser.desktop \
           org.gnome.Nautilus.desktop dev-editor.desktop org.kde.krunner.desktop; do
  run "kwriteconfig6 --file kglobalshortcutsrc --group services --group '$svc' --key _launch --delete"
done

# kglobalaccel reads these through the service cache, which is stale until this
# runs. Without it the new files are invisible even after a relog.
run "kbuildsycoca6 --noincremental >/dev/null 2>&1"

step "5. Krohnkite auto-tiling"
# Dynamic tiling for KWin - the piece that makes Plasma feel like the old
# Hyprland setup instead of a stacking desktop with extra steps.
#
# PINNED, with honest provenance: upstream esjeon/krohnkite is the original but
# has shipped no code since 2022-04-26 and still uses the Plasma 5 packaging
# format (res/metadata.desktop, no X-Plasma-API-Minimum-Version), so it does not
# load on Plasma 6. anametologin/krohnkite is the Plasma 6 port. It was ARCHIVED
# 2025-12-11, so there will be no upstream fixes - accepted deliberately: it is
# a self-contained KWin script with no privileges, no daemon and no network, and
# if it breaks we own the code.
#
# Audited 2026-08-16: no network calls, no eval, no Function constructor, no
# filesystem access, no D-Bus. A changed digest means the release was re-cut and
# must be re-audited before it is installed.
#
# Verified tiling on this machine 2026-08-17. NOTE: `kwin reconfigure` loads the
# script and registers its shortcuts but does NOT start it managing windows -
# testing that way shows no tiling and looks like a total failure. A real relog
# is the only honest test.
KROHNKITE_VER=0.9.9.2
KROHNKITE_SHA=42f7f66531d366c74b5fc860381da3517ccb4cdccd1f80c122fcab6e9a8fcf7e
KROHNKITE_URL="https://github.com/anametologin/krohnkite/releases/download/$KROHNKITE_VER/krohnkite-${KROHNKITE_VER}_1d7fd74.kwinscript"

if [ "$DRY" = 1 ]; then
  printf '  [dry-run] fetch + verify krohnkite %s, kpackagetool6 -t KWin/Script -i\n' "$KROHNKITE_VER"
elif [ -d "$HOME/.local/share/kwin/scripts/krohnkite" ]; then
  echo "   already installed"
else
  tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/k.kwinscript" "$KROHNKITE_URL"
  got=$(sha256sum "$tmp/k.kwinscript" | cut -d' ' -f1)
  if [ "$got" != "$KROHNKITE_SHA" ]; then
    warn "checksum mismatch — refusing to install"
    warn "  expected $KROHNKITE_SHA"
    warn "  got      $got"
    rm -rf "$tmp"; exit 1
  fi
  kpackagetool6 -t KWin/Script -i "$tmp/k.kwinscript" >/dev/null
  rm -rf "$tmp"
  echo "   installed $KROHNKITE_VER"
fi
run "kwriteconfig6 --file kwinrc --group Plugins --key krohnkiteEnabled true"

# Collisions between Krohnkite's defaults and bindings set above, plus two with
# stock Plasma. In every case the incumbent silently wins and Krohnkite's key
# does nothing, which reads exactly like a broken script - it is not.
kro() { run "kwriteconfig6 --file kglobalshortcutsrc --group kwin --key '$1' '$2,$3,$4'"; }

# Meta+T turns tiling OFF, inverting Krohnkite's default, on request
# 2026-08-16: the owner wants one key to escape tiling and reaches for that far
# more often than for re-tiling. Plasma's own Edit Tiles owns Meta+T and has to
# give it up. Both are PER VIRTUAL DESKTOP - turning tiling off on one desktop
# leaves the rest tiled, which looks like a bug until you know it.
run "kwriteconfig6 --file kglobalshortcutsrc --group kwin --key 'Edit Tiles' 'none,Meta+T,Toggle Tiles Editor'"
kro KrohnkiteFloatingLayout "Meta+T"       "none"   "Krohnkite: Floating Layout"
kro KrohnkiteTileLayout     "Meta+Shift+T" "Meta+T" "Krohnkite: Tile Layout"

# Meta+L is stock Lock Session; the owner's vim keys need it for focus-right.
# Lock keeps the dedicated Screensaver key, so nothing is lost.
# printf, not a literal \t: kwriteconfig6 escapes a backslash it is handed, so
# passing \t writes \\t. KConfig wants a real tab as the alternates separator.
run "kwriteconfig6 --file kglobalshortcutsrc --group ksmserver --key 'Lock Session' \"\$(printf 'Screensaver,Screensaver\\tMeta+L,Lock Session')\""

# Meta+F is fullscreen (step 3), so floating moves one key over.
kro KrohnkiteToggleFloat "Meta+Shift+F" "Meta+F"       "Krohnkite: Toggle Float"
kro KrohnkiteFloatAll    "none"         "Meta+Shift+F" "Krohnkite: Float All"

# The terminal keeps Meta+Return.
kro KrohnkiteSetMaster "Meta+Shift+Return" "Meta+Return" "Krohnkite: Set as Master"

# Krohnkite extras that lose to stock bindings — unbound so the clash is not silent.
kro KrohnkiteDecrease "none" "Meta+D" "Krohnkite: Decrease"   # Meta+D = Show Desktop
kro KrohnkiteIncrease "none" "Meta+I" "Krohnkite: Increase"   # Meta+I = System Settings
kro KrohnkiteRotate   "none" "Meta+R" "Krohnkite: Rotate"     # Meta+R = Spectacle

# Float rules: windows that must never be tiled.
#
# MATCHING SEMANTICS, from Krohnkite's own isContain(): a bare word is an exact
# match against resourceClass/resourceName, but a word wrapped in [brackets] is
# a case-insensitive SUBSTRING match. That is what makes one entry cover every
# game.
#
# Every Steam game launches as `steam steam://rungameid/<id>` and gets the
# window class steam_app_<id>, so [steam_app_] catches all of them - including
# games bought later, with no list to maintain. gamescope is the compositor
# wrapper games run under. eldenring.exe is carried over from the old
# hypr/windows.conf, which needed it because Seamless Coop runs outside the
# steam_app_ class.
#
# NOT covered: games launched through lutris or heroic, whose window classes
# vary per title. Both are installed. Add them here as they turn up rather than
# guessing at classes now.
#
# The Steam CLIENT is deliberately left tiling - it is an ordinary window, and
# its popups are already handled by floatUtility.
run "kwriteconfig6 --file kwinrc --group Script-krohnkite --key floatingClass '[steam_app_],gamescope,eldenring.exe,mpv,imv'"
run "kwriteconfig6 --file kwinrc --group Script-krohnkite --key floatUtility true"

# Layout is per virtual desktop, which is Krohnkite's default and the reason
# Meta+T turning tiling off on one desktop leaves the other nine tiled. Set
# explicitly so a future default change cannot silently make the toggle global.
run "kwriteconfig6 --file kwinrc --group Script-krohnkite --key layoutPerDesktop true"

step "6. Meta+Ctrl+<digit> move window to desktop"
# A repo-owned KWin script. See dist/kwin-move-to-desktop/contents/code/main.js
# for the full record of why Meta+Shift+<digit> is impossible here and why this
# is not just a preference for Ctrl.
run "kpackagetool6 -t KWin/Script -u '$HERE/dist/kwin-move-to-desktop' >/dev/null 2>&1 \
     || kpackagetool6 -t KWin/Script -i '$HERE/dist/kwin-move-to-desktop' >/dev/null"
run "kwriteconfig6 --file kwinrc --group Plugins --key move-to-desktopEnabled true"

step "7. display layout (only when the external is connected)"
# Ported from the old hypr/monitors.conf. The layout that matters is that the
# two outputs must not OVERLAP: KWin had HDMI at x=1114 while eDP-1 spanned
# 0..1280, so a 166px-wide strip belonged to both screens and windows bled from
# one display onto the other. Placing HDMI at exactly eDP-1's width makes them
# abut. Fixed and confirmed at the machine 2026-08-19.
#
# eDP-1 is the GPD's portrait panel: 1600x2560 native, Rotated270 for landscape
# use, scale 2 -> a 1280x800 logical desktop. So 1280 is where the external has
# to start. Changing the panel's scale or rotation changes that number.
#
# Position only. Mode and scale are left alone - they are already correct and
# are the kind of thing that is set once in System Settings, not re-asserted on
# every provisioning run.
#
# NOT SET HERE, deliberately: the external's refresh rate. monitors.conf pinned
# 1920x1080@60 with the note that this TV's EDID advertises @100 as preferred
# but flickers on it (out-of-spec timing). The box is currently running @100
# without complaint, so this is left as found rather than silently forced back.
# If flicker appears: kscreen-doctor output.HDMI-A-1.mode.1920x1080@60
if [ "$DRY" = 1 ]; then
  printf '  [dry-run] kscreen-doctor output.HDMI-A-1.position.1280,0 (if connected)\n'
elif kscreen-doctor -o 2>/dev/null | grep -q 'HDMI-A-1'; then
  run "kscreen-doctor output.HDMI-A-1.position.1280,0 >/dev/null 2>&1 || true"
  echo "   HDMI-A-1 placed at 1280,0 (abuts eDP-1, no overlap)"
else
  echo "   external not connected — skipped"
fi

step "8. desktop pager in the bottom panel"
# The pager is what makes 10 virtual desktops usable: without it there is no
# indication of which of the ten you are on, and Meta+<digit> becomes a guess.
#
# This is NOT a config file you can write. Panel contents live in
# plasma-org.kde.plasma.desktop-appletsrc, which plasmashell holds in memory and
# rewrites on exit, so an edit made underneath it is discarded. The supported
# route is the Plasma scripting API over D-Bus, which is what this uses.
#
# Idempotent by asking the running shell what is already there, not by testing
# the config file, for the same reason.
PLASMA_QDBUS=""
for c in qdbus6 qdbus-qt6 qdbus; do have "$c" && { PLASMA_QDBUS="$c"; break; }; done

if [ -z "$PLASMA_QDBUS" ]; then
  warn "no qdbus binary found — add the pager by hand: right-click the panel, Add Widgets, Pager"
elif [ "$DRY" = 1 ]; then
  printf '  [dry-run] add org.kde.plasma.pager to the bottom panel via %s\n' "$PLASMA_QDBUS"
else
  # `index` positions it after the launcher rather than at the far right end,
  # where a pager is useless. Plasma appends by default and the property is not
  # honoured on every version, so this is best-effort: if it lands at the end,
  # drag it once and Plasma remembers.
  "$PLASMA_QDBUS" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
    var report = [];
    var ps = panels();
    for (var i = 0; i < ps.length; i++) {
      var p = ps[i];
      if (String(p.location) != "bottom") continue;
      var ws = p.widgets();
      var has = false;
      for (var j = 0; j < ws.length; j++) {
        if (ws[j].type == "org.kde.plasma.pager") has = true;
      }
      if (has) { report.push("pager already in the bottom panel"); continue; }
      var w = p.addWidget("org.kde.plasma.pager");
      try { w.index = 1; } catch (e) {}
      report.push("pager added to the bottom panel");
    }
    if (report.length == 0) report.push("NO BOTTOM PANEL FOUND - nothing to add the pager to");
    print(report.join("; "));
  ' 2>&1 | sed 's/^/   /'
fi

cat <<EOF

${c_b}Written.${c_0} Two things this script CANNOT do for you:

${c_y}1. Log out and back in.${c_0} Global shortcuts are read only when KWin starts —
   \`reconfigure\` does not reload them. The bindings above are inert until then.

${c_y}2. Turn on rotation properly (Pocket 4).${c_0} System Settings ->
   Display Configuration -> Orientation: Automatic, and UNTICK
   "Only when in tablet mode". That checkbox is why rotation silently never
   fires: this hardware reports tabletMode=false forever (Lid Switch, no tablet
   switch). It cannot be scripted — KWin rewrites kwinoutputconfig.json on exit
   and discards outside edits.
EOF
