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
