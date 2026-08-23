#!/usr/bin/env bash
# setup-hindsight-memory.sh — configure the Hindsight memory provider
# (local_embedded, OpenAI-compatible LLM) across Hermes profiles, portably.
#
# PORTABLE: uses $HOME / $HERMES_HOME only — no absolute user paths. Runs on
# any machine where Hermes lives at $HOME/.hermes/hermes-agent (macOS target).
# Idempotent: safe to re-run. Reuses each profile's DEEPSEEK_API_KEY as the
# OpenAI-wire LLM key; sets memory.provider=hindsight in that profile's config.yaml.
#
# Usage:
#   setup-hindsight-memory.sh                 # default profile + all named profiles
#   setup-hindsight-memory.sh conductor       # one named profile (repeatable)
#   setup-hindsight-memory.sh --default       # default profile only
#   setup-hindsight-memory.sh --halt          # just materialize (re-run after edits)
#
# Env overrides: LLM_BASE_URL, LLM_MODEL, LLM_KEY_ENV, BANK_PREFIX
set -euo pipefail

HERMES_ROOT="${HERMES_ROOT:-$HOME/.hermes}"
VENV="$HERMES_ROOT/hermes-agent/venv"
PYTHON="${PYTHON:-$VENV/bin/python}"
HERMES_BIN="$VENV/bin/hermes"

LLM_BASE_URL="${LLM_BASE_URL:-https://api.deepseek.com/v1}"
LLM_MODEL="${LLM_MODEL:-deepseek-chat}"
LLM_KEY_ENV="${LLM_KEY_ENV:-DEEPSEEK_API_KEY}"
TIMEOUT=120
IDLE_TIMEOUT=300
BANK_PREFIX="${BANK_PREFIX:-hermes}"

log() { printf '\n== %s ==\n' "$*"; }
die() { echo "ERROR: $*" >&2; exit 1; }

[ -x "$PYTHON" ] || die "venv python not found: $PYTHON (is Hermes installed?)"
[ -x "$HERMES_BIN" ] || die "hermes not found: $HERMES_BIN"

upsert_env() { # upsert_env <envfile> <KEY> <VALUE>
  local file="$1" k="$2" v="$3"
  if grep -qE "^${k}=" "$file"; then
    sed -i '' "s|^${k}=.*|${k}=${v}|" "$file"
  else
    printf '%s=%s\n' "$k" "$v" >> "$file"
  fi
}

# Args: <label> <home>
configure_profile() {
  local label="$1" home="$2"
  [ -d "$home" ] || die "profile home missing: $home"
  log "Configuring Hindsight for '$label' ($home)"

  local cfg_dir="$home/hindsight"
  mkdir -p "$cfg_dir"
  local cfg="$cfg_dir/config.json"
  # Default profile keeps bank "hermes"; named profiles isolate per-role.
  local bank="$BANK_PREFIX"
  [ "$label" != "hermes" ] && bank="$BANK_PREFIX-$label"
  cat > "$cfg" <<JSON
{
  "profile": "$label",
  "mode": "local_embedded",
  "bank_id": "$bank",
  "recall_budget": "mid",
  "timeout": $TIMEOUT,
  "idle_timeout": $IDLE_TIMEOUT,
  "llm_provider": "openai_compatible",
  "llm_base_url": "$LLM_BASE_URL",
  "llm_model": "$LLM_MODEL"
}
JSON
  chmod 600 "$cfg"
  echo "  wrote $cfg"

  local envf="$home/.env"
  [ -f "$envf" ] || die "no .env at $envf"
  local key
  key="$(grep -E "^$LLM_KEY_ENV=" "$envf" | head -1 | cut -d= -f2-)"
  [ -n "$key" ] || die "$LLM_KEY_ENV not set in $envf"
  upsert_env "$envf" HINDSIGHT_LLM_API_KEY "$key"
  upsert_env "$envf" HINDSIGHT_TIMEOUT "$TIMEOUT"
  upsert_env "$envf" HINDSIGHT_IDLE_TIMEOUT "$IDLE_TIMEOUT"
  chmod 600 "$envf"
  echo "  updated $envf"
}

# Args: <home>
activate_provider() {
  local home="$1"
  log "Activating provider for $home"
  HERMES_HOME="$home" "$HERMES_BIN" config set memory.provider hindsight >/dev/null 2>&1
  echo "  memory.provider=hindsight"
}

materialize_all() {
  log "Materializing embedded daemon env files"
  "$PYTHON" - "$HERMES_ROOT" <<'PY'
import json, os, sys
from pathlib import Path
HERMES_ROOT = Path(sys.argv[1])
targets = [("hermes", HERMES_ROOT)]
pp = HERMES_ROOT / "profiles"
if pp.is_dir():
    targets += [(d.name, d) for d in sorted(x for x in pp.iterdir() if x.is_dir())]
sys.path.insert(0, str(HERMES_ROOT / "hermes-agent"))
from plugins.memory.hindsight import _materialize_embedded_profile_env
for label, prof in targets:
    cfg_path = prof / "hindsight" / "config.json"
    if not cfg_path.exists():
        continue
    cfg = json.loads(cfg_path.read_text())
    env = {}
    for line in (prof / ".env").read_text(encoding="utf-8").splitlines():
        if "=" in line and not line.startswith("#"):
            k, v = line.split("=", 1)
            env[k.strip()] = v.strip()
    key = env.get("HINDSIGHT_LLM_API_KEY", "")
    p = _materialize_embedded_profile_env(cfg, llm_api_key=key or None)
    print("  ", p)
PY
}

# ---- main ----
if [ "${1:-}" = "--halt" ] 2>/dev/null; then
  materialize_all
  echo "Done (materialize only)."
  exit 0
fi

if [ $# -eq 0 ]; then
  # default + all named profiles
  configure_profile "hermes" "$HERMES_ROOT"
  activate_provider "$HERMES_ROOT"
  for d in "$HERMES_ROOT"/profiles/*/; do
    [ -d "$d" ] || continue
    configure_profile "$(basename "$d")" "${d%/}"
    activate_provider "${d%/}"
  done
elif [ "${1:-}" = "--default" ]; then
  configure_profile "hermes" "$HERMES_ROOT"
  activate_provider "$HERMES_ROOT"
else
  for label in "$@"; do
    configure_profile "$label" "$HERMES_ROOT/profiles/$label"
    activate_provider "$HERMES_ROOT/profiles/$label"
  done
fi

materialize_all
echo
echo "Done. Start a new session per profile to activate hindsight."
