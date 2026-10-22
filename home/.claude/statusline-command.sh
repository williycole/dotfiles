#!/usr/bin/env bash
input=$(cat)

SEP=" │ "

make_bar() {
  local pct=$1
  local fill="${2:-█}"
  local empty="${3:-░}"
  local width=8
  local filled=$(awk "BEGIN { printf \"%.0f\", ($pct / 100) * $width }")
  local bar=""
  for ((i=0; i<filled; i++)); do bar="${bar}${fill}"; done
  for ((i=filled; i<width; i++)); do bar="${bar}${empty}"; done
  printf "%s" "$bar"
}


# Elapsed time
transcript=$(echo "$input" | jq -r '.transcript_path // empty')
elapsed=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  start_ts=$(head -1 "$transcript" | jq -r '.timestamp // empty' 2>/dev/null)
  if [ -n "$start_ts" ]; then
    now=$(date +%s)
    start=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${start_ts%%.*}" "+%s" 2>/dev/null || date -d "$start_ts" +%s 2>/dev/null)
    if [ -n "$start" ]; then
      diff=$(( now - start ))
      mins=$(( diff / 60 ))
      secs=$(( diff % 60 ))
      elapsed="${mins}m${secs}s"
    fi
  fi
fi
[ -z "$elapsed" ] && elapsed=""

# Cost — the value Claude Code already computes (accounts for cache + plan)
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0' | awk '{printf "$%.2f", $1}')

# Context window % bar — Claude Code doesn't emit context tokens to the
# statusline, so derive them from the transcript's last main-chain assistant
# usage: input + cache_creation + cache_read = tokens currently in the window.
# ponytail: 1M detected from model id OR settings model OR used>200k — one knob.
ctx_display=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  ctx_used=$(tail -n 500 "$transcript" | jq -s '
    [ .[] | select(.isSidechain != true) | .message.usage
      | select(. != null)
      | (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0) ]
    | last // 0' 2>/dev/null)
  model_id=$(echo "$input" | jq -r '.model.id // empty')
  settings_model=$(jq -r '.model // empty' "$HOME/.claude/settings.json" 2>/dev/null)
  ctx_max=200000
  echo "$model_id $settings_model" | grep -qi '1m' && ctx_max=1000000
  [ -n "$ctx_used" ] && [ "$ctx_used" -gt 200000 ] && ctx_max=1000000
  if [ -n "$ctx_used" ] && [ "$ctx_used" -gt 0 ]; then
    ctx_pct=$(awk "BEGIN { printf \"%.0f\", ($ctx_used / $ctx_max) * 100 }")
    ctx_k=$(awk "BEGIN { printf \"%.0f\", $ctx_used/1000 }")
    ctx_maxk=$(awk "BEGIN { printf \"%.0f\", $ctx_max/1000 }")
    ctx_display="ctx $(make_bar $ctx_pct "▰" "▱") ${ctx_pct}% ${ctx_k}k/${ctx_maxk}k"
  fi
fi

# Plan quota % bar + reset time
used_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
if [ -n "$used_pct" ]; then
  remaining=$(printf "%.0f" "$used_pct")
  bar=$(make_bar "$remaining")
  if [ -n "$resets_at" ]; then
    reset_time=$(date -r "$resets_at" "+%I:%M%p" 2>/dev/null || date -d "@$resets_at" "+%I:%M%p" 2>/dev/null)
    plan="quota ${bar} ${remaining}% ↺${reset_time}"
  else
    plan="quota ${bar} ${remaining}%"
  fi
else
  plan=""
fi

# MCP server count from settings
mcp_count=0
for settings_file in "$HOME/.claude/settings.json" "$HOME/.claude/settings.local.json"; do
  if [ -f "$settings_file" ]; then
    n=$(python3 -c "import json,sys; d=json.load(open('$settings_file')); print(len(d.get('mcpServers', {})))" 2>/dev/null)
    mcp_count=$(( mcp_count + ${n:-0} ))
  fi
done
mcp_display=""
[ "$mcp_count" -gt 0 ] && mcp_display="MCPs: ${mcp_count}"

# Diff stats — one unfiltered number, scoped to work in flight.
# jj repo: `jj diff` = current change (@) vs its parent. Git HEAD is parked at @-
# under jj, so git-side branch math reads the whole stack — hence the jj branch.
# Plain git repo: uncommitted tracked changes vs HEAD.
diff_stats=""
if jj root &>/dev/null; then
  line=$(jj diff --stat 2>/dev/null | tail -1)
else
  line=$(git diff --shortstat HEAD 2>/dev/null)
fi
ins=$(echo "$line" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+'); [ -z "$ins" ] && ins=0
del=$(echo "$line" | grep -oE '[0-9]+ deletion'  | grep -oE '[0-9]+'); [ -z "$del" ] && del=0
if [ "$ins" -gt 0 ] || [ "$del" -gt 0 ]; then
  diff_stats="+${ins} -${del}"
fi

# Assemble — skip empty segments
parts=("$cost")
[ -n "$elapsed" ] && parts=("$elapsed" "$cost")
[ -n "$ctx_display" ] && parts+=("$ctx_display")
[ -n "$plan" ] && parts+=("$plan")
[ -n "$mcp_display" ] && parts+=("$mcp_display")
[ -n "$diff_stats" ] && parts+=("$diff_stats")

output=""
for part in "${parts[@]}"; do
  if [ -z "$output" ]; then
    output="$part"
  else
    output="${output}${SEP}${part}"
  fi
done

printf "%s" "$output"
