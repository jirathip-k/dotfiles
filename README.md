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
| `opencode/` | `~/.config/opencode/opencode.jsonc`, `instructions.md` | opencode config (DeepSeek, YOLO permissions) |
| `launchd/` | `~/Library/LaunchAgents/` | Launch agents (herdr server, keep-awake) |
| `scripts/` | — | Helper scripts (run from repo, not deployed) — `setup-mac.sh` for new machines |
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

## Setup (new machine)

One script does the full machine bring-up — idempotent, run it any time:

```sh
~/Projects/dotfiles/scripts/setup-mac.sh          # full: brew bundle, dotter deploy, launchd, SSH
~/Projects/dotfiles/scripts/setup-mac.sh --check  # verify only, changes nothing
```

`--check` reports each subsystem (launch agents, SSH, Tailscale, Mosh,
herdr). The full run prompts for sudo once (only needed for the SSH step —
Remote Login can't be enabled by an agent).

## Launch agents

launchd plists **cannot expand `~` or `$HOME`** — they need absolute paths.
To keep this repo machine-agnostic (same checkout on any Mac, any username),
machine-specific plists live in `launchd/` as `*.plist.tmpl` templates with a
`__HOME__` placeholder. `scripts/install-launch-agents.sh` generates the real
plists into `~/Library/LaunchAgents/` and (re)loads them:

- `com.jirathip.herdr-server` → `launchd/com.jirathip.herdr-server.plist.tmpl`
- `com.jirathip.hermes-dashboard` → `launchd/com.jirathip.hermes-dashboard.plist.tmpl`
- `com.jirathip.caffeinate` — no user paths, plain `.plist` (symlinked via dotter)
- `com.hermes.agent-state-sync` — generated from the hermes-brain repo's
  template (delegated to `~/Projects/hermes-brain/scripts/install-agent-state-sync.sh`)

`setup-mac.sh` runs this installer on every bring-up, and also links the
`herdr-*` console tools into `~/.local/bin` via `scripts/link-herdr-tools.sh`.

Manual reload (needs a user terminal — the gateway blocks launchctl from
inside itself):

```sh
~/Projects/dotfiles/scripts/install-launch-agents.sh        # generate + reload all
~/Projects/dotfiles/scripts/install-launch-agents.sh --dry-run  # preview only
```

| Agent | Purpose |
|---|---|
| `com.jirathip.herdr-server` | herdr server daemon — keeps agent sessions/panes alive across logout & reboot |
| `com.jirathip.caffeinate` | runs `caffeinate -dimsu` from login — no idle sleep while plugged in |
| `com.jirathip.hermes-dashboard` | Hermes web dashboard — `hermes dashboard --no-open --host 0.0.0.0 --port 9119`, auth-gated (dashboard.basic_auth in config.yaml), tailnet-reachable at `http://<mac>.tail*.ts.net:9119` |

The dashboard binds 0.0.0.0 and REQUIRES an auth provider — set
`hermes config set dashboard.basic_auth.username <user>` +
`password_hash` (via `plugins.dashboard_auth.basic.hash_password`) before
first bootstrap, or the job exits with "Refusing to bind dashboard to
0.0.0.0 — no auth providers are registered".

Verify: `launchctl list | grep jirathip`.

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
  survive via the launch agents above.

Known gaps (accepted):

- Simulator + Xcode + computer-use remain macOS-bound; a headless Linux box
  can't run the iOS build/test loop.
- Reattach from another device requires Remote Login (SSH) enabled on the Mac.

Revisit if: you need agent execution on a headless box for non-iOS work, or
want remote reattach over SSH without keeping the MacBook awake.

## Remote attach from iPhone (Moshi)

[Moshi](https://getmoshi.app) — iOS terminal for herdr/tmux over SSH/MOSH.
Full interactive herdr TUI from the phone, anywhere.

Prereqs (all in this repo except two macOS settings):

1. **Tailscale** — `cask "tailscale"` in Brewfile; Mac + iPhone on same tailnet.
   Get the Mac's tailnet address: `tailscale ip -4` (or MagicDNS name from
   `tailscale status`).
2. **Remote Login (SSH)** — macOS system setting, not in this repo:
   `sudo launchctl enable system/com.openssh.sshd && sudo launchctl bootstrap system /System/Library/LaunchDaemons/ssh.plist`
   or System Settings → General → Sharing → Remote Login. Requires sudo;
   cannot be scripted by an agent — `setup-mac.sh` handles it (note:
   `systemsetup` needs Full Disk Access; the launchctl path avoids that).
3. **Mosh server** — `brew "mosh"` in Brewfile.
4. **herdr server** — LaunchAgent in `launchd/` (see Launch agents section above).

Phone connection (Moshi):

- Host: Mac's tailnet IP (`100.x.x.x`, e.g. `100.67.222.5`) or MagicDNS name
- User: `jirathip`
- Protocol: Mosh (SSH fallback)
- Then run `herdr` — same server/panes as the desktop.

Note: tailnet IPs are stable per device but re-run `tailscale ip -4` if the
Mac changes identity. New machine: run `scripts/setup-mac.sh` (covers brew
bundle, dotter deploy, launchd bootstrap, Remote Login).

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
