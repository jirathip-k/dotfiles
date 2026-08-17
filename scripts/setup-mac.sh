#!/usr/bin/env bash
# setup-mac.sh — one-shot full machine setup for a fresh macOS install.
# Idempotent: safe to re-run any time; each step checks current state first.
#
# Covers:
#   1. Homebrew packages + casks (Brewfile)
#   2. dotter deploy (symlink dotfiles into place)
#   3. Launch agents (herdr server, caffeinate keep-awake)
#   4. Remote Login (SSH) — required for phone attach (Moshi) over Tailscale
#   5. Verification
#
# Usage:
#   ./scripts/setup-mac.sh                # full setup (prompts for sudo)
#   ./scripts/setup-mac.sh --skip-deps    # skip brew + dotter, only launchd + SSH
#   ./scripts/setup-mac.sh --check        # verify everything, change nothing
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="full"
for arg in "$@"; do
  case "$arg" in
    --skip-deps) MODE="skip-deps" ;;
    --check)     MODE="check" ;;
    -h|--help)   sed -n '2,18p' "$0" | sed 's/^# //'; exit 0 ;;
    *) echo "Unknown flag: $arg (try --help)" >&2; exit 1 ;;
  esac
done

say() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
ok()  { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
warn(){ printf '\033[1;33m  !\033[0m %s\n' "$*"; }
fail(){ printf '\033[1;31m  ✗\033[0m %s\n' "$*"; }

agent_loaded() { launchctl list | grep -q "$1"; }

# ---------- 1. Homebrew ----------
if [ "$MODE" = "full" ]; then
  say "1/4 Homebrew packages + casks (Brewfile)"
  if command -v brew >/dev/null; then
    brew bundle --file "$REPO_ROOT/Brewfile"
    ok "brew bundle complete"
  else
    warn "Homebrew not found — install it first: https://brew.sh"
  fi

  # ---------- 2. dotter deploy ----------
  say "2/4 Deploying dotfiles (dotter)"
  if command -v dotter >/dev/null; then
    (cd "$REPO_ROOT" && dotter deploy)
    ok "dotfiles deployed"
  else
    warn "dotter not found — install with: brew install dotter"
  fi
fi

# ---------- 3. Launch agents ----------
say "3/4 Launch agents"

# Generate + load all machine-specific launchd plists (herdr-server,
# hermes-dashboard, caffeinate, hermes agent-state-sync) from __HOME__ templates.
# launchd can't expand ~, so these MUST be generated against $HOME at install
# time. Re-runs are idempotent. --check must be read-only: dry-run only.
if [ "$MODE" = "check" ]; then
  if [ -x "$REPO_ROOT/scripts/install-launch-agents.sh" ]; then
    "$REPO_ROOT/scripts/install-launch-agents.sh" --dry-run >/dev/null \
      && ok "launch agents: template render OK" || fail "launch agents: template render FAILED"
  else
    fail "install-launch-agents.sh not found (deploy dotfiles first)"
  fi
  [ -x "$REPO_ROOT/scripts/link-herdr-tools.sh" ] \
    && "$REPO_ROOT/scripts/link-herdr-tools.sh" --dry-run >/dev/null \
    && ok "herdr tools: symlink targets resolve" || fail "herdr tools: missing or unresolvable"
else
  "$REPO_ROOT/scripts/install-launch-agents.sh"
  "$REPO_ROOT/scripts/link-herdr-tools.sh"
fi

# ---------- 4. Remote Login (SSH) ----------
say "4/4 Remote Login (SSH)"
if pgrep -x sshd >/dev/null; then
  ok "sshd already running"
elif [ "$MODE" = "check" ]; then
  warn "Remote Login is OFF — run full setup to enable"
else
  # Apple's sshd-keygen-wrapper exits 255 on macOS 26.5 (silent: stderr -> /dev/null)
  # while raw sshd works. Bypass it: custom LaunchDaemon runs sshd -D directly.
  # Host keys already exist, so the wrapper's keygen job is unnecessary.
  sudo launchctl disable system/com.openssh.sshd 2>/dev/null || true
  sudo mkdir -p /Library/LaunchDaemons
  sudo ln -sf "$REPO_ROOT/launchd/com.jirathip.sshd.plist" \
    /Library/LaunchDaemons/com.jirathip.sshd.plist
  sudo launchctl bootstrap system /Library/LaunchDaemons/com.jirathip.sshd.plist \
    || sudo launchctl kickstart -k system/com.jirathip.sshd
  if pgrep -x sshd >/dev/null; then ok "sshd running"; else fail "sshd not up — see /var/log/sshd.jirathip.err"; fi
fi

# ---------- 5. Verification ----------
say "Verification"
ok "launch agents:  $(launchctl list | grep -c 'com\.jirathip\.' || true) loaded"
if pgrep -x sshd >/dev/null; then
  ok "SSH:           port 22 listening"
else
  fail "SSH:           not running"
fi
if command -v tailscale >/dev/null 2>&1 || [ -x /Applications/Tailscale.app/Contents/MacOS/Tailscale ]; then
  TS_BIN="$(command -v tailscale || echo /Applications/Tailscale.app/Contents/MacOS/Tailscale)"
  TS_IP="$("$TS_BIN" ip -4 2>/dev/null | head -n1)"
  [ -n "$TS_IP" ] && ok "Tailscale:     $TS_IP" || warn "Tailscale:     not connected"
else
  warn "Tailscale:    not installed"
fi
command -v mosh >/dev/null && ok "Mosh:          $(mosh --version 2>&1 | head -n1)" || warn "Mosh:          not installed"
command -v herdr >/dev/null && ok "herdr:         $(herdr --version 2>&1 | head -n1)" || warn "herdr:         not installed"

echo
echo "Next: in Moshi on iPhone → host \$(tailscale ip -4) → user \$(whoami) → Mosh → run herdr"
