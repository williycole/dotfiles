#!/bin/bash
# Read Claude replies aloud (macOS or Linux). Driven by the /say commands.
#
#   say-reply.sh            Stop-hook mode: stdin JSON. Saves the cleaned reply to
#                           <scratchpad>/say-last.txt. If ~/.claude/.say-on exists,
#                           queues the trailing "🔊 ..." summary line (or the whole
#                           reply when absent), prefixed with the repo name.
#   say-reply.sh --prompt   UserPromptSubmit-hook mode: if auto-read is on, tell
#                           Claude to end its reply with a 🔊 line. Never cuts speech.
#   say-reply.sh --last F   Flush the queue and speak file F now.
#   say-reply.sh --test     Speak a fixed phrase through the full path, ignoring gates.
#   say-reply.sh --stop     Flush the queue, cut off speech.
#   say-reply.sh --on|--off Toggle automatic reading (global).
#   say-reply.sh --quiet    Toggle mute for THIS Herdr pane only (human decision; no
#                           skill should call it).
#
# Silent on purpose: `claude -p` runs (CLAUDE_CODE_ENTRYPOINT != cli), SAY_QUIET=1,
# a pane toggled quiet, auto-read off, or an empty message with nothing recoverable
# from the transcript. Every decision is one line in ~/.claude/say.log.
#
# Playback, macOS: render with `say -o` to an AIFF, verify it has length, then
# `afplay`. A failed or empty render means speechsynthesisd is wedged (a known
# macOS state where `say` exits 0 and plays nothing); restart it and render once
# more. The text gets a leading [[slnc]] pause so a sleeping Bluetooth headset
# wakes on silence, not on the first words.
# Playback, Linux: `espeak-ng -w` to a WAV (22050 Hz mono 16-bit, so its length is
# plain byte math, no probe tool), then `paplay` (PipeWire's pulse shim). The
# headset-wake pause is a burst of raw silence through the sink before the words.
# espeak-ng is the stopgap voice: robotic but dependency-free. piper is the
# upgrade when a model download is worth permitting.
# Concurrent sessions take turns via a pid-owned lock dir on both.
ON="$HOME/.claude/.say-on"
MARK="🔊"
# A hotkey tool (Karabiner) runs --stop with a bare env: no TMPDIR. Resolve the
# same per-user temp dir the hooks use, or the lock and temp files are missed.
[ -n "$TMPDIR" ] || TMPDIR=$(getconf DARWIN_USER_TEMP_DIR 2>/dev/null || echo /tmp/)
LOCK="${TMPDIR:-/tmp}/say-reply.lock"
QUIET_DIR="$HOME/.claude/say-quiet"
LOG="$HOME/.claude/say.log"
RATE=220
VOICE="Ava (Premium)"   # macOS; Linux picks its voice via PIPER_VOICE
PAUSE_MS=1200

log() {
  printf '%s %-22s %s\n' "$(date '+%m-%d %H:%M:%S')" "${HERDR_PANE_ID:-nopane}" "$*" >> "$LOG"
  # Keep the log bounded: past 2000 lines, keep the newest 500.
  if [ "$(wc -l < "$LOG")" -gt 2000 ]; then tail -500 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"; fi
}

# Waiter body, detached in its own process group (set -m) so it outlives the hook
# process the harness reaps. $1 text file, $2 lock dir, $3 log file, $4 rate, $5 pause ms, $6 macOS voice.
WAITER='
tag="${HERDR_PANE_ID:-nopane}"; logf="$3"; rate="$4"; pause="$5"; voice="$6"
lg() { printf "%s %-22s %s\n" "$(date "+%m-%d %H:%M:%S")" "$tag" "$*" >> "$logf"; }
until mkdir "$2" 2>/dev/null; do
  p=$(cat "$2/pid" 2>/dev/null); if [ -n "$p" ] && ! kill -0 "$p" 2>/dev/null; then rm -rf "$2"; fi
  sleep 0.2
