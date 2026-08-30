#!/usr/bin/env bash
# tailscale-setup.sh — idempotent Tailscale CLI-variant setup for this Mac.
# Installs tailscaled as a root launchd service (starts at BOOT, before login —
# the GUI App Store variant cannot do this), authenticates the node, and
# restores the tailscale serve routes for tailnet-only UIs.
#
# Run:  sudo needed only for `brew services start tailscale` and first `up`.
# Idempotent: safe to re-run after OS reinstall or on a new machine.
set -euo pipefail

TS="/opt/homebrew/opt/tailscale/bin/tailscale"
BREW_TSD="tailscale"   # homebrew formula providing tailscaled

# 1) Install CLI variant if missing
if [ ! -x "$TS" ]; then
  echo "Installing tailscale via Homebrew…"
  brew install "$BREW_TSD"
fi

# 2) Start root daemon (boot-persistent via brew services → launchd)
if ! pgrep -x tailscaled >/dev/null 2>&1; then
  echo "Starting tailscaled (sudo needed)…"
  sudo brew services start "$BREW_TSD"
fi

# 3) Authenticate if logged out (prints a login URL; Ctrl-C after visiting it)
if ! "$TS" status >/dev/null 2>&1; then
  echo "Node not authenticated. Run manually:"
  echo "  $TS up"
  echo "Then re-run this script."
  exit 1
fi

# 4) Restore serve routes (idempotent — re-running refreshes the config).
#    All routes are tailnet-only; TLS certs are auto-provisioned per hostname.
#    NOTE: hostname follows the NODE name, so on a new node (re-auth) the
#    -1/-2 suffix changes. Update DNS references below if the node was renamed.
$TS serve --bg --https=443  http://127.0.0.1:8474  # corrald board
$TS serve --bg --https=8443 http://127.0.0.1:8787  # hermes-webui (Hermex)
$TS serve --bg --https=8446 http://127.0.0.1:7878  # hindsight control center

# 5) Verify
echo "--- serve routes ---"
$TS serve status
echo "--- status ---"
$TS status | head -3

# 6) Optional hardening for unattended reboots (laptop era):
#    sudo pmset -a autorestart 1 && sudo pmset -a autorestartatconnect 1
echo "Done. Note: GUI Tailscale.app may still be installed as fallback but is"
echo "logged out; its login item is a no-op menubar stub."
