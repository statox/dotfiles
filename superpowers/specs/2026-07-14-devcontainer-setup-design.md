# Dev Container setup for Claude Code — Design

## Goals

- Replace the current hand-rolled `claude_docker/` (Dockerfile + `build.sh`/`run.sh`) with a
  [Dev Containers](https://containers.dev/) based setup, invoked via `devcontainer` (aliased to
  `npx devcontainer` on the host).
- Keep the base configuration versioned in this dotfiles repo, reusable across arbitrary target
  repos without writing anything into those repos.
- Leave a clear seam for per-repo extensibility (installing repo-specific tools in the agent
  container) as a future iteration — not built now.
- Replace the current host-integration hacks (`paplay`/`notify-send` hooks, which don't work
  from inside a container) with a small, tightly-scoped **broker container** that holds the only
  host-facing permissions needed, inspired by the socat-based MCP-forwarding pattern described in
  Dashlane's engineering blog post on sandboxing AI coding tools. The agent container itself gets
  no direct access to host audio/notification facilities.
- Keep both containers as constrained as possible: the agent has no elevated host access beyond
  what it already needs (workdir, git credentials, persisted Claude state); the broker has host
  access but no workdir, no git credentials, no Claude state.

## Non-goals (this iteration)

- Per-repo compose overrides / repo-specific tool installation — the seam is documented below but
  not implemented.
- An MCP-forwarding broker — the notification broker validates the pattern; a future MCP broker
  reuses it as a separate service.
- Moving `glab`/`.netrc`/`.claude.json` credential mounts out of the agent container into a
  broker — unchanged from today.
- Removing `network_mode: host` from the agent container — kept for now because corporate GitLab
  is only reachable via a host-routed VPN. This is a known, temporary compromise; the intent is to
  eventually move VPN/GitLab access into its own dedicated container that the agent reaches the
  same way it reaches the notification broker, so the agent can drop host networking entirely.

## Repo layout

```
devcontainer/
├── devcontainer.json          # references docker-compose.yml, workspaceFolder, remoteUser, postCreateCommand
├── docker-compose.yml         # defines `agent` and `broker` services
├── agent/
│   └── Dockerfile             # today's claude_docker/Dockerfile, minus the custom ENTRYPOINT
├── broker/
│   ├── Dockerfile             # minimal image: socat, libnotify-bin, pulseaudio-utils, dbus
│   └── handle-notify.sh       # parses a request off the socket and fires paplay/notify-send
└── scripts/
    └── claude-devcontainer    # wrapper: `devcontainer up`/`exec` with --config pointed at this dir
```

`claude_docker/` (Dockerfile, build.sh, run.sh, entrypoint.sh) is retired — the devcontainer CLI
handles build, run, and exec, and `postCreateCommand` replaces `entrypoint.sh`'s symlink step.

`claude/` keeps its role as the versioned Claude Code config (settings.json, CLAUDE.md,
statusline-command.sh, bell.wav), plus one new file: `claude/bell-notify.sh`.

## Invocation

Given `alias devcontainer='npx devcontainer'` on the host, config resolution always points at the
dotfiles repo rather than the target repo:

```sh
devcontainer up   --workspace-folder "$(pwd)" --config ~/.dotfiles/devcontainer/devcontainer.json
devcontainer exec --workspace-folder "$(pwd)" --config ~/.dotfiles/devcontainer/devcontainer.json zsh
```

`devcontainer/scripts/claude-devcontainer` wraps both calls into a single command, mirroring what
`run.sh` did today. Nothing is written into the target repo.

## Container architecture

Both services use `network_mode: host` (see Non-goals above for why, and the planned follow-up).

### `agent` service

- Image: today's `agent/Dockerfile` (Ubuntu 24.04, Claude Code, git, glab, uv, etc.), unchanged
  except the custom `ENTRYPOINT` is removed — devcontainer CLI manages the container's lifecycle,
  and the dotfiles-symlink step moves to `postCreateCommand` in `devcontainer.json`.
- Mounts:
  - workspace folder → `/workdir` (handled by the devcontainer CLI itself)
  - `claude-home` volume → `/home/dev/.claude` (unchanged)
  - `glab-config` volume → `/home/dev/.config/glab-cli` (unchanged)
  - per-repo `.venv-claude` → `/workdir/.venv` (unchanged)
  - `~/.dotfiles`, `~/.claude.json`, `~/.netrc` bind mounts (unchanged)
  - **new:** `broker-sock` volume → `/run/broker` (holds only the notification Unix socket)
- Explicitly does **not** mount PulseAudio's socket, D-Bus's session socket, or anything else
  needed for host notifications — that access lives only in `broker`.

### `broker` service

