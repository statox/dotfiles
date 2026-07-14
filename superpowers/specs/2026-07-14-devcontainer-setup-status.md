# Dev Container setup for Claude Code — Status & Handoff

This picks up after the setup in `2026-07-14-devcontainer-setup-design.md` (design) and
`2026-07-14-devcontainer-setup-plan.md`-equivalent (`superpowers/plans/2026-07-14-devcontainer-setup.md`,
the implementation plan) was built and debugged live against a real machine. Read those two first for
the original rationale; this doc covers what changed during real-world testing, what works today, and
the one significant known gap that should be fixed before `claude_docker/` is retired.

## What's built and working

Sound *and* desktop notifications both work end-to-end through the real `claude` alias (not just raw
`devcontainer`/`docker compose` calls) — verified by triggering actual Claude Code `Notification`/`Stop`
hooks inside a running agent container, in a single workspace.

Repo layout (`~/.dotfiles/devcontainer/`):

```
devcontainer/
├── devcontainer.json          # agent config: build + mounts + runArgs (no Compose), postCreateCommand, updateRemoteUserUID
├── agent/
│   ├── Dockerfile             # Ubuntu 24.04, Claude Code, git, glab, uv, socat, etc.
│   └── postCreate.sh          # symlinks ~/.dotfiles/claude/* into ~/.claude (replaces old entrypoint.sh)
├── broker/
│   ├── docker-compose.yml     # global singleton compose project, restart: unless-stopped
│   ├── Dockerfile             # minimal: dbus, libnotify-bin, pulseaudio-utils, socat, util-linux
│   └── handle-notify.sh       # parses type|message off the socket, fires paplay + notify-send
└── scripts/
    ├── claude-devcontainer          # the `claude` alias target: brings up broker, then devcontainer up + exec
    └── claude-devcontainer-compose  # broker-only diagnostic wrapper (logs, exec, ps, down)
```

`claude/bell-notify.sh` (in the main dotfiles `claude/` dir, alongside `settings.json`) is the client:
Claude Code's `Notification`/`Stop` hooks call it, it speaks `type|message` over
`UNIX-CONNECT:/run/broker/notify.sock`.

Host aliases (`bash_aliases`):
```
alias devcontainer="npx @devcontainers/cli"
alias claude="$HOME/.dotfiles/devcontainer/scripts/claude-devcontainer"
```

## Non-obvious fixes discovered during live testing

These are all committed already (see `git log` for the individual commits), but the *reasons* are worth
keeping around since they're easy to accidentally regress:

1. **`npx devcontainer` is not `npx @devcontainers/cli`.** The former resolves to an unrelated npm
   package (`devcontainer@0.3.0`) that has no usable bin, and fails with "could not determine executable
   to run". Always invoke `npx @devcontainers/cli` (or the `devcontainer` alias, which does this).

2. **`docker-compose.yml` referenced via `dockerComposeFile` gets no devcontainer-spec variable
   substitution.** The devcontainer CLI hands the file straight to `docker compose ... config`, which
   only understands plain Compose interpolation (`${VAR}` from the process environment) — `${localEnv:HOME}`
   and `${localWorkspaceFolder}` are devcontainer.json-only syntax and error out inside a compose file.
   Fix: use plain `${HOME}`, and export `WORKSPACE_FOLDER`/`DEV_UID` yourself before invoking the CLI
   (`claude-devcontainer` does this).

3. **`~` expands on the host shell, not inside the container**, when passed unquoted as a `devcontainer exec`
   argument (e.g. `devcontainer exec ... bash ~/.claude/foo.sh` silently resolves `~` to your *host* home
   directory before the CLI ever sees it). Wrap anything using `~` in `bash -c '...'` (single-quoted) so
   expansion happens inside the container's own shell.

4. **The broker's Unix socket needs an explicit permissive mode.** `socat`'s default `UNIX-LISTEN` socket
   permissions don't grant the agent's non-root user write/connect access (owner-only by default in
   practice). Fixed via `UNIX-LISTEN:...,mode=777` in `broker/Dockerfile`'s `CMD`. The socket lives in a
   private volume shared only by `agent`/`broker`, so world-writable is fine there.

5. **The broker must run as your host UID, not root**, for D-Bus. `docker-compose.yml`'s
   `services.broker.user: "${DEV_UID}"`. The systemd session bus at `/run/user/<uid>/bus` authenticates by
   peer UID (`SO_PEERCRED`) and rejects root outright ("The connection is closed"), even though the socket
   path itself is reachable. Because Docker only applies an image directory's permissions to a *named
   volume* the first time that volume is created, changing this after the fact also requires removing the
   stale `broker-sock` volume once (`docker volume rm devcontainer_broker-sock`) — a rebuild alone doesn't
   fix already-existing volume ownership.

6. **Ubuntu 23.10+/24.04 added AppArmor userspace mediation for D-Bus.** Even with the correct UID, the
   host's `dbus-daemon` blocks messages from processes running under Docker's default confined AppArmor
   profile ("An AppArmor policy prevents this sender..."). Fixed via `security_opt: [apparmor:unconfined]`
   on the `broker` service only (not `agent`).

7. **`socat`'s `fork` mode kills the connection handler (and anything still attached to it) as soon as the
   client closes its end** — which happens immediately, since `bell-notify.sh` just pipes one line in and
   exits. `paplay` is fast enough to usually win that race; `notify-send`'s D-Bus round trip usually isn't,
   so sound would play but no notification would appear, with no error anywhere (silent failure). Fixed by
   having `handle-notify.sh` detach the actual work via `setsid sh -c '...' &`, so it survives past the
   parent process's teardown. This was the last fix and is what got the full round trip working.

