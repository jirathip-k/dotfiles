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
| `claude/` | `~/.claude/settings.json`, `~/.claude/CLAUDE.md` | Claude Code settings + global memory |
| `opencode/` | `~/.config/opencode/opencode.jsonc`, `instructions.md` | opencode config (DeepSeek, YOLO permissions, Orca skills guide) |
| `launchd/` | `~/Library/LaunchAgents/` | Launch agents (herdr server, keep-awake) |
| `scripts/` | — | Helper scripts (run from repo, not deployed) |
| `Brewfile` | — | All Homebrew packages/casks |

`vial/` holds the [Vial](https://get.vial.today) keymap backup for the Corne
keyboard (`corne-choc.vil`) — versioned here, not deployed by dotter.

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

## Remote Orca access (over Tailscale)

Install Tailscale (`cask "tailscale"` in the Brewfile), log in, and make sure
the target device is on the same tailnet.

> macOS 15+ gotcha: Tailscale's network extension approval lives in
> **System Settings → General → Login Items & Extensions → Network
> Extensions** (not Privacy & Security). If the app's "Required permissions"
> window is stuck, quit and relaunch Tailscale after enabling it.

### Primary: advertise the app (recommended)

The desktop app advertises itself — real profile, all worktrees visible:

1. Orca → **Settings → Remote Orca Servers** → under *Advertise this app as a
   server* → **New Link**
2. Connection address: pick the **Tailscale** address (e.g. `100.x.y.z`),
   **Generate Access Link**
3. On the other machine/phone: scan the QR or paste the link (Orca Mobile's
   "local network" QR scanner accepts any `orca://pair` code — the Tailscale
   address is baked into the link)

Usage/accounts (Claude, Codex, OpenCode Go, …) is served from this Mac to
remote clients — pull-to-refresh the Accounts screen on mobile if it looks
stale.

### Alternative: headless `orca serve`

For a dedicated headless runtime (fresh empty profile — no worktrees):

```sh
~/Projects/dotfiles/scripts/orca-remote.sh                # app must be quit
~/Projects/dotfiles/scripts/orca-remote.sh --sidecar      # runs alongside the app
```

It resolves the Tailscale IPv4 and prints a pairing link/code. Pair with:

```sh
orca environment add --name macbook --pairing-code <printed code>
```

Verify with `orca environment show --environment macbook` or `orca --environment macbook status --json`.
Use `--sidecar --mobile-pairing` for a mobile QR while the app stays open
(separate profile at `~/Library/Application Support/orca-serve`, port 6769).

### Keeping the Mac awake

The Orca app (and its remote runtime) sleeps with the Mac. A launchd agent
runs `caffeinate -dimsu` from login onward so idle sleep never kicks in while
the machine is plugged in:

```sh
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.jirathip.caffeinate.plist   # once after deploy
```

Notes: closing the lid still sleeps a MacBook unless it's in clamshell mode
with power + display; on battery, macOS may sleep anyway.

## Agent runtime: Herdr (Orca retired)

Decision (2026-08-15): **Orca retired** (Electron RAM overhead); agent
worktrees and sessions now run under [Herdr](https://herdr.dev)
(`~/.local/bin/herdr`, v0.7.5) — persistent panes survive agent crashes, and
`herdr --remote` enables SSH attach from another device (Mac mini/VPS) with
no workflow changes. Former Orca workspaces were recreated as herdr tabs
grouped by project.

Workflow rules:

- One worktree → one agent → one tool (never two worktree managers over the
  same repo).
- Hermes orchestrates and delegates; herdr hosts the agent sessions.
- Long-running runs (soaks, endurance tests) stay in herdr panes — they
  survive via the launchd agents below.

Known gaps (accepted):

- Simulator + Xcode + computer-use remain macOS-bound; a headless Linux box
  can't run the iOS build/test loop.
- Reattach from another device requires Remote Login (SSH) enabled on the Mac.

Revisit if: you need agent execution on a headless box for non-iOS work, or
want remote reattach over SSH without keeping the MacBook awake.

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
(pinned in `nvim/lazy-lock.json`); native LSP configured under `nvim/lsp/` and
enabled in `nvim/lua/lsp-init.lua`. Nerd Font required — `font-hack-nerd-font`
is in the Brewfile.

**Languages** (LSP + treesitter + format-on-save):

| Lang | LSP | Formatter |
|------|-----|-----------|
| TypeScript/JS | `typescript-language-server` | prettier |
| Swift / iOS | `sourcekit-lsp` (via `xcrun`, needs Xcode) | swift-format |
| Python | `pyright` + `ruff` | ruff |
| Lua | `lua-language-server` | stylua |

Treesitter uses the `master` branch (full highlight + indent + incremental
selection). Most parsers install automatically; **Swift needs a one-time build**
because its grammar must be generated and Neovim's ABI 15 is newer than master's
auto-generator supports:

```sh
nvim/scripts/build-swift-parser.sh   # needs the tree-sitter CLI + a C compiler
```

LSP keymaps (buffer-local on attach): `gd` definition, `gD` declaration, `gi`
implementation, `gy` type def, `K` hover, `<leader>rn` rename, `<leader>ca` code
action, `<leader>d` diagnostics float, `[d`/`]d` navigate, `<leader>th` toggle
inlay hints, `<leader>m` format.

## tmux

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux source ~/.config/tmux/tmux.conf   # then prefix + I to install plugins
```

## Managing dotfiles

- Edit files under `~/Projects/dotfiles`; they're symlinked, so changes are live.
- `dotter deploy` after adding a new file mapping in `.dotter/global.toml`.
- `brew bundle dump --file Brewfile --force` to refresh the package list.
