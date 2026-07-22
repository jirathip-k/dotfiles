# Dotfiles

Personal macOS dev environment — **zsh + Ghostty + Neovim**, managed with
[dotter](https://github.com/SuperCuber/dotter). Canonical location:
`~/Projects/dotfiles`.

## Layout

| Dir | Deploys to | What |
|-----|-----------|------|
| `zsh/` | `~/.zshenv`, `~/.config/zsh/` | Shell: env, PATH, plugins, aliases, vi-mode |
| `starship/` | `~/.config/starship.toml` | Prompt (Catppuccin Frappé) |
| `ghostty/` | `~/.config/ghostty/config` | Terminal |
| `nvim/` | `~/.config/nvim/` | Neovim (0.11+, native LSP) |
| `git/` | `~/.gitconfig`, `~/.config/git/ignore` | Git config + global ignore |
| `tmux/` | `~/.config/tmux/tmux.conf` | tmux |
| `Brewfile` | — | All Homebrew packages/casks |

## Fresh install

```sh
# 1. Homebrew, then all packages
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file ~/Projects/dotfiles/Brewfile

# 2. Deploy dotfiles
cd ~/Projects/dotfiles
cp .dotter/local-example.toml .dotter/local.toml   # trim packages per-machine
dotter deploy

# 3. Make zsh the login shell
chsh -s /bin/zsh
```

Open a new terminal — antidote clones the zsh plugins on first launch.

## Shell

zsh with [antidote](https://github.com/mattmc3/antidote) (plugins in
`zsh/.zsh_plugins.txt`, statically bundled for fast startup):

- `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf-tab`, `zsh-completions`
- Prompt: [starship](https://starship.rs) · dir jumping: [zoxide](https://github.com/ajeetdsouza/zoxide) (`z`)
- Built-in vi mode with cursor-shape switching
- fzf on `Ctrl-R` (history), `Ctrl-T` (files), `Alt-C` (cd)
- Aliases: `ls`→eza, `cat`→bat, `lg`→lazygit, `v`/`vi`/`vim`→`nvim .`

## Neovim

Requires Neovim 0.11+. Plugins via [lazy.nvim](https://github.com/folke/lazy.nvim)
(pinned in `nvim/lazy-lock.json`); LSPs configured under `nvim/lsp/`. Nerd Font
required — `font-hack-nerd-font` is in the Brewfile.

## tmux

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux source ~/.config/tmux/tmux.conf   # then prefix + I to install plugins
```

## Managing dotfiles

- Edit files under `~/Projects/dotfiles`; they're symlinked, so changes are live.
- `dotter deploy` after adding a new file mapping in `.dotter/global.toml`.
- `brew bundle dump --file Brewfile --force` to refresh the package list.