8. **`devcontainer.json`'s `build.dockerfile` path is resolved relative to the folder containing
   `devcontainer.json` itself, not relative to `build.context`.** Setting `"dockerfile": "Dockerfile"` with
   `"context": "agent"` looked plausible but made the CLI look for `devcontainer/Dockerfile` (which doesn't
   exist) instead of `devcontainer/agent/Dockerfile`. This didn't surface immediately — a stale cached image
   from earlier testing (same content hash, different tag) let the first `up` "succeed" without ever
   re-reading the Dockerfile. It only broke on a workspace whose image tag hadn't been built yet. Fixed by
   setting `"dockerfile": "agent/Dockerfile"`.

9. **Compose namespaces volume names with the project name by default, even for a single-service project.**
   `broker/docker-compose.yml`'s bare `broker-sock:` volume became `broker_broker-sock` (project name
   derived from the `broker/` directory), a *different* volume than the plain `broker-sock` the agent's
   `devcontainer.json` mounts referenced directly by name. Both sides "worked" (no error, socket directory
   existed in both containers) but the socket file itself only ever appeared in the broker's copy — the
   agent's side was silently a different, empty volume. Fixed by pinning `name: broker-sock` on the volume
   in `broker/docker-compose.yml`, overriding Compose's implicit prefixing.

## Known gap: compose project name isn't workspace-scoped — FIXED

See `superpowers/specs/2026-07-14-devcontainer-workspace-scoping-design.md` (design) and
`superpowers/plans/2026-07-14-devcontainer-workspace-scoping.md` (implementation plan) for the full
rationale. Summary: `agent` no longer uses Compose at all (so the devcontainer CLI's own built-in
per-workspace container naming applies, sidestepping Compose's project-naming rules entirely); `broker`
became a separate, global-singleton Compose project (`restart: unless-stopped`), shared by every workspace.
Live-verified: two workspaces running `agent` concurrently, distinct containers, no collision, notifications
working from both. `claude_docker/` can now be retired (separate, explicit step — see below).

The section below is kept for historical context (why this was hard, what was tried).

`docker-compose.yml` lives at a fixed path (`~/.dotfiles/devcontainer/`), and Docker Compose derives its
project name from the compose file's *own* directory name by default — not from
`--workspace-folder`/`${WORKSPACE_FOLDER}`. Confirmed empirically: `devcontainer up` reported
`"composeProjectName":"devcontainer"` identically whether invoked from `~/.dotfiles` or
`~/dev/monorepo`. That means every workspace maps to the *same* container names
(`devcontainer-agent-1`, `devcontainer-broker-1`).

Symptom: running `claude` from a second, different repo after already having one running elsewhere fails:

```
[233 ms] Start: Run: docker compose -f /home/adrien/.dotfiles/devcontainer/docker-compose.yml --profile * config
{"outcome":"success", ..., "composeProjectName":"devcontainer", ...}
[148 ms] Error: Dev container not found.
```

The CLI finds the existing `agent` container (still configured for the *first* workspace's bind mount)
and doesn't recognize it as belonging to the newly requested workspace, so it refuses to attach — it
doesn't automatically tear down and recreate.

### The constraint that makes this non-trivial

- `agent` **must** be workspace-scoped — it bind-mounts a specific repo and can't be shared across repos.
- `claude-home` and `glab-config` **must not** be workspace-scoped — they're deliberately global/shared
  Claude Code session state and `glab` credentials, meant to persist identically across every repo you
  use `claude` in (this is the existing, pre-devcontainer behavior from `claude_docker/run.sh` too).
- `broker` is arguably fine either way — either one global long-lived instance shared by all workspaces,
  or recreated per-workspace (wastes a little startup time, but it's a tiny image).

A single undifferentiated compose project can't satisfy "some services workspace-scoped, others global"
at the same time under Docker Compose's naming model — project name determines *all* resource naming
(containers, and non-`external` volumes) uniformly.

## Cleanup still pending

- `claude_docker/` (the old setup) is still present and untouched. The workspace-scoping gap is now fixed
  and re-verified, so retiring it is unblocked — but do it as an explicit, separate step, not bundled into
  other changes.
- The old `devcontainer_claude-home`, `devcontainer_glab-config`, `devcontainer_broker-sock`, and
  `broker_broker-sock` volumes are orphaned leftovers from previous setups/testing. Safe to remove manually
  (`docker volume rm ...`) whenever convenient — nothing references them anymore.

## How to test any future changes

The debugging cycle that got this working (see commits `16a99c0` through `ebd45f5`) all followed the same
loop, useful to repeat for the workspace-scoping fix too:

```bash
export DEV_UID
DEV_UID="$(id -u)"
docker compose -f "$HOME/.dotfiles/devcontainer/broker/docker-compose.yml" up -d --wait

WORKSPACE_FOLDER=<some-workspace-path>
mkdir -p "$WORKSPACE_FOLDER/.venv-claude"
devcontainer up --workspace-folder "$WORKSPACE_FOLDER" --config "$HOME/.dotfiles/devcontainer/devcontainer.json"
devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" --config "$HOME/.dotfiles/devcontainer/devcontainer.json" \
  bash -c 'bash ~/.claude/bell-notify.sh done "test"'
```

Prefer writing multi-line test sequences into a throwaway script file (e.g. `/tmp/dc-test.sh`) rather than
pasting multi-line `\`-continued commands directly into the terminal — line-wrapping during copy/paste
reliably breaks continuations and produces confusing, unrelated-looking errors (this happened repeatedly
during this session).
