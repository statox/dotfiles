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
