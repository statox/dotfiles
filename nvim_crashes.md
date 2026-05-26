# How I tried to debug nvim crashes

## Symptoms

neovim crashes ~once a week with this type of error

```
:[1]    213332 bus error (core dumped)  nvim
```

## Attempt 1 - Keep cores

core dumps enabled via `/etc/security/limits.conf` adding the line `afabre soft core unlimited`
To debug nvim bus error crashes - see /var/crash/ after a crash

=> But `/var/crash` was never populated

Two issues:

The real blocker: Apport (your crash handler, see core_pattern) silently ignores crashes from non-packaged binaries. Your nvim is at /home/afabre/.bin/nvim and is not from a dpkg package — apport sees it,
shrugs, and writes nothing.

Your `limits.conf` change is working (`ulimit -c = unlimited`), but it's irrelevant — apport intercepts the crash via the kernel pipe (|/usr/share/apport/apport ...) before any file is written.

Secondary issue: pam_limits is not in /etc/pam.d/common-session, only in GDM/login/ssh sessions. Terminal emulator sessions may inherit limits from systemd, not PAM. But again, this isn't the actual blocker.


## Attempt 2 - Fix core dump capture permanently

Switch from apport to file-based dumps persistently:

# Create a cores directory
```
sudo mkdir -p /var/cores
sudo chmod 1777 /var/cores
```

# Persist the core_pattern (survives reboots, overrides apport)

Recommended by LLM:

```
echo 'kernel.core_pattern=/var/cores/core.%e.%p.%t' | sudo tee /etc/sysctl.d/99-coredump.conf
sudo sysctl -p /etc/sysctl.d/99-coredump.conf
```

But `/etc/sysctl.d/99-coredump.conf` is symlinked to `/etc/sysctl.conf`
So I edited this file and ran `sudo sysctl -p /etc/sysctl.conf`

```
cat /proc/sys/kernel/core_pattern
```
=> This displays `/var/cores/core.%e.%p.%t`

This means next time nvim crashes, `/var/cores/core.nvim.<pid>.<timestamp>` will appear.

I also added `export NVIM_LOG_FILE=~/.local/state/nvim/nvim.log` to my zshrc

# Confirm

When I'll get a core in `/var/cores` analyze it with:

```
gdb ~/.bin/nvim /var/cores/core.nvim.*
(gdb) bt full
```

The log file `~/.local/state/nvim/nvim.log` should capture errors right before the crash, which often reveals the guilty plugin or filetype.

For the SIGBUS itself — once you have a backtrace, look for treesitter in the stack. SIGBUS in static-pie nvim binaries is most commonly a treesitter parser doing an out-of-bounds read on a specific filetype.
You can also check :checkhealth for any warnings about parsers.
