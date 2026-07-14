# Dev Container setup for Claude Code Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `claude_docker/` with a Dev Containers based setup (`devcontainer/`) consisting of an `agent` service (today's container) and a new, minimal `broker` service that owns host notification access (PulseAudio/D-Bus), talking to `agent` over a Unix socket shared via a Docker volume — no port, no network exposure.

**Architecture:** `devcontainer.json` + `docker-compose.yml` define two services on `network_mode: host`. `agent` keeps today's tools/mounts plus a `broker-sock` volume; it gets no PulseAudio/D-Bus access. `broker` mounts `/run/user/<uid>` (PulseAudio + D-Bus sockets) and the dotfiles `claude/` directory read-only (for `bell.wav`), and runs `socat` listening on a Unix socket in `broker-sock`, executing `handle-notify.sh` per connection. Claude Code hooks call a new `claude/bell-notify.sh`, which speaks a tiny `type|message` protocol over that socket.

**Tech Stack:** Dev Containers CLI (`npx @devcontainers/cli`), Docker Compose, `socat`, POSIX shell.

## Global Constraints

- Config lives entirely in this dotfiles repo; nothing is written into target repos (per approved design, section A).
- Both services use `network_mode: host` — a documented, temporary compromise for VPN-routed GitLab access (per approved design, Non-goals).
- `agent` must never gain PulseAudio/D-Bus/host-notification access directly — only `broker` has it (per approved design, section B).
- Transport is a Unix socket over a shared named volume — no TCP port, not even on loopback (per approved design, section B/C).
- Hooks must degrade to a silent no-op when run outside the devcontainer (no `socat` binary, or socket missing) (per approved design, section C).
- Prefer POSIX shell tools; use `jq` for JSON, per user's global coding rules.
- Only commit when a task step says to — each task's commit step is the explicit instruction for that commit.

**Important environment note:** the commands in this plan (`docker`, `npx @devcontainers/cli`, `docker compose`) must be run on the actual development host, not from inside a nested container/sandbox that lacks `docker`/`npx`. Verify with `command -v docker npx` before starting Task 1.

---

### Task 1: Agent container image

**Files:**
- Create: `devcontainer/agent/Dockerfile`
- Create: `devcontainer/agent/postCreate.sh`

