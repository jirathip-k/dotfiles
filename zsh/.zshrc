# ~/.config/zsh/.zshrc — interactive shells.

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------
HISTFILE="$XDG_STATE_HOME/zsh/history"
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY          # record timestamps
setopt HIST_IGNORE_ALL_DUPS      # drop older duplicate commands
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY               # expand !! etc. before running
setopt SHARE_HISTORY             # share across live sessions
setopt INC_APPEND_HISTORY

# ---------------------------------------------------------------------------
# Shell options
# ---------------------------------------------------------------------------
setopt AUTO_CD                   # `foo/` cds into foo
setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
setopt INTERACTIVE_COMMENTS      # allow # comments at the prompt
setopt NO_BEEP
setopt GLOB_DOTS                 # globs match dotfiles

# ---------------------------------------------------------------------------
# Plugins — antidote, statically bundled for fast startup
# ---------------------------------------------------------------------------
antidote_home="$(brew --prefix antidote 2>/dev/null)/share/antidote"
if [[ -e "$antidote_home/antidote.zsh" ]]; then
  source "$antidote_home/antidote.zsh"
  zsh_plugins="$ZDOTDIR/.zsh_plugins"
  # Rebuild the static bundle whenever the plugin list changes.
  if [[ ! "${zsh_plugins}.zsh" -nt "${zsh_plugins}.txt" ]]; then
    antidote bundle < "${zsh_plugins}.txt" > "${zsh_plugins}.zsh"
  fi
  source "${zsh_plugins}.zsh"
fi

# ---------------------------------------------------------------------------
# Completion styling (compinit is run by ez-compinit above)
# ---------------------------------------------------------------------------
zstyle ':completion:*' menu no                                   # fzf-tab draws the menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'        # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '[%d]'
# Preview directory contents when completing `cd`.
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons --color=always $realpath 2>/dev/null'
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# Autosuggestions from history + completion.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ---------------------------------------------------------------------------
# Vi mode (built-in — robust with fzf/autosuggestions, no extra plugin)
# ---------------------------------------------------------------------------
bindkey -v
export KEYTIMEOUT=1

# Cursor: block in command mode, beam in insert mode.
function _cursor_beam { printf '\e[6 q' }
function _cursor_block { printf '\e[2 q' }
function zle-keymap-select { [[ $KEYMAP == vicmd ]] && _cursor_block || _cursor_beam }
function zle-line-init { _cursor_beam }
zle -N zle-keymap-select
zle -N zle-line-init

# Keep a few familiar emacs-style keys usable in insert mode.
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^?' backward-delete-char   # backspace past insert point
bindkey -M viins '^W' backward-kill-word

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
[[ -f "$ZDOTDIR/aliases.zsh" ]] && source "$ZDOTDIR/aliases.zsh"

# ---------------------------------------------------------------------------
# Tools
# ---------------------------------------------------------------------------
export BAT_THEME="Catppuccin Frappe"

# Catppuccin Frappé palette for fzf.
export FZF_DEFAULT_OPTS="\
--height 40% --layout=reverse --border \
--color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
--color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
--color=marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284 \
--color=selected-bg:#51576d"

command -v starship >/dev/null && eval "$(starship init zsh)"
command -v zoxide   >/dev/null && eval "$(zoxide init zsh)"
command -v mise     >/dev/null && eval "$(mise activate zsh)"
# fzf keybindings (Ctrl-R history, Ctrl-T files, Alt-C cd). Load after vi mode.
command -v fzf      >/dev/null && source <(fzf --zsh)
