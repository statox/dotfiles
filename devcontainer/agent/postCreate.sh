#!/bin/bash
set -euo pipefail

# ~/.claude is a persistent named volume (holds session state, projects/,
# shell-snapshots/, etc.). The dotfiles-managed config files are symlinked
# in on every container creation so host <-> container edits stay live in
# both directions.
CLAUDE_HOME="$HOME/.claude"
DOTFILES_CLAUDE="$HOME/.dotfiles/claude"

mkdir -p "$CLAUDE_HOME"

# ~/.claude/skills is the one dotfiles-managed entry that's a directory
# rather than a plain file. If it already exists as a real directory (e.g.
# a skill created directly inside a container before this symlink existed),
# `ln -sf <dir> <existing-dir>` below would nest a symlink inside it instead
# of replacing it. Dotfiles always win: clear out a real directory first.
if [ -d "$CLAUDE_HOME/skills" ] && [ ! -L "$CLAUDE_HOME/skills" ]; then
    rm -rf "$CLAUDE_HOME/skills"
fi

if [ -d "$DOTFILES_CLAUDE" ]; then
    for f in "$DOTFILES_CLAUDE"/*; do
        # -n: CLAUDE_HOME lives in a volume shared by every repo's container,
        # so on the second and later container creations this symlink already
        # exists. Without -n, `ln -sf` would dereference an existing
        # symlink-to-directory and nest the new link inside it instead of
        # replacing it - which is how a stray `skills/skills` symlink ended up
        # created inside the dotfiles-managed skills/ directory itself.
        ln -sfn "$f" "$CLAUDE_HOME/$(basename "$f")"
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

# Install the Claude Code plugins declared in plugins.json (tracked in this
# dotfiles repo) idempotently, on every container creation. Marketplaces are
# matched by GitHub source ("owner/repo"); plugins by their installed "id"
# ("name@marketplace"). Already-added marketplaces / already-installed
# plugins are skipped, so re-running this is a no-op except for anything new
# added to plugins.json since the last container creation.
PLUGINS_FILE="$DOTFILES_CLAUDE/plugins.json"
if [ -f "$PLUGINS_FILE" ] && command -v claude >/dev/null 2>&1; then
    known_marketplaces="$(claude plugin marketplace list --json 2>/dev/null || echo '[]')"
    while IFS= read -r marketplace; do
        [ -n "$marketplace" ] || continue
        echo "$known_marketplaces" | jq -e --arg src "$marketplace" \
            'any(.[]; .repo == $src)' >/dev/null \
            || claude plugin marketplace add "$marketplace"
    done < <(jq -r '.marketplaces[]' "$PLUGINS_FILE")

    installed_plugins="$(claude plugin list --json 2>/dev/null || echo '[]')"
    while IFS= read -r plugin; do
        [ -n "$plugin" ] || continue
        echo "$installed_plugins" | jq -e --arg id "$plugin" \
            'any(.[]; .id == $id)' >/dev/null \
            || claude plugin install "$plugin" --scope user
    done < <(jq -r '.plugins[]' "$PLUGINS_FILE")
fi