done
echo $$ > "$2/pid"
txt=$(mktemp "${TMPDIR:-/tmp}/say-txt.XXXXXX"); snd="$txt.snd"
trap "rm -f \"$txt\" \"$snd\"; rm -rf \"$2\"" EXIT
trap "exit 143" TERM INT   # a trap that only cleans up would let the waiter run on after --stop
if [ "$(uname)" = Darwin ]; then
  { printf "[[slnc %s]] " "$5"; cat "$1"; } > "$txt"
  render() { say -v "$voice" -r "$rate" -o "$snd" -f "$txt" 2>/dev/null; rc=$?; dur=$(afinfo "$snd" 2>/dev/null | awk "/estimated duration/{print \$3}"); dur=${dur:-0}; }
  play() { afplay "$snd"; }
  unwedge() { pkill -x speechsynthesisd 2>/dev/null; sleep 0.6; }
else
  cat "$1" > "$txt"
  export PATH="$HOME/.local/bin:$PATH"
  # piper (neural, sounds like a person) when the tool and a voice are present;
  # espeak-ng otherwise. install-packages fetches the voice; PIPER_VOICE picks it.
  voice=""; v="$HOME/.local/share/piper/voices/${PIPER_VOICE:-en_US-amy-medium}.onnx"
  command -v piper >/dev/null 2>&1 && [ -s "$v" ] && [ -s "$v.json" ] && voice="$v"
  engine=${voice:+piper}; engine=${engine:-espeak}
  # Duration from the WAV header (rate x channels x bits/8 = bytes/sec), ceiled so
  # a one-word reply still counts as 1s instead of being dropped as a failed render.
  wavdur() { b=$(stat -c %s "$snd" 2>/dev/null || echo 0); r=$(od -An -tu4 -j24 -N4 "$snd" 2>/dev/null | tr -d " "); c=$(od -An -tu2 -j22 -N2 "$snd" 2>/dev/null | tr -d " "); w=$(od -An -tu2 -j34 -N2 "$snd" 2>/dev/null | tr -d " "); bps=$(( ${r:-22050} * ${c:-1} * ${w:-16} / 8 )); dur=$(( b > 44 ? (b - 44 + bps - 1) / bps : 0 )); }
  render() { if [ -n "$voice" ]; then piper -m "$voice" -f "$snd" < "$txt" >/dev/null 2>&1; rc=$?; else espeak-ng -v en-us -s "$rate" -w "$snd" -f "$txt" 2>/dev/null; rc=$?; fi; wavdur; }
  play() { head -c $(( 44100 * pause / 1000 )) /dev/zero | paplay --raw --rate=22050 --channels=1 --format=s16le 2>/dev/null; paplay "$snd"; }
  unwedge() { sleep 0.6; }
fi
render
if [ "$rc" != 0 ] || [ "${dur%.*}" -lt 1 ]; then
  lg "render failed rc=$rc dur=$dur; retrying"
  unwedge; render
fi
if [ "$rc" = 0 ] && [ "${dur%.*}" -ge 1 ]; then
  play; prc=$?; lg "played dur=${dur}s play=$prc engine=${engine:-say}"
else
  lg "GAVE UP rc=$rc dur=$dur"
fi'
enqueue() { bash -c 'set -m; nohup bash -c "$1" say-queue "$2" "$3" "$4" "$5" "$6" "$7" >/dev/null 2>&1 &' _ "$WAITER" "$1" "$LOCK" "$LOG" "$RATE" "$PAUSE_MS" "$VOICE"; }
flush()   { pkill -f ' say-queue ' 2>/dev/null; pkill -x afplay 2>/dev/null; pkill -x say 2>/dev/null; pkill -x paplay 2>/dev/null; pkill -x espeak-ng 2>/dev/null; rm -rf "$LOCK" "${TMPDIR:-/tmp}"/say-txt.* "${TMPDIR:-/tmp}"/say-test.*; }
clean()   { awk '/^```/{f=!f; next} !f' | sed -E "s/$MARK//g; s/\`[^\`]*\`/code/g; s/\[([^]]*)\]\([^)]*\)/\1/g; s/[*_#>|~]//g"; }

