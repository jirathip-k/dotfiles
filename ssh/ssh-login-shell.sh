#!/bin/bash
# sshd ForceCommand shim: guarantee herdr + Homebrew PATH for SSH logins
# (rootshell phone sessions, herdr --remote, plain ssh).
# Deployed by dotter to ~/.local/bin/ssh-login-shell.sh.
# Local shells (Terminal, rootshell Mac local tab) are unaffected — sshd
# only runs this for incoming SSH sessions.
#
# sshd invokes:  ssh-login-shell.sh <user's command words...>
# (or with NO args for interactive sessions). Join words into one command
# string for zsh -c. -l login shell so .zprofile PATH applies; +Z only in
# command mode (zle stalls non-TTY pipes).
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
if [[ -n "${SSH_ORIGINAL_COMMAND:-}" ]]; then
  exec /bin/zsh -l +Z -c "$SSH_ORIGINAL_COMMAND"
else
  exec /bin/zsh -l -i
fi
