# ~/.config/zsh/.zprofile — login shells only. PATH and environment live here.

# Homebrew (Apple Silicon). Runs after /etc/zprofile's path_helper so brew wins.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Keep PATH/path entries unique, preserving first occurrence.
typeset -U path PATH

# User binaries.
path=(
  $HOME/.local/bin        # uv / pipx / user scripts
  $path
)

# Rust / Cargo.
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

export EDITOR="nvim"
export VISUAL="nvim"
export DOCKER_BUILDKIT=1
