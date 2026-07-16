# MCP-everything Container Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. You don't have access to docker, ask the user to run the docker commands.

**Goal:** Add a containerized `@modelcontextprotocol/server-everything` MCP server to the devcontainer setup, reachable directly from the agent container over a dedicated network, as a test of running isolated MCP servers alongside the existing broker.

**Architecture:** `mcp-everything` is a new global-singleton container (Node/Alpine, `socat` wrapping the stdio MCP process on TCP port 3001), sharing one merged `docker-compose.yml` with the existing broker. The agent container joins a new `mcp-net` bridge network (replacing its current `--network=host`) so it can reach `mcp-everything` by service name; Claude Code connects using `nc` as the MCP server's `command`.

**Tech Stack:** Docker Compose, `node:22-alpine`, `socat`, `netcat-openbsd` (`nc`), `@modelcontextprotocol/server-everything` (npm), Bash, devcontainers CLI.

## Global Constraints

- MCP server for this test: `@modelcontextprotocol/server-everything` (stateless reference/test server — no credentials, no filesystem access, no per-repo state).
- `mcp-everything` is a global singleton (one instance, shared across all repos) — not per-repo.
- The broker's `network_mode: host` and all other broker config stays unchanged.
- No routing of MCP traffic through the broker — the agent reaches `mcp-everything` directly over the network.
- Tasks 1-6 do not wire `~/.claude.json` through any automated symlink/bind-mount mechanism — they document the required manual `mcpServers` entry instead (see spec: `claude/.claude.json` is currently disconnected from the live container file, and fixing that was out of scope for the original design). Task 7 is a follow-up that does add automation, scoped narrowly to merging just the `mcpServers` key via `jq` — it does not touch the rest of `~/.claude.json`'s wiring.
- Spec reference: `superpowers/specs/2026-07-16-mcp-broker-design.md`.

---

### Task 1: Build the `mcp-everything` container image

**Files:**
- Create: `devcontainer/mcp-everything/Dockerfile`

**Interfaces:**
- Produces: a standalone Docker image, tagged `mcp-everything-test` for this task's verification, that listens on TCP port 3001 and bridges each connection to a fresh `mcp-server-everything` (stdio) process via `socat`. Task 2 consumes this Dockerfile as a compose `build.context`.

- [ ] **Step 1: Write the Dockerfile**

```dockerfile
FROM node:22-alpine

RUN apk add --no-cache socat

RUN npm install -g @modelcontextprotocol/server-everything

# node:22-alpine already ships a non-root "node" user at uid 1000 for this
# purpose, so there's no need to create a separate one.
USER node

EXPOSE 3001
CMD ["socat", "TCP-LISTEN:3001,fork,reuseaddr", "EXEC:mcp-server-everything"]
```
(Note: an earlier draft of this Dockerfile created a separate `mcp` user via
`addgroup -S mcp && adduser -S mcp -G mcp -u 1000`, but `node:22-alpine`
already has a built-in `node` user at uid 1000, so that step failed with
`adduser: uid '1000' in use`. Using the existing `node` user avoids the
conflict.)

- [ ] **Step 2: Build the image standalone**

Run: `docker build -t mcp-everything-test devcontainer/mcp-everything`
Expected: build succeeds (exit code 0); if `npm install -g @modelcontextprotocol/server-everything` fails to expose a `mcp-server-everything` binary, run `docker run --rm --entrypoint sh mcp-everything-test -c "ls /usr/local/bin | grep mcp"` to find the actual installed binary name and correct the `CMD` line's `EXEC:` argument accordingly, then rebuild.

- [ ] **Step 3: Run the image and verify it accepts a connection**

Run:
```bash
docker run --rm -d --name mcp-everything-test -p 3001:3001 mcp-everything-test
sleep 1
nc -zv localhost 3001
docker stop mcp-everything-test
```
Expected: `nc -zv` prints `Connection to localhost 3001 port [tcp/*] succeeded!` (or equivalent). If it prints "Connection refused", inspect `docker logs mcp-everything-test` for a `socat` or Node startup error before proceeding.

