# MCP server container: design spec

Date: 2026-07-16

## Goal

Add a containerized MCP server to the devcontainer setup, as a test of running
MCP servers isolated from the agent container, reachable over the network
rather than run as a subprocess of the agent. Use
`@modelcontextprotocol/server-everything` (the MCP reference/test server) as
the test case: it is stateless, needs no credentials, filesystem access, or
per-repo configuration, and exposes simple, deterministic tools (`echo`,
`add`) that make end-to-end validation unambiguous.

## Non-goals

- Routing MCP traffic through the broker. The broker remains
  notification-only; this design bypasses it entirely for MCP traffic.
- Per-repo MCP server instances. `mcp-everything` is a global singleton,
  matching the broker's lifecycle model, since it holds no per-repo state.
- Filesystem-backed or credentialed MCP servers (e.g. the filesystem server,
  Notion, 1Password). Those need per-repo scoping or secret handling this
  design does not address; `server-everything` was chosen specifically to
  defer that complexity.
- Changing the broker's networking (`network_mode: host` stays, for
  PulseAudio/D-Bus access — unrelated to this change).

## Architecture

One merged docker-compose stack (`broker` + `mcp-everything`) replaces the
broker-only one. `mcp-everything` is a global singleton, stateless MCP
reference server, reachable by DNS name over a dedicated bridge network
(`mcp-net`). The agent container drops `--network=host` and joins `mcp-net`
instead, so it can resolve `mcp-everything` by service name. Claude Code
talks to it using the standard stdio MCP transport, bridged over TCP via `nc`
(client side, inside the agent container) and `socat` (server side, inside
the `mcp-everything` container, wrapping the actual stdio process). The
broker is untouched — still host-networked, still notification-only — just
co-located in the same compose file so there is a single lifecycle command
for both.

## Components

1. **`devcontainer/docker-compose.yml`** (moved from
   `devcontainer/broker/docker-compose.yml`) — two services:
   - `broker`: unchanged configuration, `build.context: ./broker`.
   - `mcp-everything`: `build.context: ./mcp-everything`, `restart: unless-stopped`,
     attached to the `mcp-net` network.
   - Declares the `mcp-net` bridge network with a fixed `name:` (so the
     agent's `--network=mcp-net` runArg resolves it, the same reasoning the
     existing `broker-sock` volume's fixed name already follows), alongside
     the existing `broker-sock` volume declaration.

2. **`devcontainer/mcp-everything/Dockerfile`** (new — named per-server rather
   than a generic `mcp/`, so future servers each get their own sibling
   directory, e.g. `devcontainer/mcp-notion/`, without reshuffling this one):
   ```dockerfile
   FROM node:22-alpine

   RUN apk add --no-cache socat

   RUN npm install -g @modelcontextprotocol/server-everything

   RUN addgroup -S mcp && adduser -S mcp -G mcp -u 1000
   USER mcp

   EXPOSE 3001
   CMD ["socat", "TCP-LISTEN:3001,fork,reuseaddr", "EXEC:mcp-server-everything"]
   ```
   The exact CLI binary name exposed by `@modelcontextprotocol/server-everything`
   needs to be confirmed against the published package during implementation
   (assumed `mcp-server-everything`).

3. **`devcontainer/broker/`** — unchanged, apart from now being a sibling
   build context referenced by the top-level compose file instead of owning
   its own compose file.

4. **`devcontainer.json`** — `runArgs: ["--network=host"]` becomes
   `runArgs: ["--network=mcp-net"]`. No other changes (mounts, features,
   `workspaceMount` all stay as-is).

5. **Scripts** (`claude-devcontainer`, `code-devcontainer`,
   `claude-devcontainer-rebuild`) — each already has one
   `docker compose -f .../broker/docker-compose.yml up -d --wait` line;
   repoint it at `devcontainer/docker-compose.yml`. No duplication — one
   `up -d --wait` still brings up both services.

6. **`claude-devcontainer-compose`** — `-f` path repointed to the new file
   location. No new wrapper script needed; `... ps` / `... logs -f
   mcp-everything` work against the merged file same as today.

7. **Documentation only — no file in this repo is wired up automatically.**
   `claude/.claude.json` today is disconnected from what's actually live in
   the container (`devcontainer.json` bind-mounts the host's plain
   `$HOME/.claude.json`, bootstrapped empty by the launch scripts if
   missing — it does not come from this repo). Rather than fix that wiring
   as part of this change, this design just documents the entry to add
   manually to your real `~/.claude.json`:
   ```json
   "mcpServers": {
     "everything": {
       "command": "nc",
       "args": ["mcp-everything", "3001"]
     }
   }
   ```
   This lives in the implementation's README/notes, not as a repo file
   change. Revisit wiring `~/.claude.json` through the dotfiles mechanism as
   a separate, later change if desired.

## Data flow

Claude Code spawns `nc mcp-everything 3001` as the MCP server's stdio child
process → `nc` opens a TCP connection over `mcp-net` to the `mcp-everything`
container → `socat`'s listener forks a handler that execs
`mcp-server-everything`, wiring the TCP socket directly to that process's
stdin/stdout → JSON-RPC MCP protocol frames flow transparently through the
whole chain in both directions. One long-lived connection per Claude Code
session (not one per tool call) — `nc` and `socat` are not MCP-aware, they
are just a byte pipe; framing and protocol semantics are entirely handled by
Claude Code and `mcp-server-everything` at the two ends.

## Error handling

No custom error handling is introduced — this relies on existing tool
semantics:

- If `mcp-everything` is down or unreachable, `nc` fails to connect and
  Claude Code reports the MCP server as unreachable at session start, the
  same as a misconfigured local command would.
- `docker compose up -d --wait` combined with the existing
  bring-up-stack-before-create-agent-container ordering avoids a race where
  the agent container is created before `mcp-net` exists.
- Because `nc` holds a single connection open for the life of the Claude
  Code session, restarting `mcp-everything` (e.g.
  `docker compose up -d --force-recreate mcp-everything`) breaks any
  already-open session's connection. This is expected and is one of the
  validation steps below, not a case this design handles gracefully.

## Testing / validation

1. `docker compose up -d --wait` brings up both services; confirm both are
   `Running` / healthy.
2. From inside the agent container, manually `nc mcp-everything 3001` and
   confirm the connection opens (no "connection refused").
3. With the `mcpServers.everything` entry in place, start Claude Code in the
   agent container and confirm the `everything` server shows connected.
4. Call the `echo` tool with a test string and confirm the exact string
   round-trips through the full chain.
5. Restart `mcp-everything` mid-session and confirm the expected failure
   mode (broken connection, requiring a new Claude Code session) rather than
   a silent hang.
6. Confirm nothing that previously relied on the agent container's
   `--network=host` (e.g. reaching services on `localhost` from inside the
   agent) breaks now that it's on `mcp-net` instead.
