# ssh — SSH login-shell shim for rootshell / remote herdr

Managed by [dotter](https://github.com/SuperCuber/dotter).

- `ssh-login-shell.sh` → `~/.local/bin/ssh-login-shell.sh`

## Purpose

SSH non-login shells skip `.zprofile`, so `~/.local/bin` (herdr) and
Homebrew are missing from PATH — `herdr` is "command not found" in
rootshell (iPhone) or any plain ssh session. This shim exports the full
PATH and execs `/bin/zsh -l`, making SSH sessions behave like local
login shells.

## Enable (one-time, needs sudo)

1. Add to `/etc/ssh/sshd_config` (back up first):

   ```
   ForceCommand /Users/jirathip/.local/bin/ssh-login-shell.sh
   ```

2. Reload sshd (it relaunches on demand):

   ```
   sudo launchctl stop com.openssh.sshd
   ```

## Verify

```
ssh localhost 'which herdr'   # → /Users/jirathip/.local/bin/herdr
```

