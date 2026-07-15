# Claude devcontainer setup

A per-repo development container for running Claude Code, with a small always-on
"broker" container that gives it a safe, narrow path to host resources.

## Goals

- **Per-repo agent container.** Every repo gets its own container (`agent`), scoped
  to that repo's workspace folder, so Claude only ever sees the path it was started
  in — not the rest of the host filesystem.
- **A broker for host access.** The `agent` container has no direct access to the
  host. Anything it needs from the host goes through `broker`, a separate,
  minimal, global-singleton container (one broker for all workspaces), reached
  over a Unix socket shared via a Docker volume.
  - **Today:** the broker forwards desktop notifications (sound + `notify-send`)
    so Claude can nudge you when it needs input or finishes a task, without the
    agent container needing PulseAudio/D-Bus access itself.
  - **Tomorrow:** the same pattern generalizes to an MCP broker, forwarding MCP
    traffic via `socat` so credentials/tools stay off the agent container and
    are mediated at a single, auditable point (see "Future MCP broker" below).
- **One command to get in.** A shell alias (`claude`) wraps the whole flow —
  bring up the broker, bring up/reuse the per-repo agent container, drop you into
  a shell in it — so day-to-day use is just `cd <repo> && claude`.
- **Devcontainer features for the dev environment, the agent Dockerfile for the
  rest.** Standard tooling (GitHub CLI, `uv`, Node, the `claude` binary itself)
  is installed via devcontainer features in `devcontainer.json` — that's the
  preferred path since it's declarative and versioned in
  `devcontainer-lock.json`. For anything without a feature (e.g. `vim`,
  `ripgrep`, `glab`), it's installed directly in `agent/Dockerfile` instead. See
  "Updating the setup" below for when to use which.
- **Your Claude Code customizations, shared across every repo.** `~/.dotfiles/claude/`
  (see "Claude Code customizations" below) holds your personal `CLAUDE.md`,
  `settings.json`, hooks, and statusline script, symlinked into every agent
  container so they're consistent everywhere and edit-in-place from the host.

## Architecture

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
│       ├── claude-devcontainer-compose    <- thin `docker compose` wrapper for the broker project
│       └── claude-devcontainer-rebuild    <- force a clean rebuild of the agent image/container
│
├── <repo>/.venv-claude/               <- per-repo bind mount target for the agent's /workdir/.venv
│
└── docker volumes
    ├── claude-home    <- ~/.claude inside agent containers (session state, persists across repos)
    ├── glab-config    <- ~/.config/glab-cli inside agent containers
    └── broker-sock    <- /run/broker inside both agent and broker (the notify socket lives here)
