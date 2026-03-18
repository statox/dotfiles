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
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
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

# --- short cwd ---
short_cwd=$(echo "$cwd" | awk -F'/' '{
    n=NF; parts="";
    start = n-2 > 0 ? n-2 : 1;
    for(i=start; i<=n; i++) {
        if(parts != "") parts = parts "/" $i;
        else parts = $i;
    }
    print parts
}')
short_cwd=$(echo "$short_cwd" | sed "s|^$(echo "$HOME" | sed 's|/|\\/|g')|~|")

# --- context bar ---
BAR_WIDTH=10
filled=$(( used_pct * BAR_WIDTH / 100 ))
empty=$(( BAR_WIDTH - filled ))
bar=""
[ "$filled" -gt 0 ] && printf -v f "%${filled}s" && bar="${f// /▓}"
[ "$empty"  -gt 0 ] && printf -v e "%${empty}s"  && bar="${bar}${e// /░}"

# --- assemble ---
parts=()

# cwd
parts+=("${ORANGE}${short_cwd}${RESET}")

# git: branch + staged/modified + lines added/removed
if [ -n "$branch" ]; then
    git_info="${DIM}${branch}${RESET}"
    [ "$staged"   -gt 0 ] && git_info+=" ${GREEN}+${staged}${RESET}"
    [ "$modified" -gt 0 ] && git_info+=" ${YELLOW}~${modified}${RESET}"
    if [ "$lines_added" -gt 0 ] || [ "$lines_removed" -gt 0 ]; then
        git_info+=" ${GREEN}+${lines_added}${RESET}${DIM}/${RESET}${RED}-${lines_removed}${RESET}"
    fi
    parts+=("$git_info")
elif [ "$lines_added" -gt 0 ] || [ "$lines_removed" -gt 0 ]; then
    parts+=("${GREEN}+${lines_added}${RESET}${DIM}/${RESET}${RED}-${lines_removed}${RESET}")
fi

# context bar + stats
ctx_info="${DIM}${bar} ${used_pct}%"
[ -n "$remaining" ]    && ctx_info+=" (${remaining}% free)"
[ -n "$input_tokens" ] && ctx_info+=" · ${input_tokens}tok"
ctx_info+="${RESET}"
parts+=("$ctx_info")

# cost
if [ -n "$cost" ] && [ "$(echo "$cost > 0" | bc -l 2>/dev/null)" = "1" ]; then
    parts+=("${DIM}\$$(printf '%.4f' "$cost")${RESET}")
fi

# model
[ -n "$model" ] && parts+=("${DIM}${model}${RESET}")

line=""
for i in "${!parts[@]}"; do
    [ "$i" -gt 0 ] && line+="  "
    line+="${parts[$i]}"
done
echo "$line"