- New, minimal image (`broker/Dockerfile`): `socat`, `libnotify-bin`, `pulseaudio-utils`, `dbus`.
- Mounts:
  - `broker-sock` volume → `/run/broker`
  - host's PulseAudio socket (`$XDG_RUNTIME_DIR/pulse`) and D-Bus session socket, read-write
  - `claude/` (or the `claude-home` volume) mounted **read-only**, so `handle-notify.sh` can find
    `bell.wav` without duplicating it into the broker image
  - nothing else: no workspace, no git credentials, no `.claude.json`
- Runs as the host UID (`user: "${DEV_UID}"` in compose), not root — the systemd D-Bus session
  bus authenticates by peer UID and rejects root, even though the socket path is reachable.
- Runs unconfined (`security_opt: apparmor:unconfined`) — Ubuntu's AppArmor userspace mediation
  for D-Bus blocks the session bus from Docker's default confined profile regardless of UID.
- Foreground process: `socat UNIX-LISTEN:/run/broker/notify.sock,fork,unlink-early,mode=777
  EXEC:/usr/local/bin/handle-notify.sh`. The container's only job is running this listener.

This gives the intended isolation: only `broker` can make sound or raise a host notification, and
its attack surface is "parse a small message off a socket." A fully compromised `agent` container
still cannot reach PulseAudio or D-Bus directly.

## Notification protocol

Newline-delimited, two fields: `type|message`, e.g. `waiting|Waiting for input` or `done|Done`.
Deliberately simple; extensible later (e.g. adding a `title` field) without a breaking change,
since `handle-notify.sh` can default missing fields.

- `claude/bell-notify.sh` (new, versioned alongside `bell.wav`):

  ```sh
  #!/bin/bash
  # $1=type $2=message
  echo "${1}|${2}" | socat - UNIX-CONNECT:/run/broker/notify.sock
  ```

  Guards against running outside the devcontainer (no `socat`, or the socket doesn't exist) by
  checking both before attempting to connect, so hooks degrade to a silent no-op on bare-host
  Claude Code sessions rather than erroring.

- `claude/settings.json` hooks updated:
  - `Notification` → `bash ~/.claude/bell-notify.sh waiting "Waiting for input"`
  - `Stop` → `bash ~/.claude/bell-notify.sh done "Done"`

- `broker/handle-notify.sh` reads the line, splits on `|`, then runs `paplay`/`notify-send`
  (icon/urgency derived from `type`) detached via `setsid ... &`. This detachment is required,
  not cosmetic: `socat` tears down the forked connection handler as soon as the client (a single
  short-lived `socat` invocation from `bell-notify.sh`) closes its end, which happens immediately
  after sending its one line. `paplay` usually finishes before that teardown; `notify-send`'s
  D-Bus round trip usually doesn't, so without detaching, the sound plays but the desktop
  notification silently never fires.

## Extensibility seam (future iteration, not built now)

`devcontainer.json`'s `dockerComposeFile` field accepts an array of compose files, merged in
order. The future per-repo extension mechanism is to append a repo-local override file, e.g.:

```json
"dockerComposeFile": [
  "~/.dotfiles/devcontainer/docker-compose.yml",
  "${localWorkspaceFolder}/.devcontainer/compose.override.yml"
]
```

when such a file exists in the target repo. Nothing needs to change in the base setup to support
this later — it's called out here so the seam isn't rediscovered from scratch.

## Future MCP broker

The same shared-Unix-socket-over-volume pattern (dedicated minimal container, socket in its own
named volume, `agent` never gets the host access directly) generalizes to an `mcp-broker` service
for forwarding MCP traffic, following the isolation approach described in Dashlane's write-up on
sandboxing AI coding tools (dev containers + `socat`-forwarded traffic keeping credentials off the
agent). Not built in this iteration.

## Testing / verification plan

- `devcontainer up` succeeds against a throwaway repo using `--config` pointed at the dotfiles
  path; both `agent` and `broker` services come up.
- From inside `agent`, `bash ~/.claude/bell-notify.sh done "test"` produces an audible bell and a
  host notification (manual check — no automated test for host-visible side effects).
- Confirm `agent` has no access to `$XDG_RUNTIME_DIR/pulse` or the D-Bus session socket (e.g. the
  paths aren't mounted, and `notify-send`/`paplay` aren't installed in the `agent` image at all).
- Confirm existing behavior is preserved: `claude-home`/`glab-config` persistence across
  `devcontainer up` runs, dotfiles-managed `claude/` files symlinked into `~/.claude` via
  `postCreateCommand`, git/glab credentials usable inside `agent`.
- Running Claude Code hooks on the bare host (no devcontainer) does not error, per the guard in
  `bell-notify.sh`.
