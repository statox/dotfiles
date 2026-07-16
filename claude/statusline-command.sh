#!/bin/bash
# Claude Code status line

input=$(cat)

# --- colors ---
ORANGE=$'\033[38;5;202m'
GREEN=$'\033[38;5;71m'
YELLOW=$'\033[33m'
RED=$'\033[38;5;167m'
DIM=$'\033[2m'
RESET=$'\033[0m'

# --- session data ---
model=$(echo "$input" | jq -r '.model.display_name // ""')
effort=$(echo "$input" | jq -r '.effort.level // empty')
thinking=$(echo "$input" | jq -r '.thinking.enabled // false')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
repo_owner=$(echo "$input" | jq -r '.workspace.repo.owner // empty')
repo_name=$(echo "$input" | jq -r '.workspace.repo.name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# --- git ---
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
    staged=$(git -C "$cwd" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    modified=$(git -C "$cwd" diff --numstat 2>/dev/null | wc -l | tr -d ' ')
else
    branch="" staged="" modified=""
fi

# --- context bar ---
BAR_WIDTH=10
filled=$(( used_pct * BAR_WIDTH / 100 ))
empty=$(( BAR_WIDTH - filled ))
bar=""
[ "$filled" -gt 0 ] && printf -v f "%${filled}s" && bar="${f// /▓}"
[ "$empty"  -gt 0 ] && printf -v e "%${empty}s"  && bar="${bar}${e// /░}"

# --- assemble ---
parts=()

# repo (owner/name), shown only when workspace.repo is defined - cwd itself is
# always /workdir in the container so it's not worth displaying
[ -n "$repo_owner" ] && [ -n "$repo_name" ] && parts+=("${ORANGE}${repo_owner}/${repo_name}${RESET}")

# git: branch + staged/modified
if [ -n "$branch" ]; then
    git_info="${DIM}${branch}${RESET}"
    [ "$staged"   -gt 0 ] && git_info+=" ${GREEN}+${staged}${RESET}"
    [ "$modified" -gt 0 ] && git_info+=" ${YELLOW}~${modified}${RESET}"
    parts+=("$git_info")
fi

# context bar + stats
ctx_info="${DIM}${bar} ${used_pct}%"
[ -n "$input_tokens" ] && ctx_info+=" · ${input_tokens}tok"
ctx_info+="${RESET}"
parts+=("$ctx_info")

# session stats: cost + duration + lines added/removed
session_info=""
if [ -n "$cost" ] && [ "$(echo "$cost > 0" | bc -l 2>/dev/null)" = "1" ]; then
    session_info+="\$$(printf '%.4f' "$cost")"
fi
if [ -n "$duration_ms" ] && [ "$duration_ms" -gt 0 ]; then
    total_sec=$(( duration_ms / 1000 ))
    duration_str=$(printf '%dm%02ds' "$(( total_sec / 60 ))" "$(( total_sec % 60 ))")
    [ -n "$session_info" ] && session_info+=" "
    session_info+="${duration_str}"
fi
if [ "$lines_added" -gt 0 ] || [ "$lines_removed" -gt 0 ]; then
    [ -n "$session_info" ] && session_info+=" "
    session_info+="${RESET}${GREEN}+${lines_added}${RESET}${DIM}/${RESET}${RED}-${lines_removed}${RESET}${DIM}"
fi
[ -n "$session_info" ] && parts+=("${DIM}${session_info}${RESET}")

# model + effort/thinking levels
if [ -n "$model" ]; then
    model_info="$model"
    extra=""
    [ -n "$effort" ] && extra="$effort"
    if [ "$thinking" = "true" ]; then
        [ -n "$extra" ] && extra+=", "
        extra+="thinking"
    fi
    [ -n "$extra" ] && model_info+=" (${extra})"
    parts+=("${DIM}${model_info}${RESET}")
fi

line=""
for i in "${!parts[@]}"; do
    [ "$i" -gt 0 ] && line+="  "
    line+="${parts[$i]}"
done
echo "$line"
