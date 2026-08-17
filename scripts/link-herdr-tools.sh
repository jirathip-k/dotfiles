#!/bin/bash
# link-herdr-tools.sh — create the ~/.local/bin/herdr-* symlinks into the
# hermes-brain scripts dir. Idempotent. Machine-agnostic (resolves $HOME).
#
# The herdr-* console tools are thin wrappers over python scripts that live in
# ~/Projects/hermes-brain/scripts/. Symlink them into ~/.local/bin (which must
# be on PATH) so they're callable from anywhere. Re-run any time, on any Mac —
# paths resolve against $HOME, so the same checkout works regardless of username.
#
# Usage:
#   ./link-herdr-tools.sh [--dry-run]
set -euo pipefail

SOURCE_ROOT="$HOME/Projects/hermes-brain/scripts"
BIN="$HOME/.local/bin"
DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

[ "$DRY_RUN" = 1 ] && echo "# link-herdr-tools.sh --dry-run (HOME=$HOME)"

mkdir -p "$BIN"
if [ ! -d "$SOURCE_ROOT" ]; then
  echo "!! hermes-brain scripts not found at $SOURCE_ROOT — clone it first" >&2
  exit 1
fi

# name=source — plain list, avoids hyphenated associative-array issues under set -u.
TOOLS="
herdr-status=$SOURCE_ROOT/herdr-status.py
herdr-spawn=$SOURCE_ROOT/herdr-spawn.py
herdr-fanout=$SOURCE_ROOT/herdr-fanout.py
herdr-orch-status=$SOURCE_ROOT/herdr-orch-status.py
herdr-cleanup=$SOURCE_ROOT/herdr-cleanup.py
herdr-fleet=$HOME/.hermes/scripts/herdr-fleet.py
herdr-issue-start=$SOURCE_ROOT/herdr-issue-start.py
herdr-issues=$SOURCE_ROOT/herdr-issues.py
herdr-usage=$SOURCE_ROOT/herdr-usage.py
restore-herdr-sessions=$HOME/.hermes/scripts/restore_herdr_sessions.py
"

while IFS= read -r entry; do
  [ -z "$entry" ] && continue
  name="${entry%%=*}"
  src="${entry#*=}"
  dst="$BIN/$name"
  if [ ! -e "$src" ]; then
    echo "  (skip) $name — source missing: $src"
    continue
  fi
  if [ "$DRY_RUN" = 1 ]; then
    echo "  would link: $dst -> $src"
    continue
  fi
  ln -sfn "$src" "$dst"
  echo "linked: $name"
done <<< "$TOOLS"

if [ "$DRY_RUN" = 0 ]; then
  echo "done. herdr-* tools available under $BIN"
fi
exit 0
