# systemd user services

Services here run as the current user (`systemctl --user`), no root required.

## Files

A service typically requires two files:

- `user/<name>.service` — what to run (`ExecStart=`, `Type=oneshot` for scripts)
- `user/<name>.timer` — when to run it:
  - `OnBootSec=` — delay after boot before the first run (e.g. `1min`)
  - `OnUnitActiveSec=` — interval between subsequent runs (e.g. `5min`)

See `man systemd.timer`

## Managing a service

```bash
systemctl --user stop <name>.timer      # stop the timer (service won't be triggered anymore)
systemctl --user start <name>.timer     # start it again
systemctl --user start <name>.service   # run the service immediately (for testing)


systemctl --user status <name>.timer    # timer schedule and last trigger
systemctl --user status <name>.service  # last run exit code and output
journalctl --user -u <name>.service     # full logs
```

## Adding a new service

1. Create `user/<name>.service` and `user/<name>.timer` in this directory
2. Register both in `scripts/files_list` so they get symlinked to `~/.config/systemd/user/`
3. Update `set-dotfiles.sh` to run the command to enable the timer once:

```bash
systemctl --user enable --now <name>.timer
```

The timer triggers the service automatically — no need to enable the service separately.

## Removing a service

1. Disable and stop the timer:

```bash
systemctl --user disable --now <name>.timer
```

2. Remove the unit files from `user/` and from `scripts/files_list`
3. Delete the symlinks from `~/.config/systemd/user/`
4. Reload systemd:

```bash
systemctl --user daemon-reload
```

## Updating a service

When the service runs a script like `monitor_battery.service` the system doesn't automatically reload
the changes in the script. One need to run the following to test:

```bash
systemctl --user daemon-reload
```