- [ ] **Step 4: Commit**

```bash
git add devcontainer/mcp-everything/Dockerfile
git commit -m "$(cat <<'EOF'
Add mcp-everything container image

Wraps @modelcontextprotocol/server-everything's stdio process behind
socat TCP-LISTEN:3001, so it can be reached over the network instead of
spawned as a local subprocess.
EOF
)"
```

---

### Task 2: Merge `mcp-everything` into the singleton compose stack

**Files:**
- Create: `devcontainer/docker-compose.yml` (new top-level file)
- Delete: `devcontainer/broker/docker-compose.yml` (content moves into the new file)

**Interfaces:**
- Consumes: `devcontainer/mcp-everything/Dockerfile` (Task 1), existing `devcontainer/broker/Dockerfile` (unchanged).
- Produces: a `mcp-net` Docker network (fixed name `mcp-net`) that Task 3's `devcontainer.json` change and Task 4's script changes depend on; a `broker-sock` named volume (unchanged from today).

- [ ] **Step 1: Read the current broker compose file to confirm its exact contents before moving it**

Run: `cat devcontainer/broker/docker-compose.yml`
Expected output (confirm it matches before proceeding — if it differs, use the actual content instead of the snippet below):
```yaml
services:
  broker:
    build:
      context: .
    network_mode: host
    user: "${DEV_UID}"
    security_opt:
      - apparmor:unconfined
    restart: unless-stopped
    volumes:
      - broker-sock:/run/broker
      - /run/user/${DEV_UID}:/run/user/${DEV_UID}
      - ${HOME}/.dotfiles/claude:/claude-assets:ro
    environment:
      - PULSE_SERVER=unix:/run/user/${DEV_UID}/pulse/native
      - DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${DEV_UID}/bus

volumes:
  broker-sock:
    name: broker-sock
```

- [ ] **Step 2: Create the merged `devcontainer/docker-compose.yml`**

```yaml
services:
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
    restart: unless-stopped
    volumes:
      - broker-sock:/run/broker
      - /run/user/${DEV_UID}:/run/user/${DEV_UID}
      - ${HOME}/.dotfiles/claude:/claude-assets:ro
    environment:
      - PULSE_SERVER=unix:/run/user/${DEV_UID}/pulse/native
      - DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${DEV_UID}/bus

  mcp-everything:
    build:
      context: ./mcp-everything
    restart: unless-stopped
    networks:
      - mcp-net

networks:
  # Fixed name so the agent's `--network=mcp-net` runArg (devcontainer.json)
  # attaches to this network by name, rather than Compose's default
  # project-prefixed naming.
  mcp-net:
    name: mcp-net

volumes:
  # Fixed name so this matches the plain (non-Compose) volume reference the
  # agent's devcontainer.json mounts by name — otherwise Compose would
  # namespace it under the project name, a different volume the agent never sees.
  broker-sock:
    name: broker-sock
```

- [ ] **Step 3: Delete the old broker-only compose file**

Run: `git rm devcontainer/broker/docker-compose.yml`

- [ ] **Step 4: Validate the merged file's syntax**

Run: `export DEV_UID=$(id -u) && docker compose -f devcontainer/docker-compose.yml config --quiet`
Expected: no output, exit code 0. (`--quiet` suppresses the rendered YAML; a non-zero exit or error text means a syntax problem to fix before continuing.)

- [ ] **Step 5: Bring the merged stack up and verify both services**

Run:
```bash
docker compose -f devcontainer/docker-compose.yml up -d --wait
docker compose -f devcontainer/docker-compose.yml ps
```
Expected: both `broker` and `mcp-everything` listed with state `running`/`Up`.

- [ ] **Step 6: Verify `mcp-everything` is reachable by service name from another container on `mcp-net`**

Run:
```bash
docker run --rm --network mcp-net alpine sh -c "apk add --no-cache netcat-openbsd >/dev/null && nc -zv mcp-everything 3001"
```
Expected: `mcp-everything (172.x.x.x:3001) open` (or equivalent "succeeded" message).

