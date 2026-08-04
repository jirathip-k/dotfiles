# ~/.config/zsh/aliases.zsh

alias python='python3'

# Editor — open the current dir in nvim (matches the old fish setup).
alias v='nvim .'
alias vi='nvim .'
alias vim='nvim .'

# eza (modern ls). Falls back silently if not installed.
if command -v eza >/dev/null; then
  alias ls='eza --icons'
  alias ll='eza -l --icons --git'
  alias la='eza -la --icons --git'
  alias lt='eza --tree --level=2 --icons'
fi

# bat (modern cat).
command -v bat     >/dev/null && alias cat='bat'
command -v lazygit >/dev/null && alias lg='lazygit'

alias g='git'
alias reload='exec zsh'

# Note: grep is intentionally NOT aliased to rg — use `rg` directly so scripts
# and grep's own flags keep working. fzf lives on Ctrl-R / Ctrl-T / Alt-C.

# Print the agent-ops GitHub App private key from the login keychain.
# `security -w` hex-encodes any value containing newlines, which a PEM always
# has, so a bare `find-generic-password` pipes an unusable blob. Decode it and
# restore the trailing newline the keychain drops.
#   agent-ops-key | gh secret set AGENT_APP_PRIVATE_KEY --repo OWNER/REPO
agent-ops-key() {
  security find-generic-password -s agent-ops-app-key -w | python3 -c '
import binascii, sys
raw = sys.stdin.read().strip()
try:
    out = binascii.unhexlify(raw).decode()
except (binascii.Error, ValueError):
    out = raw
sys.stdout.write(out.rstrip("\n") + "\n")
'
}