```

**Two containers, two lifecycles:**

- `broker` is a **global singleton** — one instance total, shared by every repo's
  agent container, started via `docker compose` (`broker/docker-compose.yml`) and
  left running (`restart: unless-stopped`). It's the only container with
  host-facing access (`network_mode: host`, the host's PulseAudio/D-Bus sockets
  bind-mounted in, `apparmor:unconfined` because Ubuntu's AppArmor D-Bus mediation
  blocks the session bus otherwise). Its whole job is to sit on
  `UNIX-LISTEN:/run/broker/notify.sock` (via `socat`) and run `handle-notify.sh`
  for each connection.
- `agent` is **per-repo** — one instance per workspace folder, built from
  `agent/Dockerfile`, created/reused by the `devcontainers` CLI
  (`devcontainer.json`). It mounts the repo at `/workdir`, gets `broker-sock` so it
  can reach the broker's socket, but never touches the host directly.

**Notification flow (today's only broker traffic):** a Claude Code hook in the
agent container runs `bell-notify.sh <type> <message>`, which pipes
`type|message` into `UNIX-CONNECT:/run/broker/notify.sock`. The broker's `socat`
forks a handler running `handle-notify.sh`, which plays `bell.wav` and fires a
`notify-send` desktop notification on the host, detached via `setsid` so the
D-Bus round-trip survives `socat` tearing down the connection handler as soon as
the client disconnects.

**Future MCP broker:** the same pattern (dedicated minimal container, socket in
its own named volume, agent never gets host access directly) generalizes to an
`mcp-broker` service that forwards MCP traffic via `socat`, keeping credentials
and tool access off the agent container and mediated at one auditable point —
the isolation approach described in Dashlane's write-up on sandboxing AI coding
tools. Not built yet.

**Extensibility seam for per-repo customization (not built yet):**
`devcontainer.json`'s `dockerComposeFile` field accepts an array of compose
files merged in order, so a repo can later append its own
`.devcontainer/compose.override.yml` without any change to this base setup.

## Claude Code customizations (`~/.dotfiles/claude/`)

`~/.dotfiles/claude/` holds your personal Claude Code configuration, independent
of this devcontainer setup and shared with any bare-host (non-container) use of
Claude Code too:

- `CLAUDE.md` — your global instructions, active in every project.
- `settings.json` — permissions, hooks (wired to `bell-notify.sh`), statusline,
  theme, and other Claude Code settings.
- `bell-notify.sh` / `bell.wav` — the client half of the notification flow
  described above (see "Architecture"); invoked by the `Notification`/`Stop`
  hooks in `settings.json`.
- `statusline-command.sh` — the statusline script referenced by `settings.json`.
- `.claude.json` — other persisted Claude Code state.

`agent/postCreate.sh` symlinks every file under `~/.dotfiles/claude/` into
`~/.claude` (a named volume, `claude-home`) inside the agent container, on every
container creation. So editing a file under `~/.dotfiles/claude/` on the host
takes effect the next time a container is created or recreated — no rebuild
needed, and no copy to keep in sync since it's a symlink both ways.

## Using it: getting the CLI running

1. `cd` into the repo you want to work on.
2. Run `claude` (alias for `~/.dotfiles/devcontainer/scripts/claude-devcontainer`,
   set in `bash_aliases`).

That single command:
- brings up the global `broker` singleton if it isn't already running
  (`docker compose ... up -d --wait`);
- creates (or reuses) the `agent` container for the current workspace folder via
  `devcontainers/cli up`;
- execs a `bash` shell inside it (`devcontainers/cli exec`).

From that shell, run `claude` (the actual Claude Code binary — installed via the
`claude-code` devcontainer feature) as usual. Inside the container you have your
repo at `/workdir`, your dotfiles at `~/.dotfiles`, `gh`/`glab` for GitHub/GitLab,
and desktop notifications working through the broker.

To just inspect/manage the broker without going through the full flow:
```
claude-devcontainer-compose ps
claude-devcontainer-compose logs -f
claude-devcontainer-compose down
```

## Updating the setup

**Adding a new tool — features vs. `agent/Dockerfile`.** Prefer a devcontainer
feature when one exists for the tool (check
[containers.dev/features](https://containers.dev/features)) — that's how
GitHub CLI, `uv`, Node, and the `claude` binary itself are installed today
(`devcontainer.json`'s `features` block). It's declarative, versioned, and
maintained upstream. Fall back to adding it to `agent/Dockerfile` (a plain
`apt-get install`, like `vim`, `ripgrep`, `shellcheck`, `socat`, or `glab`
today) only when no feature exists for it.

**Add a devcontainer feature** (e.g. a new language runtime): edit the
`features` block in `devcontainer.json`, then rebuild (see below). Run
`npx @devcontainers/cli up ...` once normally afterwards to refresh
`devcontainer-lock.json` (feature version/integrity pins) — commit that file
alongside the `devcontainer.json` change.

**Add a tool to the agent image** (when no feature exists for it): edit
`agent/Dockerfile`, then rebuild.

**Change the broker** (new notification behavior, future MCP forwarding): edit
`broker/Dockerfile`, `broker/docker-compose.yml`, or `broker/handle-notify.sh`,
then recreate the broker:
```
claude-devcontainer-compose up -d --build --force-recreate
```

**Rebuild the agent container from scratch** (picks up Dockerfile/feature
changes that a plain `claude` run won't, since that reuses the existing
container): from the repo you want to rebuild,
```
claude-devcontainer-rebuild
```
This removes the existing container and rebuilds the image with `--no-cache`,
then drops you into a shell in the fresh container. Run it once per repo whose
agent container needs the update (each repo has its own container instance).

**Change what gets symlinked into `~/.claude`** (settings, hooks, statusline
script, etc.): edit the files under `~/.dotfiles/claude/`. They're re-symlinked
into the `claude-home` volume by `agent/postCreate.sh` on every container
creation, so a plain `claude` (which recreates the container if needed) or
`claude-devcontainer-rebuild` picks them up — no separate step required.
