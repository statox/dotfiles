#!/bin/bash
set -euo pipefail

TYPE="${1:-info}"
MESSAGE="${2:-}"
SOCK=/run/broker/notify.sock

command -v socat >/dev/null 2>&1 || exit 0
[ -S "$SOCK" ] || exit 0

printf '%s|%s\n' "$TYPE" "$MESSAGE" | socat - "UNIX-CONNECT:${SOCK}" >/dev/null 2>&1 || true