**Interfaces:**
- Produces: a buildable image tagged `claude-agent-devcontainer:latest`, with a `dev` user (uid 1000), `socat` installed, and `/home/dev/postCreate.sh` present and executable (invoked later by `devcontainer.json`'s `postCreateCommand` in Task 4). `postCreate.sh` takes no arguments; it symlinks every file in `/home/dev/.dotfiles/claude/` into `/home/dev/.claude/`.

- [ ] **Step 1: Create the directory layout**

```bash
mkdir -p /workdir/devcontainer/agent /workdir/devcontainer/broker /workdir/devcontainer/scripts
```

- [ ] **Step 2: Write `devcontainer/agent/Dockerfile`**

```dockerfile
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    jq \
    less \
    openssh-client \
    python3 \
    python3-pip \
    python3-venv \
    ripgrep \
    shellcheck \
    socat \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Install the GitLab CLI (glab) from the official release .deb
ARG GLAB_VERSION=1.103.0
RUN curl -fsSL -o /tmp/glab.deb \
    "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSION}/downloads/glab_${GLAB_VERSION}_linux_amd64.deb" \
    && apt-get install -y --no-install-recommends /tmp/glab.deb \
    && rm -f /tmp/glab.deb /var/lib/apt/lists/* 2>/dev/null || true

# Create dev user with a known UID; devcontainer CLI's updateRemoteUserUID
# remaps this to match the host user at container-creation time.
RUN userdel -r ubuntu 2>/dev/null || true
RUN useradd -m -s /bin/bash -u 1000 dev

USER dev
WORKDIR /workdir

# Pre-create dirs owned by dev so named volumes mounted here inherit dev's
# ownership (1000) instead of being root-owned and unwritable.
RUN mkdir -p /home/dev/.config/glab-cli /home/dev/.claude

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

ENV PATH="/home/dev/.claude/local/bin:/home/dev/.local/bin:${PATH}"

COPY --chown=dev:dev postCreate.sh /home/dev/postCreate.sh
RUN chmod 755 /home/dev/postCreate.sh
```

Note what's deliberately **removed** from the old `claude_docker/Dockerfile`: the `ENTRYPOINT`/`CMD` lines. With `docker-compose.yml`, `overrideCommand` defaults to `false`, so the compose file's own `command:` (Task 3) becomes the container's foreground process instead.

- [ ] **Step 3: Write `devcontainer/agent/postCreate.sh`**

```bash
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
```

- [ ] **Step 4: Build the image and verify it succeeds**

Run: `docker build -t claude-agent-devcontainer devcontainer/agent`
Expected: build completes with `Successfully tagged claude-agent-devcontainer:latest` (or Buildkit's equivalent final `naming to docker.io/library/claude-agent-devcontainer:latest done`).

- [ ] **Step 5: Verify socat is present and postCreate.sh is executable**

Run: `docker run --rm claude-agent-devcontainer bash -c 'command -v socat && test -x /home/dev/postCreate.sh && echo OK'`
Expected: prints the `socat` path followed by `OK`.

- [ ] **Step 6: Commit**

```bash
git add devcontainer/agent
git commit -m "devcontainer: add agent container image"
```

---

### Task 2: Broker container image

**Files:**
- Create: `devcontainer/broker/Dockerfile`
- Create: `devcontainer/broker/handle-notify.sh`

**Interfaces:**
- Consumes: nothing from Task 1.
- Produces: a buildable image tagged `claude-broker-devcontainer:latest` whose default foreground process is `socat UNIX-LISTEN:/run/broker/notify.sock,fork,unlink-early,mode=777 EXEC:/usr/local/bin/handle-notify.sh`. `handle-notify.sh` reads one line of the form `type|message` from stdin and is the only executable later tasks depend on by this exact path (`/usr/local/bin/handle-notify.sh`).

- [ ] **Step 1: Write `devcontainer/broker/Dockerfile`**

```dockerfile
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    dbus \
    libnotify-bin \
    pulseaudio-utils \
    socat \
    util-linux \
    && rm -rf /var/lib/apt/lists/*

COPY handle-notify.sh /usr/local/bin/handle-notify.sh
RUN chmod 755 /usr/local/bin/handle-notify.sh

RUN mkdir -p /run/broker && chmod 777 /run/broker

CMD ["socat", "UNIX-LISTEN:/run/broker/notify.sock,fork,unlink-early,mode=777", "EXEC:/usr/local/bin/handle-notify.sh"]
```

The image itself stays root-built (no `USER` directive), but `docker-compose.yml`'s `user: "${DEV_UID}"` runs the container's actual process as the host UID, because the systemd D-Bus session bus at `/run/user/<uid>/bus` authenticates by peer UID (`SO_PEERCRED`) and rejects root outright with "The connection is closed" even though the socket path itself is reachable. `chmod 777` on `/run/broker` matters because a named volume only inherits an image directory's permissions the *first* time it's created — a stale `broker-sock` volume from an earlier root-owned run needs to be removed (`docker volume rm`) for the fix to take effect, not just an image rebuild.

- [ ] **Step 2: Write `devcontainer/broker/handle-notify.sh`**

```bash
#!/bin/sh
set -eu

IFS='|' read -r type message || true

case "$type" in
    waiting) urgency=low; icon=dialog-question ;;
    done)    urgency=low; icon=dialog-ok ;;
    *)       urgency=low; icon=dialog-information ;;
esac

echo "[broker] notify: type=${type} message=${message}" >&2

# socat tears down this process (and anything still attached to its session)
# as soon as the client closes the connection, which happens right after it
# sends its one line. paplay usually finishes before that race is lost, but
# notify-send's D-Bus round trip often doesn't. setsid detaches the actual
# work into its own session so it survives past this process's teardown.
# shellcheck disable=SC2016
setsid sh -c '
    paplay /claude-assets/bell.wav >/dev/null 2>&1 || true
    notify-send "$1" -a Claude -u "$2" -i "$3" -t 1500 || true
' -- "$message" "$urgency" "$icon" </dev/null >/dev/null 2>&1 &
```

- [ ] **Step 3: Build the image and verify it succeeds**

Run: `docker build -t claude-broker-devcontainer devcontainer/broker`
Expected: build completes with a "Successfully tagged" / "naming to ... done" line.

- [ ] **Step 4: Smoke-test the binaries are present**

Run: `docker run --rm claude-broker-devcontainer sh -c 'command -v socat paplay notify-send'`
Expected: three paths printed, one per binary, no errors.

- [ ] **Step 5: Commit**

```bash
git add devcontainer/broker
git commit -m "devcontainer: add broker container image"
```

---

### Task 3: Compose file wiring agent + broker

**Files:**
- Create: `devcontainer/docker-compose.yml`

**Interfaces:**
- Consumes: `devcontainer/agent/Dockerfile` (Task 1), `devcontainer/broker/Dockerfile` (Task 2).
- Produces: a `docker compose` project with services named `agent` and `broker`, and named volumes `claude-home`, `glab-config`, `broker-sock`. Later tasks (4, 6, 7) reference these exact service and volume names. Requires the host environment variables `WORKSPACE_FOLDER` and `DEV_UID` to be exported before any `docker compose` / `devcontainer` invocation (Task 6's wrapper script does this). Plain `${VAR}` names are used throughout (not devcontainer-spec `${localEnv:...}`/`${localWorkspaceFolder}` syntax) because the devcontainer CLI hands this file straight to `docker compose ... config`, which only understands Compose's own environment-variable interpolation.

- [ ] **Step 1: Write `devcontainer/docker-compose.yml`**

```yaml
services:
  agent:
    build:
      context: ./agent
    network_mode: host
    command: ["sleep", "infinity"]
    volumes:
      - ${WORKSPACE_FOLDER}:/workdir
      - ${WORKSPACE_FOLDER}/.venv-claude:/workdir/.venv
      - claude-home:/home/dev/.claude
      - glab-config:/home/dev/.config/glab-cli
      - broker-sock:/run/broker
      - ${HOME}/.dotfiles:/home/dev/.dotfiles
      - ${HOME}/.claude.json:/home/dev/.claude.json
      - ${HOME}/.netrc:/home/dev/.netrc

  broker:
    build:
      context: ./broker
    network_mode: host
    user: "${DEV_UID}"
    # Ubuntu's AppArmor userspace mediation for D-Bus blocks the session bus
    # from Docker's default confined profile regardless of UID; the broker's
    # sole job is talking to that bus, so it runs unconfined.
    security_opt:
      - apparmor:unconfined
    volumes:
      - broker-sock:/run/broker
      - /run/user/${DEV_UID}:/run/user/${DEV_UID}
      - ${HOME}/.dotfiles/claude:/claude-assets:ro
    environment:
      - PULSE_SERVER=unix:/run/user/${DEV_UID}/pulse/native
      - DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${DEV_UID}/bus

volumes:
  claude-home:
  glab-config:
  broker-sock:
```

`agent` deliberately has no volume touching `/run/user/*` — it cannot reach PulseAudio or D-Bus, matching the design's isolation requirement. Named volumes without `external: true` are created automatically by `docker compose up` the first time they're needed, so no manual `docker volume create` step is required (unlike the old `build.sh`).

- [ ] **Step 2: Validate the compose file**

Run: `WORKSPACE_FOLDER=$(pwd) DEV_UID=$(id -u) docker compose -f devcontainer/docker-compose.yml config`
Expected: prints the fully resolved compose config (both services, volumes) with no errors, `${WORKSPACE_FOLDER}`/`${HOME}`/`${DEV_UID}` all resolved to real values rather than left as literal `${...}` tokens or blank.

- [ ] **Step 3: Commit**

```bash
git add devcontainer/docker-compose.yml
git commit -m "devcontainer: wire agent and broker services in docker-compose.yml"
```

---

### Task 4: devcontainer.json

**Files:**
- Create: `devcontainer/devcontainer.json`

**Interfaces:**
- Consumes: `devcontainer/docker-compose.yml` (Task 3), service name `agent`, `/home/dev/postCreate.sh` (Task 1).
- Produces: the file later referenced by `--config` in Task 6's wrapper script and Task 7's verification.

- [ ] **Step 1: Write `devcontainer/devcontainer.json`**

```json
{
    "name": "claude-agent",
    "dockerComposeFile": "docker-compose.yml",
    "service": "agent",
    "workspaceFolder": "/workdir",
    "remoteUser": "dev",
    "updateRemoteUserUID": true,
    "postCreateCommand": "/home/dev/postCreate.sh",
    "shutdownAction": "stopCompose"
}
```

`updateRemoteUserUID: true` (the devcontainer CLI default, listed explicitly for clarity) remaps the `dev` user inside the container to the host's UID/GID on creation, replacing what `--user "$(id -u)":"$(id -g)"` did in the old `run.sh`. `shutdownAction: stopCompose` stops both `agent` and `broker` together when the devcontainer session ends.

- [ ] **Step 2: Validate JSON syntax**

Run: `jq . devcontainer/devcontainer.json`
Expected: the same JSON printed back, pretty-formatted, no parse error.

- [ ] **Step 3: Commit**

```bash
git add devcontainer/devcontainer.json
git commit -m "devcontainer: add devcontainer.json for agent service"
```

---

### Task 5: Notification protocol (hooks + client script)

**Files:**
- Create: `claude/bell-notify.sh`
- Modify: `claude/settings.json` (the `hooks.Notification` and `hooks.Stop` command strings)

**Interfaces:**
- Consumes: `/run/broker/notify.sock` (produced by the `broker` service, Task 2/3), speaking the `type|message` protocol handled by `devcontainer/broker/handle-notify.sh` (Task 2).
- Produces: `claude/bell-notify.sh <type> <message>`, invoked by Claude Code's `Notification` and `Stop` hooks.

- [ ] **Step 1: Write `claude/bell-notify.sh`**

```bash
#!/bin/bash
set -euo pipefail

TYPE="${1:-info}"
MESSAGE="${2:-}"
SOCK=/run/broker/notify.sock

command -v socat >/dev/null 2>&1 || exit 0
[ -S "$SOCK" ] || exit 0

printf '%s|%s\n' "$TYPE" "$MESSAGE" | socat - "UNIX-CONNECT:${SOCK}" >/dev/null 2>&1 || true
```

```bash
chmod +x /workdir/claude/bell-notify.sh
```

- [ ] **Step 2: Update `claude/settings.json` hooks**

Change the `Notification` hook's command from:
```
"command": "paplay ~/.claude/bell.wav && notify-send '⏳ Waiting for input' -a Claude -u low -t 1500"
```
to:
```
"command": "bash ~/.claude/bell-notify.sh waiting \"⏳ Waiting for input\""
```

Change the `Stop` hook's command from:
```
"command": "paplay ~/.claude/bell.wav && notify-send '✅ Done' -a Claude -u low -t 1500"
```
to:
```
"command": "bash ~/.claude/bell-notify.sh done \"✅ Done\""
```

The resulting `hooks` block:

```json
    "hooks": {
        "Notification": [
            {
                "matcher": "*",
                "hooks": [
                    {
                        "type": "command",
                        "command": "bash ~/.claude/bell-notify.sh waiting \"⏳ Waiting for input\""
                    }
                ]
            }
        ],
        "Stop": [
            {
                "hooks": [
                    {
                        "type": "command",
                        "command": "bash ~/.claude/bell-notify.sh done \"✅ Done\""
                    }
                ]
            }
        ]
    },
```

- [ ] **Step 3: Round-trip smoke test via docker compose directly**

This exercises the socket protocol without needing the full devcontainer CLI flow (that's Task 7).

```bash
export DEV_UID
DEV_UID="$(id -u)"
docker compose -f devcontainer/docker-compose.yml up -d broker
docker compose -f devcontainer/docker-compose.yml run --rm \
  -v "$(pwd)/claude:/home/dev/.claude" \
  agent bash -c 'source /home/dev/.cargo/env 2>/dev/null; bash /home/dev/.claude/bell-notify.sh done "test message"'
docker compose -f devcontainer/docker-compose.yml logs broker
```

Expected: the `logs broker` output contains a line `[broker] notify: type=done message=test message`, and (if PulseAudio/D-Bus are reachable on the host) the bell sound plays and a desktop notification appears.

- [ ] **Step 4: Tear down the smoke-test stack**

```bash
docker compose -f devcontainer/docker-compose.yml down
```

- [ ] **Step 5: Commit**

```bash
git add claude/bell-notify.sh claude/settings.json
git commit -m "claude: route notification hooks through the broker socket"
```

---

### Task 6: Wrapper script and host aliases

**Files:**
- Create: `devcontainer/scripts/claude-devcontainer`
- Modify: `bash_aliases:393` (the `alias claude=...` line)

**Interfaces:**
- Consumes: `devcontainer/devcontainer.json` (Task 4), `npx @devcontainers/cli` (the user's existing host alias per the approved design).
- Produces: a `claude` command on the host equivalent to today's `claude_docker/run.sh`, and a bare `devcontainer` alias for direct devcontainer CLI use.

- [ ] **Step 1: Write `devcontainer/scripts/claude-devcontainer`**

```bash
#!/bin/bash
set -euo pipefail

DOTFILES_DEVCONTAINER="$HOME/.dotfiles/devcontainer/devcontainer.json"

# Exported plainly (not devcontainer-spec ${localEnv:...} syntax) because the
# referenced docker-compose.yml is interpolated by plain `docker compose`,
# which only understands ${VAR} looked up from the process environment.
export WORKSPACE_FOLDER
WORKSPACE_FOLDER="$(pwd)"

export DEV_UID
DEV_UID="$(id -u)"

[ -e "$HOME/.claude.json" ] || echo "{}" > "$HOME/.claude.json"
mkdir -p "${WORKSPACE_FOLDER}/.venv-claude"

npx @devcontainers/cli up --workspace-folder "$WORKSPACE_FOLDER" --config "$DOTFILES_DEVCONTAINER"
exec npx @devcontainers/cli exec --workspace-folder "$WORKSPACE_FOLDER" --config "$DOTFILES_DEVCONTAINER" bash
```

```bash
chmod +x /workdir/devcontainer/scripts/claude-devcontainer
```

- [ ] **Step 2: Update `bash_aliases`**

Replace this line (currently `bash_aliases:393`):
```
alias claude="$HOME/.dotfiles/claude_docker/run.sh"
```
with:
```
alias devcontainer="npx @devcontainers/cli"
alias claude="$HOME/.dotfiles/devcontainer/scripts/claude-devcontainer"
```

- [ ] **Step 3: Shellcheck the new script**

Run: `shellcheck devcontainer/scripts/claude-devcontainer`
Expected: no output (no warnings/errors).

- [ ] **Step 4: Commit**

```bash
git add devcontainer/scripts/claude-devcontainer bash_aliases
git commit -m "devcontainer: add claude-devcontainer wrapper and update host aliases"
```

---

### Task 7: End-to-end verification via the devcontainer CLI

**Files:** none (verification only — no commit for this task).

**Interfaces:**
- Consumes: everything from Tasks 1-6, exercised together through the real `devcontainer` CLI rather than raw `docker compose`.

- [ ] **Step 1: Set up a scratch workspace**

```bash
mkdir -p /tmp/devcontainer-smoke-test
cd /tmp/devcontainer-smoke-test
git init -q
```

- [ ] **Step 2: Bring the devcontainer up**

```bash
export WORKSPACE_FOLDER=/tmp/devcontainer-smoke-test
export DEV_UID
DEV_UID="$(id -u)"
npx @devcontainers/cli up --workspace-folder /tmp/devcontainer-smoke-test \
  --config "$HOME/.dotfiles/devcontainer/devcontainer.json"
```

Expected: JSON output ending with `"outcome":"success"`, both `agent` and `broker` containers running (`docker compose -f "$HOME/.dotfiles/devcontainer/docker-compose.yml" ps` shows both `Up`).

- [ ] **Step 3: Verify the dotfiles symlink step ran**

```bash
npx @devcontainers/cli exec --workspace-folder /tmp/devcontainer-smoke-test \
  --config "$HOME/.dotfiles/devcontainer/devcontainer.json" \
  bash -c 'readlink ~/.claude/settings.json'
```

Expected: prints `/home/dev/.dotfiles/claude/settings.json`.

- [ ] **Step 4: Verify the notification round trip**

```bash
npx @devcontainers/cli exec --workspace-folder /tmp/devcontainer-smoke-test \
  --config "$HOME/.dotfiles/devcontainer/devcontainer.json" \
  bash -c 'bash ~/.claude/bell-notify.sh done "e2e test"'
docker compose -f "$HOME/.dotfiles/devcontainer/docker-compose.yml" logs broker --tail 5
```

`~` must be wrapped in `bash -c '...'` (single-quoted) here — unquoted, the host shell expands it to the *host's* home directory before `devcontainer exec` ever sees the argument, breaking the path inside the container.

Expected: `logs broker` shows `[broker] notify: type=done message=e2e test`; bell sound and desktop notification observed on the host.

- [ ] **Step 5: Verify agent has no PulseAudio/D-Bus access**

```bash
npx @devcontainers/cli exec --workspace-folder /tmp/devcontainer-smoke-test \
  --config "$HOME/.dotfiles/devcontainer/devcontainer.json" \
  bash -c 'test -S /run/user/'"$DEV_UID"'/pulse/native && echo LEAK || echo OK'
```

Expected: prints `OK` (the socket path does not exist inside `agent`).

- [ ] **Step 6: Verify UID remapping and persisted volumes**

```bash
npx @devcontainers/cli exec --workspace-folder /tmp/devcontainer-smoke-test \
  --config "$HOME/.dotfiles/devcontainer/devcontainer.json" \
  bash -c 'id -u; touch /home/dev/.claude/e2e-marker; ls -la /workdir/.venv'
```

Expected: `id -u` matches the host's `$(id -u)`; the touch succeeds (no permission error); `.venv-claude` bind mount is visible and writable.

- [ ] **Step 7: Tear down**

```bash
docker compose -f "$HOME/.dotfiles/devcontainer/docker-compose.yml" down
rm -rf /tmp/devcontainer-smoke-test
```

If any step fails, stop and fix the relevant task (1-6) before proceeding to Task 8 — do not retire the old setup until this task passes cleanly.

---

### Task 8: Retire `claude_docker/`

**Files:**
- Delete: `claude_docker/Dockerfile`, `claude_docker/build.sh`, `claude_docker/run.sh`, `claude_docker/entrypoint.sh`

**Interfaces:** none — this is cleanup only, gated on Task 7 passing.

- [ ] **Step 1: Remove the old setup**

```bash
git rm -r /workdir/claude_docker
```

- [ ] **Step 2: Confirm nothing else references it**

Run: `grep -rn "claude_docker" /workdir --include="*.sh" --include="*.md" --include="bash_aliases" --include="zshrc" -l`
Expected: no output (the `bash_aliases` reference was already updated in Task 6).

- [ ] **Step 3: Commit**

```bash
git commit -m "devcontainer: retire claude_docker in favor of devcontainer/"
```

---

## Self-Review Notes

- **Spec coverage:** repo layout/invocation (Tasks 1, 4, 6), agent/broker split and mounts (Tasks 1-3), notification protocol and hook changes (Task 5), extensibility seam and future MCP broker — documented in the design doc only, no task needed since they're explicit non-goals, wrapper/alias (Task 6), retiring `claude_docker/` (Task 8), verification plan (Task 7 covers all four bullet points from the design's Testing section; the bare-host no-op guard is covered by `bell-notify.sh`'s own guard clause in Task 5 rather than a separate test, since it's a property of the code, not the running stack).
- **Placeholder scan:** none found — every step has literal file contents or literal commands with literal expected output.
- **Type/name consistency:** service names `agent`/`broker`, volume names `claude-home`/`glab-config`/`broker-sock`, socket path `/run/broker/notify.sock`, executable path `/usr/local/bin/handle-notify.sh`, and script path `~/.claude/bell-notify.sh` are used identically across Tasks 1-7.
