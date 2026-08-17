#!/bin/bash
# install-launch-agents.sh — generate all machine-specific launchd plists from
# __HOME__ templates into ~/Library/LaunchAgents/ and (re)load them.
#
# launchd plists CANNOT use ~ or $HOME (no shell expansion), so every plist that
# references a user path must be generated at install time from a template that
# carries a __HOME__ placeholder. This keeps the dotfiles + hermes-brain repos
# machine-agnostic: the SAME checkout works on any Mac regardless of username.
#
# Covers:
#   com.jirathip.herdr-server       (from dotfiles .tmpl)
#   com.jirathip.hermes-dashboard   (from dotfiles .tmpl)
#   com.jirathip.caffeinate         (no user paths — symlinked as-is, passthrough)
#   com.hermes.agent-state-sync     (from hermes-brain .tmpl, via its installer)
#
# Usage:
#   ./install-launch-agents.sh                     # generate + (re)load all
#   ./install-launch-agents.sh --dry-run           # show what WOULD be generated
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LADIR="$HOME/Library/LaunchAgents"
DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

# label=template-path — plain list (hyphenated keys break declare -A under set -u).
TMPLS="
com.jirathip.herdr-server=$DOTFILES_ROOT/launchd/com.jirathip.herdr-server.plist.tmpl
com.jirathip.hermes-dashboard=$DOTFILES_ROOT/launchd/com.jirathip.hermes-dashboard.plist.tmpl
"

mkdir -p "$LADIR" "$HOME/.config/herdr" "$HOME/.hermes/logs"

# literal __HOME__ replacement — NOT sed: $HOME could contain & or | on some
# account, and sed would interpret them (silent corruption / hard error).
render() { # tmpl -> stdout, __HOME__ -> $HOME literally
  python3 -c 'import os,sys;print(open(sys.argv[1]).read().replace("__HOME__",os.environ["HOME"]),end="")' "$1"
}

gen() { # label tmpl_path
  local label="$1" tmpl="$2"
  local dest="$LADIR/$label.plist"
  if [ "$DRY_RUN" = 1 ]; then
    echo "# --- $label (would write $dest)"
    render "$tmpl"
    echo
    return
  fi
  rm -f "$dest"           # drop stale symlink to the old repo .plist / old file
  render "$tmpl" > "$dest"
  plutil -lint "$dest" >/dev/null || { echo "!! $label plist invalid" >&2; exit 1; }
  reload "$label" "$dest"
}

reload() { # label dest
  local label="$1" dest="$2"
  if launchctl list | grep -q "$label"; then
    launchctl bootout "gui/$(id -u)" "$dest" 2>/dev/null || true
  fi
  launchctl bootstrap "gui/$(id -u)" "$dest" && echo "loaded: $label"
}

if [ "$DRY_RUN" = 1 ]; then
  echo "# install-launch-agents.sh --dry-run (HOME=$HOME)"
fi

while IFS= read -r entry; do
  [ -z "$entry" ] && continue
  label="${entry%%=*}"
  tmpl="${entry#*=}"
  gen "$label" "$tmpl"
done <<< "$TMPLS"

# caffeinate: no user paths inside, stays a plain symlinked plist via dotter.
# Guard on the DEPLOYED dest (dotter may not have run yet on a fresh machine) —
# absent dest means "deploy dotfiles first", not "abort the installer".
dest="$LADIR/com.jirathip.caffeinate.plist"
if [ "$DRY_RUN" = 0 ] && [ -f "$dest" ]; then
  reload "com.jirathip.caffeinate" "$dest" || true
fi

# agent-state-sync lives in the hermes-brain repo — delegate to its installer.
HB_INSTALLER="$HOME/Projects/hermes-brain/scripts/install-agent-state-sync.sh"
if [ "$DRY_RUN" = 0 ] && [ -x "$HB_INSTALLER" ]; then
  "$HB_INSTALLER"
fi

if [ "$DRY_RUN" = 0 ]; then
  echo "done. LaunchAgents under $LADIR"
fi