- [ ] **Step 7: Tear down before committing (avoid leaving dev-machine state mid-plan)**

Run: `docker compose -f devcontainer/docker-compose.yml down`

- [ ] **Step 8: Commit**

```bash
git add devcontainer/docker-compose.yml
git commit -m "$(cat <<'EOF'
Merge broker and mcp-everything into one singleton compose stack

Moves the broker's compose file up to devcontainer/docker-compose.yml
and adds mcp-everything as a second singleton service, on a new mcp-net
bridge network. One `docker compose up -d --wait` now brings up both
services instead of requiring a second invocation per stack.
EOF
)"
```

---

### Task 3: Attach the agent container to `mcp-net`

**Files:**
- Modify: `devcontainer/devcontainer.json`

**Interfaces:**
- Consumes: the `mcp-net` network produced by Task 2 (must already exist — verified in Step 3 below).

- [ ] **Step 1: Change the agent's network**

In `devcontainer/devcontainer.json`, change:
```json
    "runArgs": [
        "--network=host"
    ],
```
to:
```json
    "runArgs": [
        "--network=mcp-net"
    ],
```

- [ ] **Step 2: Bring the compose stack up (mcp-net must exist before the agent container is created)**

Run: `export DEV_UID=$(id -u) && docker compose -f devcontainer/docker-compose.yml up -d --wait`
Expected: both services running (as in Task 2).

- [ ] **Step 3: Create the agent container against the updated config and verify it landed on `mcp-net`**

Run:
```bash
cd /tmp && mkdir -p mcp-test-workspace && cd mcp-test-workspace
npx @devcontainers/cli up --workspace-folder "$(pwd)" --config /workdir/devcontainer/devcontainer.json
CONTAINER_ID=$(docker ps -q --filter "label=devcontainer.local_folder=$(pwd)")
docker inspect "$CONTAINER_ID" --format '{{json .NetworkSettings.Networks}}'
```
Expected: JSON output whose only key is `mcp-net` (not `host`/bridge default).

- [ ] **Step 4: Verify the agent container can reach `mcp-everything` by name**

Run: `npx @devcontainers/cli exec --workspace-folder "$(pwd)" --config /workdir/devcontainer/devcontainer.json nc -zv mcp-everything 3001`
Expected: connection succeeds. If `nc` is not installed in the agent image, this step also confirms Task 4's script/config changes are needed before Claude Code itself can use `nc` — note it and continue; `nc` availability in `agent/Dockerfile` is required for the end-to-end test in Task 5 and should be checked there.

- [ ] **Step 5: Check for anything that depended on the agent's old host networking**

Run: `grep -rn "localhost\|127\.0\.0\.1" devcontainer/agent/ claude/ devcontainer/scripts/`
Expected: no matches referencing a host-side service the agent needs to reach directly (e.g. a local dev server on `localhost:<port>`). If any match does depend on reaching the host's network namespace directly, flag it — `mcp-net` is an isolated bridge network and no longer shares the host's loopback interface, so such a dependency would break and needs a separate follow-up (out of scope for this plan).

- [ ] **Step 6: Clean up the test container and workspace**

Run:
```bash
npx @devcontainers/cli exec --workspace-folder "$(pwd)" --config /workdir/devcontainer/devcontainer.json true || true
docker rm -f "$CONTAINER_ID"
cd /workdir && rm -rf /tmp/mcp-test-workspace
docker compose -f devcontainer/docker-compose.yml down
```

- [ ] **Step 7: Commit**

```bash
git add devcontainer/devcontainer.json
git commit -m "$(cat <<'EOF'
Attach agent container to mcp-net instead of host networking

Needed so the agent can resolve mcp-* singleton containers (e.g.
mcp-everything) by service name over Docker's compose DNS.
EOF
)"
```

---

### Task 4: Repoint launch scripts at the merged compose file, and ensure `nc` is available in the agent

