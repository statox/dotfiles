#!/bin/bash
set -euo pipefail

# ~/.claude is a persistent named volume (holds session state, projects/,
# shell-snapshots/, etc.). The dotfiles-managed config files are symlinked
# in on every container creation so host <-> container edits stay live in
# both directions.
CLAUDE_HOME="$HOME/.claude"
DOTFILES_CLAUDE="$HOME/.dotfiles/claude"

mkdir -p "$CLAUDE_HOME"

if [ -d "$DOTFILES_CLAUDE" ]; then
    for f in "$DOTFILES_CLAUDE"/*; do
        ln -sf "$f" "$CLAUDE_HOME/$(basename "$f")"
    done
fi

# Merge the dotfiles-tracked mcpServers config into ~/.claude.json (a
# bind-mounted file, not part of the symlink loop above) without touching
# any of its other content. Idempotent: safe to re-run on every container
# creation, and any server keys present in mcp-servers.json always win over
# a stale entry left in ~/.claude.json from a previous run.
MCP_SERVERS_FILE="$DOTFILES_CLAUDE/mcp-servers.json"
CLAUDE_JSON="$HOME/.claude.json"
if [ -f "$MCP_SERVERS_FILE" ]; then
    [ -f "$CLAUDE_JSON" ] || echo '{}' > "$CLAUDE_JSON"
    # ~/.claude.json is a bind mount (devcontainer.json), i.e. a mount point
    # in this container's mount namespace. `mv`/rename(2) onto a mount point
    # fails with EBUSY ("Device or resource busy") since it would require
    # detaching the mount. Overwrite the file's contents in place instead of
    # replacing the inode.
    jq --slurpfile mcp "$MCP_SERVERS_FILE" \
        '.mcpServers = ((.mcpServers // {}) + $mcp[0])' \
        "$CLAUDE_JSON" > "$CLAUDE_JSON.tmp"
    cat "$CLAUDE_JSON.tmp" > "$CLAUDE_JSON"
    rm "$CLAUDE_JSON.tmp"
fi

# typescript-language-server backs the "typescript" MCP server
# (claude/mcp-servers.json), which runs mcp-language-server as a local stdio
# process against /workdir. Installed here rather than in agent/Dockerfile
# because npm only exists after the node feature is layered onto the image.
command -v typescript-language-server >/dev/null 2>&1 || npm install -g typescript typescript-language-server