# Last non-empty assistant text in the transcript, for when the hook payload is blank.
# The file can lag the turn, so try a few times.
from_transcript() {
  local t="$1" i out
  [ -s "$t" ] || return 1
  for i in 1 2 3 4; do
    out=$(jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text' "$t" 2>/dev/null | awk 'NF{last=$0} END{print last}')
    [ -n "$out" ] && { printf '%s' "$out"; return 0; }
    sleep 0.5
  done
  return 1
}

case "$1" in
  --stop)  flush; log "stop"; exit 0 ;;
  --on)    touch "$ON"; log "auto-read on"; echo "auto-read on"; exit 0 ;;
  --off)   rm -f "$ON"; log "auto-read off"; echo "auto-read off"; exit 0 ;;
  --quiet)
    [ -n "$HERDR_PANE_ID" ] || { echo "not in a Herdr pane, nothing to toggle"; exit 0; }
    mkdir -p "$QUIET_DIR"
    if [ -e "$QUIET_DIR/$HERDR_PANE_ID" ]; then rm -f "$QUIET_DIR/$HERDR_PANE_ID"; log "pane unmuted"; echo "this pane speaks again"
    else touch "$QUIET_DIR/$HERDR_PANE_ID"; log "pane muted"; echo "this pane is muted (run again to unmute)"; fi
    exit 0 ;;
  --test)
    flush; f=$(mktemp "${TMPDIR:-/tmp}/say-test.XXXXXX")
    printf 'Read aloud test from %s. If you hear this, the audio path works.\n' "$(basename "$PWD")" > "$f"
    log "test enqueued"; enqueue "$f"; echo "speaking a test line; see $LOG"; exit 0 ;;
  --last)  flush; [ -s "$2" ] && { log "on-demand $(wc -c < "$2" | tr -d ' ')c"; enqueue "$2"; } || echo "no saved reply at $2"; exit 0 ;;
  --prompt)
    [ -e "$ON" ] && jq -n --arg m "$MARK" '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:("Read-aloud is on. End your reply with one final line starting with " + $m + " followed by a 1-3 sentence plain-English spoken summary: conversational, no jargon, no markdown, no code. That line is what gets spoken.")}}'
    exit 0 ;;
esac

# ---- Stop-hook mode ----
in=$(cat)
msg=$(printf '%s' "$in" | jq -r '.last_assistant_message // empty')
dir=$(printf '%s' "$in" | jq -r '.scratchpad_dir // empty'); [ -d "$dir" ] || dir="$HOME/.claude"
if [ -z "$msg" ]; then
  msg=$(from_transcript "$(printf '%s' "$in" | jq -r '.transcript_path // empty')") || { log "skip: empty message, transcript had nothing"; exit 0; }
  log "payload empty; recovered from transcript"
fi
printf '%s\n' "$msg" | clean > "$dir/say-last.txt"
[ -e "$ON" ] || { log "skip: auto-read off"; exit 0; }
[ "${CLAUDE_CODE_ENTRYPOINT:-cli}" = cli ] || { log "skip: entrypoint $CLAUDE_CODE_ENTRYPOINT"; exit 0; }
[ "${SAY_QUIET:-0}" = 1 ] && { log "skip: SAY_QUIET"; exit 0; }
[ -n "$HERDR_PANE_ID" ] && [ -e "$QUIET_DIR/$HERDR_PANE_ID" ] && { log "skip: pane muted"; exit 0; }
name=$(basename "$(printf '%s' "$in" | jq -r '.cwd // empty')")
tldr=$(printf '%s\n' "$msg" | grep "^$MARK" | tail -1 | clean)
kind=tldr; [ -n "$tldr" ] || { tldr=$(cat "$dir/say-last.txt"); kind=full; }
printf '%s. %s\n' "$name" "$tldr" > "$dir/say-tldr.txt"
log "enqueue $kind $(wc -c < "$dir/say-tldr.txt" | tr -d ' ')c"
enqueue "$dir/say-tldr.txt"
exit 0
