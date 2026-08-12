#!/usr/bin/env bash
# orca-remote.sh — serve this Mac's Orca runtime over Tailscale so another
# machine can pair with it:  orca environment add --name <name> --pairing-code <code>
#
# Modes:
#   default   Official flow: requires the Orca app to be quit first (single-instance
#             lock on the main profile); serves the real profile on port 6768.
#   --sidecar Run headless serve ALONGSIDE the Orca app, on a separate profile and
#             port (6769). The served runtime starts empty — remote clients must
#             add repos by path (repo add), and agent logins are separate from the
#             desktop profile.
set -euo pipefail

ORCA_BIN="/Applications/Orca.app/Contents/MacOS/Orca"
SIDECAR_PROFILE="$HOME/Library/Application Support/orca-serve"
SIDECAR_PORT="${ORCA_SERVE_PORT:-6769}"
WRAPPER_DIR="${TMPDIR:-/tmp}/orca-serve"
WRAPPER="$WRAPPER_DIR/wrapper.sh"

resolve_tailscale() {
  if command -v tailscale >/dev/null 2>&1; then
    echo tailscale
  elif [ -x "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ]; then
    echo "/Applications/Tailscale.app/Contents/MacOS/Tailscale"
  else
    return 1
  fi
}

TS="$(resolve_tailscale)" || {
  echo "Tailscale CLI not found — install with: brew install --cask tailscale" >&2
  exit 1
}

TS_IP="$("$TS" ip -4 2>/dev/null | head -n1)"
if [ -z "$TS_IP" ]; then
  echo "No Tailscale IPv4 assigned — is Tailscale logged in and connected?" >&2
  exit 1
fi

echo "Serving Orca runtime at Tailscale address: $TS_IP"
echo "Pair from another machine with: orca environment add --name <name> --pairing-code <printed code>"

if [ "${1:-}" = "--sidecar" ]; then
  shift
  mkdir -p "$WRAPPER_DIR" "$SIDECAR_PROFILE"
  cat > "$WRAPPER" << EOF
#!/bin/sh
exec "$ORCA_BIN" --user-data-dir="$SIDECAR_PROFILE" "\$@"
EOF
  chmod +x "$WRAPPER"
  echo "[sidecar] separate profile: $SIDECAR_PROFILE (port $SIDECAR_PORT)"
  exec env ORCA_APP_EXECUTABLE="$WRAPPER" orca serve --port "$SIDECAR_PORT" --pairing-address "$TS_IP" "$@"
fi

if pgrep -x Orca >/dev/null; then
  echo "ERROR: the Orca app is running; serve needs the main profile free." >&2
  echo "Quit Orca first, or use: $0 --sidecar" >&2
  exit 1
fi

exec orca serve --pairing-address "$TS_IP" "$@"
