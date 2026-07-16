# VS Code Claude Code extension inside the confined agent container — Design

## Goal

Let the VS Code Claude Code extension run confined inside the existing per-repo `agent`
devcontainer (see `2026-07-14-devcontainer-setup-design.md`), instead of on the bare host, without
changing the container/broker architecture.

## Chosen approach: attach to the running container

Rejected the native "Reopen in Container" flow (would require a per-repo `.devcontainer` pointer
file plus an `initializeCommand` to bring up the broker, since VS Code's Dev Containers extension
looks for config inside the workspace folder, not `~/.dotfiles/devcontainer/`). Instead, reuse the
existing CLI-driven lifecycle verbatim and have VS Code attach to the container it already creates:

1. The existing `claude-devcontainer` script (or the new `code-devcontainer` below) brings up the
   broker and the per-repo `agent` container exactly as today.
2. VS Code's Dev Containers extension attaches to that already-running container. Because the
   container was created by `@devcontainers/cli up`, it already carries the
   `devcontainer.local_folder` label the CLI itself uses to find/reuse containers — the same label
   VS Code reads for its own attach flow, so no extra tagging is needed.
3. Once attached, the Claude Code extension installs and runs **inside** the container (VS Code
   Server is remote), so it is exactly as confined as the CLI — no direct host access, same broker
   path for anything that needs it.

This adds zero new moving parts to the container/broker architecture itself — the only additions
are one persisted volume and one convenience script.

## Changes

### 1. `devcontainer.json` — persist VS Code Server + extensions

Add one more named volume, alongside the existing `claude-home`/`glab-config`/`broker-sock`:

```json
"source=vscode-server,target=/home/dev/.vscode-server,type=volume"
```

Without this, VS Code Server and installed extensions (Claude Code included) would reinstall from
scratch every time the agent container is recreated (`claude-devcontainer-rebuild`, or a plain
`claude-devcontainer` run after the container was removed). Global volume (not per-repo), matching
the existing pattern for `claude-home`/`glab-config`.

### 2. New script: `scripts/code-devcontainer`

Mirrors `claude-devcontainer`'s bootstrap (NVM/npx setup, `.claude.json`/`.venv-claude`
bootstrapping, bring up the broker, `devcontainers/cli up` for the current workspace folder), but
instead of `exec`-ing a shell, it opens VS Code attached to the container directly:

```sh
CONTAINER_ID="$(docker ps -q --filter "label=devcontainer.local_folder=${WORKSPACE_FOLDER}")"
CONTAINER_NAME="$(docker inspect -f '{{.Name}}' "$CONTAINER_ID")"   # includes leading "/"
HEX="$(printf '{"containerName":"%s"}' "$CONTAINER_NAME" | xxd -p | tr -d '\n')"
exec code --folder-uri "vscode-remote://attached-container+${HEX}/workdir"
```

The script carries a comment flagging that the `attached-container+<hex>` URI scheme is an
**undocumented, internal VS Code implementation detail** (reverse-engineered from community blog
posts, not from official docs), so it may break across VS Code updates. The documented, stable
fallback (Command Palette → "Dev Containers: Attach to Running Container…" → pick the repo's
container → Open Folder → `/workdir`) is called out in both the script comment and the README, so
the workflow degrades gracefully if the URI trick ever stops working.

### 3. Alias

Add `code-devcontainer` next to the existing `claude` alias in `bash_aliases`.

### 4. `README.md`

New section documenting the VS Code workflow: what `code-devcontainer` does, that the extension
runs confined inside the container exactly like the CLI, the manual fallback attach steps, and a
note on the new `vscode-server` volume under "Architecture".

## Repeated invocation (same directory, twice)

Running `code-devcontainer` (or `claude`) twice against the same repo does **not** create a second
container: `@devcontainers/cli up` is idempotent — it looks up any existing container via the
`devcontainer.local_folder` label before creating one, and reuses it if found (already true of
`claude-devcontainer` today). The second `code-devcontainer` run resolves the same container ID and
opens a second VS Code window attached to it. VS Code supports multiple separate windows attached
to the same container concurrently (confirmed against VS Code's own "Connect to multiple
containers" docs), so the result is one container, two windows — analogous to two shells into the
same container. No port/identity conflicts.

## Non-goals

- Native "Reopen in Container" support (symlinked `.devcontainer`, `initializeCommand` for the
  broker) — not built, per the chosen approach above. Could be revisited later if the attach flow
  proves inconvenient.
- Any change to the broker or agent Dockerfile/compose architecture.

## Testing / verification plan

- `code-devcontainer` from a throwaway repo: broker + agent container come up (or are reused),
  VS Code opens attached, `/workdir` shows the repo contents.
- Install the Claude Code extension in that attached window once; confirm after
  `claude-devcontainer-rebuild` (which recreates the container) that the extension is still
  installed — i.e. the `vscode-server` volume actually persists it.
- Run `code-devcontainer` twice in a row from the same repo; confirm via `docker ps` that only one
  container exists, and that two VS Code windows are both usable against it.
- Confirm the documented manual fallback (Command Palette attach) still works independently of the
  script, in case the URI scheme changes in a future VS Code release.
