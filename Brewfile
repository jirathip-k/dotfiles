# Brewfile — declarative package manifest.
#   Install everything:  brew bundle --file ~/Projects/dotfiles/Brewfile
#   (Add --cleanup to also uninstall anything NOT listed here — use with care.)

# --- Shell & prompt ---------------------------------------------------------
brew "zsh"            # ships with macOS, but pin the Homebrew build
brew "antidote"      # zsh plugin manager
brew "starship"      # cross-shell prompt

# --- CLI core ---------------------------------------------------------------
brew "git"
brew "git-delta"     # nicer git diffs
brew "gh"            # GitHub CLI (also git credential helper)
brew "lazygit"
brew "tmux"
brew "mise"          # runtime/version manager
brew "fzf"
brew "zoxide"        # smarter cd (`z`)
brew "eza"           # modern ls
brew "bat"           # modern cat
brew "fd"            # modern find
brew "ripgrep"       # fast grep (rg)
brew "neovim"
brew "tree-sitter"   # CLI, for building generated parsers (e.g. swift)

# --- Language servers / dev tooling ----------------------------------------
brew "uv"                              # Python packaging
brew "pyright"
brew "ruff"
brew "typescript-language-server"
brew "tailwindcss-language-server"
brew "prettier"

# --- Platform / project tools ----------------------------------------------
brew "azure-cli"
brew "cocoapods"
brew "fastlane"
brew "xcodegen"
brew "hugo"
brew "poppler"
brew "dotter"        # dotfiles manager for this repo

# --- GUI apps & fonts -------------------------------------------------------
cask "ghostty"
cask "cmux"          # Ghostty-based terminal with agent workspaces; reads ghostty/config
cask "font-hack-nerd-font"
cask "visual-studio-code"
cask "godot"
