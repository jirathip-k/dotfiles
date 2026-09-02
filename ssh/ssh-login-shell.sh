#!/bin/bash
# sshd ForceCommand shim: guarantee herdr + Homebrew PATH for SSH logins
# (rootshell phone sessions, herdr --remote, plain ssh).
# Deployed by dotter to ~/.local/bin/ssh-login-shell.sh.
# Local shells (Terminal, rootshell Mac local tab) are unaffected — sshd
# only runs this for incoming SSH sessions.
#
# Why: herdr lives in ~/.local/bin, added to PATH only in .zprofile
# (login shells). SSH non-login shells skip .zprofile → herdr invisible.
# This shim sets the full PATH then execs a login zsh, so SSH sessions
# behave like local Terminal tabs.
#
# Two modes:
#   no args (ForceCommand / interactive SSH)  → login+interactive zsh (full TUI)
#   with args (ssh host 'cmd')                → login+interactive zsh running
#                                                the command, +Z disables zle
#                                                so non-TTY pipes don't stall
#
# Enable (needs sudo, one-time — see README.md "SSH login shell"):
#   1. /etc/ssh/sshd_config:  ForceCommand /Users/jirathip/.local/bin/ssh-login-shell.sh
#   2. sudo launchctl stop com.openssh.sshd   # sshd relaunches on demand
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
if [[ $# -gt 0 ]]; then
  exec /bin/zsh -l -i +Z -c "$@"
else
  exec /bin/zsh -l -i
fi