**Files:**
- Modify: `devcontainer/scripts/claude-devcontainer:38`
- Modify: `devcontainer/scripts/code-devcontainer:30`
- Modify: `devcontainer/scripts/claude-devcontainer-rebuild:32`
- Modify: `devcontainer/scripts/claude-devcontainer-compose:15`
- Modify: `devcontainer/agent/Dockerfile`

**Interfaces:**
- Consumes: `devcontainer/docker-compose.yml` (Task 2).
- Produces: the `nc` binary available on the agent's `PATH`, which Task 5's Claude Code `mcpServers` config depends on (`"command": "nc"`).

- [ ] **Step 1: Repoint `claude-devcontainer`**

In `devcontainer/scripts/claude-devcontainer`, change:
```bash
docker compose -f "$DOTFILES_DEVCONTAINER_DIR/broker/docker-compose.yml" up -d --wait
```
to:
```bash
docker compose -f "$DOTFILES_DEVCONTAINER_DIR/docker-compose.yml" up -d --wait
```

- [ ] **Step 2: Repoint `code-devcontainer`**

In `devcontainer/scripts/code-devcontainer`, change:
```bash
docker compose -f "$DOTFILES_DEVCONTAINER_DIR/broker/docker-compose.yml" up -d --wait
```
to:
```bash
docker compose -f "$DOTFILES_DEVCONTAINER_DIR/docker-compose.yml" up -d --wait
```

- [ ] **Step 3: Repoint `claude-devcontainer-rebuild`**

In `devcontainer/scripts/claude-devcontainer-rebuild`, change:
```bash
docker compose -f "$DOTFILES_DEVCONTAINER_DIR/broker/docker-compose.yml" up -d --wait
```
to:
```bash
docker compose -f "$DOTFILES_DEVCONTAINER_DIR/docker-compose.yml" up -d --wait
```

- [ ] **Step 4: Repoint `claude-devcontainer-compose`**

In `devcontainer/scripts/claude-devcontainer-compose`, change:
```bash
exec docker compose -f "$HOME/.dotfiles/devcontainer/broker/docker-compose.yml" "$@"
```
to:
```bash
exec docker compose -f "$HOME/.dotfiles/devcontainer/docker-compose.yml" "$@"
```
Also update its header comment (currently "Thin wrapper around `docker compose` for the global broker project") to say "for the global singleton services project (broker, mcp-everything, ...)" since it now wraps more than just the broker.

- [ ] **Step 5: Check whether `nc` is already available in the agent image**

Run: `grep -n "netcat\|openbsd" devcontainer/agent/Dockerfile`
Expected: no match — `agent/Dockerfile`'s `apt-get install` list (bash, ca-certificates, curl, git, jq, less, openssh-client, ripgrep, shellcheck, socat, vim) does not currently include a netcat package.

- [ ] **Step 6: Add `netcat-openbsd` to the agent image**

In `devcontainer/agent/Dockerfile`, change:
```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    jq \
    less \
    openssh-client \
    # Should not be needed with the uv feature (To be confirmed)
    # python3 \
    # python3-pip \
    # python3-venv \
    ripgrep \
    shellcheck \
    socat \
    vim \
    && rm -rf /var/lib/apt/lists/*
```
to:
```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    jq \
    less \
    netcat-openbsd \
    openssh-client \
    # Should not be needed with the uv feature (To be confirmed)
    # python3 \
    # python3-pip \
    # python3-venv \
    ripgrep \
    shellcheck \
    socat \
    vim \
    && rm -rf /var/lib/apt/lists/*
```

- [ ] **Step 7: Verify the scripts have no remaining references to the old path**

Run: `grep -rn "broker/docker-compose.yml" devcontainer/scripts/`
Expected: no output.

- [ ] **Step 8: Commit**

```bash
git add devcontainer/scripts/claude-devcontainer devcontainer/scripts/code-devcontainer \
    devcontainer/scripts/claude-devcontainer-rebuild devcontainer/scripts/claude-devcontainer-compose \
    devcontainer/agent/Dockerfile
git commit -m "$(cat <<'EOF'
Point launch scripts at the merged compose file, add nc to agent image

All four scripts referenced devcontainer/broker/docker-compose.yml,
which moved in the previous commit. Also adds netcat-openbsd to the
agent image so Claude Code can reach mcp-everything via `nc`.
EOF
)"
```

