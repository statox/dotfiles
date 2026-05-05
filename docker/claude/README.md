# Docker Claude Code Isolation

## What works

- `c` alias launches the container from any directory
- The container starts and Claude Code runs
- All config files are bind-mounted from the dotfiles repo:
  - `~/.dotfiles/claude/CLAUDE.md` → `/home/dev/.claude/CLAUDE.md` (ro)
  - `~/.dotfiles/claude/settings.json` → `/home/dev/.claude/settings.json` (ro)
  - `~/.dotfiles/claude/bell.wav` → `/home/dev/.claude/bell.wav` (ro)
  - `~/.dotfiles/claude/statusline-command.sh` → `/home/dev/.claude/statusline-command.sh` (ro)
  - `~/.dotfiles/config/nvim/` → `/home/dev/.config/nvim/` (ro)
- `--rebuild` flag triggers a fresh image build

## Known issue: first-run setup screen on every launch

Every time the container starts, Claude Code shows the setup screen (theme
selection + authentication), even though the credentials file is mounted.

**Observed behaviour:** When connecting to a running container with a shell
(`docker exec -it <id> bash`) and launching `claude` manually, the setup screen
appears on the first invocation but not on subsequent ones within the same
container session. This means Claude Code writes some state to disk after the
first run - state that is lost when the ephemeral container exits.

The state that goes missing is likely one or both of:
- The OAuth session/refresh (Claude Code may need to write back a refreshed
  access token to `.credentials.json`)
- A "setup completed" flag stored somewhere under `~/.claude/`

## Root cause

The container is ephemeral (`--rm`). Any state Claude Code writes to
`~/.claude/` during its first run is discarded on exit. The credentials file is
mounted read-only, so token refresh writes also fail silently.

## Open questions / possible approaches

**Option A - Pass credentials as an env var**
Set `ANTHROPIC_API_KEY` at container launch time instead of mounting
`.credentials.json`. Sidesteps the read-only refresh problem but requires an
API key (not an OAuth token) and means managing the key securely.

**Option B - Make credentials writable**
Mount `.credentials.json` as read-write. Token refreshes work and persist back
to the host. Risk: the container can overwrite the host credentials file.
Mitigation: acceptable given it's the same user on the same machine.

**Option C - Named Docker volume for ~/.claude state**
Mount a named volume at `/home/dev/.claude/` for the mutable state (history,
cache, credentials), and overlay individual read-only config files on top.
Allows state to persist across container restarts without touching host files.
Problem: Docker does not support overlaying individual files on top of a volume
mount - files must be injected at image build time or via an entrypoint script.

**Option D - Entrypoint script that copies config into a writable directory**
Write a small entrypoint script that copies the read-only config files from the
mounts into a writable `~/.claude/` directory (backed by a named volume or
tmpfs), then execs `claude`. State persists within a named volume; config
changes from the dotfiles repo are picked up on each container start.
This is probably the cleanest long-term solution.
