#!/bin/sh
#
# Claude Code status line: context usage, model, directory, branch, and — only when one
# is close to biting — a subscription rate limit.
#
# Claude Code pipes the session's state in as JSON on stdin. The fields read below are a
# small part of it; `claude`'s statusline setup agent documents the full shape.

command -v jq >/dev/null || {
  printf 'statusline: jq not found'
  exit 0
}

input=$(cat)

# A single jq pass for everything the line needs, one value per line, in this order.
{
  read -r used
  read -r pct
  read -r rate_5h
  read -r rate_7d
  read -r model
  read -r dir
} <<EOF
$(printf '%s' "$input" | jq -r '
  .context_window.total_input_tokens // 0,
  (.context_window.used_percentage // 0 | floor),
  (.rate_limits.five_hour.used_percentage // 0 | floor),
  (.rate_limits.seven_day.used_percentage // 0 | floor),
  .model.id // "",
  (.workspace.current_dir // .cwd)
')
EOF

# `claude-opus-5[1m]` -> `opus-5[1m]`, `claude-haiku-4-5-20251001` -> `haiku 4.5`.
model=$(printf '%s' "$model" | sed 's/^claude-//; s/-[0-9]\{8\}$//; s/-\([0-9]\)-\([0-9]\)/ \1.\2/')

short_dir=${dir##*/}
branch=$(git -C "$dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)

fmt_tokens() {
  n=$1
  if [ "$n" -ge 1000000 ]; then
    printf '%d.%dm' $((n / 1000000)) $(((n / 100000) % 10))
  elif [ "$n" -ge 10000 ]; then
    printf '%dk' $((n / 1000))
  elif [ "$n" -ge 1000 ]; then
    printf '%d.%dk' $((n / 1000)) $(((n / 100) % 10))
  else
    printf '%d' "$n"
  fi
}

ESC=$(printf '\033')
DIM="${ESC}[2m"
RESET="${ESC}[0m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
RED="${ESC}[31m"

# Deliberately absolute rather than a share of the context window. Answers degrade past
# roughly 150-200k tokens whatever the window's capacity, so these are the numbers worth
# reacting to — yellow is "wrap this up", red is "/clear, /compact, or /handoff now".
if [ "$used" -ge 200000 ]; then
  ctx_color=$RED
elif [ "$used" -ge 100000 ]; then
  ctx_color=$YELLOW
else
  ctx_color=$GREEN
fi

# Icons are nerd-font glyphs, written as octal so the file stays POSIX and legible.
SEP="${DIM}$(printf '\342\224\202')${RESET}"
ICON_CTX=$(printf '\357\213\233')
ICON_MODEL=$(printf '\357\206\262')
ICON_DIR=$(printf '\357\201\274')
ICON_BRANCH=$(printf '\356\234\245')
ICON_RATE=$(printf '\357\200\227')

line="${ctx_color}${ICON_CTX} $(fmt_tokens "$used")${RESET} ${DIM}${pct}%${RESET}"

if [ -n "$model" ]; then
  line="${line} ${SEP} ${DIM}${ICON_MODEL} ${model}${RESET}"
fi

line="${line} ${SEP} ${DIM}${ICON_DIR} ${short_dir}${RESET}"

if [ -n "$branch" ]; then
  line="${line} ${SEP} ${DIM}${ICON_BRANCH} ${branch}${RESET}"
fi

# A subscription limit only earns space on the line once it is close enough to interrupt
# a task. Below the warning mark it stays off entirely.
RATE_WARN=80
RATE_CRIT=95

append_rate() {
  [ "$2" -ge "$RATE_WARN" ] || return 0
  if [ "$2" -ge "$RATE_CRIT" ]; then
    rate_color=$RED
  else
    rate_color=$YELLOW
  fi
  line="${line} ${SEP} ${rate_color}${ICON_RATE} $1 $2%${RESET}"
}

append_rate 5h "$rate_5h"
append_rate 7d "$rate_7d"

printf '%s' "$line"