---

### Task 5: End-to-end validation — Claude Code talking to `mcp-everything`

**Files:**
- None (verification only; no repo files change in this task).

**Interfaces:**
- Consumes: everything from Tasks 1-4 (merged compose stack, agent on `mcp-net`, `nc` in the agent image).

- [ ] **Step 1: Rebuild the agent image so it picks up the `netcat-openbsd` addition**

Run: `cd <any-test-repo> && claude-devcontainer-rebuild`
Expected: drops you into a fresh shell inside the rebuilt agent container.

- [ ] **Step 2: Confirm `nc` is present and can reach `mcp-everything` from inside the real agent container**

Run (inside the agent container shell from Step 1): `nc -zv mcp-everything 3001`
Expected: "succeeded" / "open" message, no "command not found" or "Connection refused".

- [ ] **Step 3: Add the MCP server entry to your real `~/.claude.json` (on the host, since this file is bind-mounted directly rather than managed by the dotfiles symlink mechanism — see Global Constraints)**

Edit `~/.claude.json` and add (merge into the existing JSON object, don't overwrite it):
```json
"mcpServers": {
  "everything": {
    "command": "nc",
    "args": ["mcp-everything", "3001"]
  }
}
```
Verify with: `jq '.mcpServers' ~/.claude.json`
Expected: prints the object above.

- [ ] **Step 4: Start Claude Code inside the agent container and confirm the MCP server connects**

Inside the agent container shell: run `claude`, then use Claude Code's `/mcp` command (or equivalent) to list configured MCP servers.
Expected: `everything` listed with a connected/healthy status, not an error.

- [ ] **Step 5: Exercise the `echo` tool through the full chain**

Inside the Claude Code session, ask it to call the `everything` server's `echo` tool with a distinctive test string, e.g. "mcp-everything-roundtrip-test".
Expected: the tool result contains exactly that string, unmodified.

- [ ] **Step 6: Confirm the restart failure mode matches the spec's expectation**

In a separate host shell: `docker compose -f /workdir/devcontainer/docker-compose.yml up -d --force-recreate mcp-everything`
Then, back in the still-open Claude Code session from Step 4, try the `echo` tool again.
Expected: the call fails (broken pipe / disconnected), since `nc` held one long-lived connection to the now-replaced container — starting a fresh Claude Code session should be required to reconnect. This confirms the behavior documented in the spec's Error Handling section rather than a silent hang.

- [ ] **Step 7: No commit for this task** (verification only) — proceed to Task 6 to document what was just validated.

---

### Task 6: Update `devcontainer/README.md`

**Files:**
- Modify: `devcontainer/README.md`

**Interfaces:**
- None (documentation only).

- [ ] **Step 1: Update the architecture diagram**

Change (README.md lines 39-62):
```
host
├── ~/.dotfiles/devcontainer/          <- this directory, shared across all repos
│   ├── devcontainer.json              <- agent container config (per-repo instance)
│   ├── agent/
│   │   ├── Dockerfile                 <- agent image: bash, git, vim, ripgrep, gh, glab, ...
│   │   └── postCreate.sh              <- symlinks ~/.dotfiles/claude/* into ~/.claude on create
│   ├── broker/
│   │   ├── Dockerfile                 <- broker image: socat, dbus, libnotify-bin, pulseaudio-utils
│   │   ├── docker-compose.yml         <- broker service definition (global singleton)
│   │   └── handle-notify.sh           <- runs inside broker; plays sound + notify-send per message
│   └── scripts/
│       ├── claude-devcontainer            <- `claude` alias target: up broker, up/exec agent
│       ├── code-devcontainer              <- `code-devcontainer` alias target: up broker/agent, open VS Code attached
│       ├── claude-devcontainer-compose    <- thin `docker compose` wrapper for the broker project
│       └── claude-devcontainer-rebuild    <- force a clean rebuild of the agent image/container
│
├── <repo>/.venv-claude/               <- per-repo bind mount target for the agent's /workdir/.venv
│
└── docker volumes
    ├── claude-home    <- ~/.claude inside agent containers (session state, persists across repos)
    ├── glab-config    <- ~/.config/glab-cli inside agent containers
    ├── vscode-server  <- ~/.vscode-server inside agent containers (VS Code Server + extensions)
    └── broker-sock    <- /run/broker inside both agent and broker (the notify socket lives here)
```
to:
```
host
├── ~/.dotfiles/devcontainer/          <- this directory, shared across all repos
│   ├── devcontainer.json              <- agent container config (per-repo instance)
│   ├── docker-compose.yml             <- singleton services: broker + mcp-everything (global, all workspaces)
│   ├── agent/
│   │   ├── Dockerfile                 <- agent image: bash, git, vim, ripgrep, gh, glab, ...
│   │   └── postCreate.sh              <- symlinks ~/.dotfiles/claude/* into ~/.claude on create
│   ├── broker/
│   │   ├── Dockerfile                 <- broker image: socat, dbus, libnotify-bin, pulseaudio-utils
│   │   └── handle-notify.sh           <- runs inside broker; plays sound + notify-send per message
│   ├── mcp-everything/
│   │   └── Dockerfile                 <- MCP test server image: node, socat, @modelcontextprotocol/server-everything
│   └── scripts/
│       ├── claude-devcontainer            <- `claude` alias target: up broker+mcp, up/exec agent
│       ├── code-devcontainer              <- `code-devcontainer` alias target: up broker+mcp/agent, open VS Code attached
│       ├── claude-devcontainer-compose    <- thin `docker compose` wrapper for the singleton services project
│       └── claude-devcontainer-rebuild    <- force a clean rebuild of the agent image/container
│
├── <repo>/.venv-claude/               <- per-repo bind mount target for the agent's /workdir/.venv
│
├── docker volumes
│   ├── claude-home    <- ~/.claude inside agent containers (session state, persists across repos)
│   ├── glab-config    <- ~/.config/glab-cli inside agent containers
│   ├── vscode-server  <- ~/.vscode-server inside agent containers (VS Code Server + extensions)
│   └── broker-sock    <- /run/broker inside both agent and broker (the notify socket lives here)
│
└── docker networks
    └── mcp-net        <- bridge network joining the agent container and mcp-* singleton containers
```

- [ ] **Step 2: Update the `agent` bullet in "Two containers, two lifecycles"**

Change:
```
- `agent` is **per-repo** — one instance per workspace folder, built from
  `agent/Dockerfile`, created/reused by the `devcontainers` CLI
  (`devcontainer.json`). It mounts the repo at `/workdir`, gets `broker-sock` so it
  can reach the broker's socket, but never touches the host directly.
```
to:
```
- `agent` is **per-repo** — one instance per workspace folder, built from
  `agent/Dockerfile`, created/reused by the `devcontainers` CLI
  (`devcontainer.json`). It mounts the repo at `/workdir`, gets `broker-sock` so it
  can reach the broker's socket, and joins the `mcp-net` bridge network so it can
  reach singleton MCP server containers (e.g. `mcp-everything`) by service name —
  but never touches the host directly.
```

- [ ] **Step 3: Replace the "Future MCP broker" paragraph with what was actually built**

Change:
```
**Future MCP broker:** the same pattern (dedicated minimal container, socket in
its own named volume, agent never gets host access directly) generalizes to an
`mcp-broker` service that forwards MCP traffic via `socat`, keeping credentials
and tool access off the agent container and mediated at one auditable point —
the isolation approach described in Dashlane's write-up on sandboxing AI coding
tools. Not built yet.
```
to:
```
**MCP servers:** each MCP server runs in its own container, alongside the
broker, as a singleton service in the top-level `docker-compose.yml` (e.g.
`mcp-everything`, wrapping `@modelcontextprotocol/server-everything`). The
agent container reaches them directly over the `mcp-net` bridge network by
service name — no broker involvement for MCP traffic; this is a deliberate
simplification over the "future MCP broker" idea floated in an earlier
version of this doc, since these servers don't hold host-facing credentials
the way the notification broker does. Each server's container wraps its
stdio-based process behind `socat TCP-LISTEN:<port>,fork`, and Claude Code is
configured to reach it with `nc <service-name> <port>` as the MCP server's
`command`.

To add a new MCP server: add a `devcontainer/mcp-<name>/Dockerfile` following
the `mcp-everything` pattern, add a matching service to the top-level
`docker-compose.yml` on the `mcp-net` network, and add an entry under
`mcpServers` in your `~/.claude.json` — this file is bind-mounted directly
from the host today rather than managed through the `~/.dotfiles/claude/`
symlink mechanism that handles the rest of `~/.claude/`, so edit it by hand:
```json
"mcpServers": {
  "everything": {
    "command": "nc",
    "args": ["mcp-everything", "3001"]
  }
}
```
```

- [ ] **Step 4: Update the "Change the broker" section to reflect the merged file and add an MCP-server equivalent**

Change:
```
**Change the broker** (new notification behavior, future MCP forwarding): edit
`broker/Dockerfile`, `broker/docker-compose.yml`, or `broker/handle-notify.sh`,
then recreate the broker:
```
claude-devcontainer-compose up -d --build --force-recreate
```
```
to:
```
**Change the broker** (new notification behavior): edit `broker/Dockerfile` or
`broker/handle-notify.sh`, then recreate just that service:
```
claude-devcontainer-compose up -d --build --force-recreate broker
```

**Change an MCP server** (new server, dependency bump): edit
`mcp-<name>/Dockerfile` or the top-level `docker-compose.yml`, then recreate
just that service:
```
claude-devcontainer-compose up -d --build --force-recreate mcp-everything
```
```

- [ ] **Step 5: Verify no stale references remain**

Run: `grep -n "broker/docker-compose.yml\|Future MCP broker\|mcp-broker" devcontainer/README.md`
Expected: no output.

- [ ] **Step 6: Commit**

```bash
git add devcontainer/README.md
git commit -m "$(cat <<'EOF'
Document mcp-everything in devcontainer README

Updates the architecture diagram and replaces the old "Future MCP
broker" section with a description of the MCP-server-per-container
pattern actually implemented, including how to add new servers and the
manual ~/.claude.json step.
EOF
)"
```

---

### Task 7 (follow-up): Wire `mcpServers` into `~/.claude.json` via a tracked file + `jq` merge

**Context:** Task 5 required manually pasting the `mcpServers` block into `~/.claude.json` on the host. `~/.claude.json` holds a lot of other session/project state the user doesn't want under version control, but they do want the `mcpServers` config itself tracked in dotfiles. Since Claude Code's `user` scope for MCP servers is only ever backed by `~/.claude.json` (confirmed against current docs — no alternate file or env var), the fix is to track just the `mcpServers` object in a small dotfiles-managed file and merge it into `~/.claude.json` on every container creation, rather than symlinking the whole file (which would clobber unrelated content).

**Files:**
- Create: `claude/mcp-servers.json`
- Modify: `devcontainer/agent/postCreate.sh`
- Modify: `devcontainer/README.md` (the "MCP servers" section added in Task 6 — replace "edit `~/.claude.json` by hand" with a description of this mechanism)

**Interfaces:**
- Consumes: nothing from earlier tasks besides the `mcpServers.everything` entry already validated manually in Task 5.
- Produces: nothing consumed by later tasks — this is the last task in the plan.

- [ ] **Step 1: Create the tracked MCP servers file**

```json
{
  "everything": {
    "command": "nc",
    "args": ["mcp-everything", "3001"]
  }
}
```
Save as `claude/mcp-servers.json`. Note this is just the *contents* of the `mcpServers` object (server-name keys directly at the top level), not wrapped in an outer `"mcpServers"` key — the merge step in Step 2 adds that wrapping.

- [ ] **Step 2: Add the merge step to `postCreate.sh`**

In `devcontainer/agent/postCreate.sh`, change:
```bash
mkdir -p "$CLAUDE_HOME"

if [ -d "$DOTFILES_CLAUDE" ]; then
    for f in "$DOTFILES_CLAUDE"/*; do
        ln -sf "$f" "$CLAUDE_HOME/$(basename "$f")"
    done
fi
```
to:
```bash
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
    jq --slurpfile mcp "$MCP_SERVERS_FILE" \
        '.mcpServers = ((.mcpServers // {}) + $mcp[0])' \
        "$CLAUDE_JSON" > "$CLAUDE_JSON.tmp"
    mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
fi
```

- [ ] **Step 3: Verify the merge locally, without a full container rebuild**

Run (adjust paths to match a scratch copy so this doesn't touch your real `~/.claude.json` yet):
```bash
mkdir -p /tmp/mcp-postcreate-test
echo '{"otherField": "should-survive", "mcpServers": {"stale": {"command": "old"}}}' > /tmp/mcp-postcreate-test/claude.json
jq --slurpfile mcp claude/mcp-servers.json \
    '.mcpServers = ((.mcpServers // {}) + $mcp[0])' \
    /tmp/mcp-postcreate-test/claude.json
```
Expected: prints JSON with `"otherField": "should-survive"` untouched, `"mcpServers"` containing both the original `"stale"` entry and the new `"everything"` entry (last-write-wins per key, both present here since the keys differ).

- [ ] **Step 4: Rebuild the agent container and confirm the real `~/.claude.json` got merged correctly**

Ask the user to run `claude-devcontainer-rebuild` (same caveat as Task 5 — this recreates the container this session may be running in), then, from a shell in the rebuilt container: `jq '.mcpServers' ~/.claude.json`.
Expected: contains the `everything` entry, and any other pre-existing top-level keys in `~/.claude.json` (e.g. `projects`, `numStartups`, etc.) are still present and unchanged.

- [ ] **Step 5: Update the Task 6 README section to describe the automated mechanism**

In `devcontainer/README.md`, change the "To add a new MCP server" paragraph (added in Task 6) from documenting a manual edit:
```
To add a new MCP server: add a `devcontainer/mcp-<name>/Dockerfile` following
the `mcp-everything` pattern, add a matching service to the top-level
`docker-compose.yml` on the `mcp-net` network, and add an entry under
`mcpServers` in your `~/.claude.json` — this file is bind-mounted directly
from the host today rather than managed through the `~/.dotfiles/claude/`
symlink mechanism that handles the rest of `~/.claude/`, so edit it by hand:
```json
"mcpServers": {
  "everything": {
    "command": "nc",
    "args": ["mcp-everything", "3001"]
  }
}
```
```
to:
```
To add a new MCP server: add a `devcontainer/mcp-<name>/Dockerfile` following
the `mcp-everything` pattern, add a matching service to the top-level
`docker-compose.yml` on the `mcp-net` network, and add an entry to
`claude/mcp-servers.json` (tracked in this dotfiles repo). `postCreate.sh`
merges that file's contents into the `mcpServers` key of `~/.claude.json` on
every container creation, via `jq`, without disturbing the rest of that
file's content — `~/.claude.json` itself stays untracked (it accumulates
session/project state you don't want versioned), while the MCP server list
stays under version control.
```

- [ ] **Step 6: Commit**

```bash
git add claude/mcp-servers.json devcontainer/agent/postCreate.sh devcontainer/README.md
git commit -m "$(cat <<'EOF'
Wire mcpServers into ~/.claude.json via a tracked file + jq merge

~/.claude.json holds a lot of session/project state we don't want
version-controlled, but the mcpServers config itself should be tracked
in dotfiles. postCreate.sh now merges claude/mcp-servers.json into the
mcpServers key of ~/.claude.json on every container creation, without
touching the rest of that file's content.
EOF
)"
```
