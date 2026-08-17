#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVERS_FILE="$REPO_ROOT/mcp/servers.json"
OPENCODE_GLOBAL="$REPO_ROOT/opencode/opencode.jsonc"
CODEX_PROFILES_DIR="$REPO_ROOT/codex/profiles"
MODE="apply"
FORCE=0

usage() {
  cat <<'EOF'
sync-mcp.sh — sync MCP servers from mcp/servers.json to all agent tools

Usage:
  sync-mcp.sh                 apply: write generated files, run vendor mutators
  sync-mcp.sh --dry-run       show what would change without writing
  sync-mcp.sh --check         verify everything is in sync; exit 1 on drift
  sync-mcp.sh --force         allow writes into dirty project worktrees

Writes (per tool):
  opencode  global     opencode/opencode.jsonc   (checked only; hand-maintained)
  opencode  per-project opencode.json            (generated, committed by user)
  codex     global      ~/.codex/config.toml     via `codex mcp add`
  codex     per-project codex/profiles/<p>.config.toml (dotter -> ~/.codex/)
  claude    global      ~/.claude.json           via `claude mcp add -s user`
  claude    per-project .mcp.json                via `claude mcp add -s project`

Never commits or pushes.
EOF
  exit "${1:-0}"
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) MODE="dry-run" ;;
    --check) MODE="check" ;;
    --force) FORCE=1 ;;
    -h|--help) usage 0 ;;
    *) echo "unknown option: $arg" >&2; usage 1 ;;
  esac
done

command -v python3 >/dev/null || { echo "python3 required" >&2; exit 1; }
command -v claude >/dev/null || { echo "claude CLI required" >&2; exit 1; }
command -v codex >/dev/null || { echo "codex CLI required" >&2; exit 1; }

# -- wrong-tree guard: refuse writes when running from a non-deployed checkout
deployed_target="$(readlink -f ~/.config/opencode/opencode.jsonc 2>/dev/null || true)"
if [ -n "$deployed_target" ] && [ "$deployed_target" != "$OPENCODE_GLOBAL" ] && [ "$MODE" = "apply" ]; then
  echo "ERROR: running from a checkout that is not the deployed dotfiles repo" >&2
  echo "  (deployed: $deployed_target)" >&2
  echo "  (this repo: $OPENCODE_GLOBAL)" >&2
  echo "Run from $HOME/Projects/dotfiles, or use --check." >&2
  exit 1
fi

plan() { # mode, msg
  case "$MODE" in
    apply) echo "  [apply] $2" ;;
    dry-run) echo "  [dry]   $2" ;;
    check) echo "  [check] $2" ;;
  esac
}

PY_EMIT=$(python3 - "$SERVERS_FILE" <<'PYEOF'
import json, sys, os

with open(sys.argv[1]) as f:
    data = json.load(f)

def build_url(server):
    url = server["url"]
    if server.get("read_only", True) and "read_only" not in url:
        url += "&read_only=true" if "?" in url else "?read_only=true"
    return url

global_servers = [
    {"name": s["name"], "url": build_url(s)}
    for s in data.get("global", [])
]

projects = {}
for pname, p in data.get("projects", {}).items():
    path = os.path.expanduser(p["path"])
    projects[pname] = {
        "path": path,
        "servers": [
            {"name": s["name"], "url": build_url(s), "read_only": s.get("read_only", True)}
            for s in p["servers"]
        ],
    }

print(json.dumps({"global": global_servers, "projects": projects}, indent=2))
PYEOF
)

exit_code=0

# ---------------------------------------------------------------- global checks
# opencode global: hand-maintained; verify mcp section matches servers.json
if ! python3 - "$OPENCODE_GLOBAL" "$PY_EMIT" <<'PYEOF'
import json, sys

def strip_jsonc(src):
    out = []
    i, n = 0, len(src)
    in_str = False
    while i < n:
        c = src[i]
        if in_str:
            out.append(c)
            if c == '\\' and i + 1 < n:
                out.append(src[i + 1])
                i += 2
                continue
            if c == '"':
                in_str = False
            i += 1
            continue
        if c == '"':
            in_str = True
            out.append(c)
            i += 1
            continue
        if c == '/' and src[i + 1:i + 2] == '/':
            while i < n and src[i] != '\n':
                i += 1
            continue
        if c == '/' and src[i + 1:i + 2] == '*':
            i += 2
            while i < n and src[i:i + 2] != '*/':
                i += 1
            i += 2
            continue
        out.append(c)
        i += 1
    return ''.join(out)

expected = {s["name"]: {"type": "remote", "url": s["url"]}
            for s in json.loads(sys.argv[2])["global"]}
with open(sys.argv[1]) as f:
    cfg = json.loads(strip_jsonc(f.read()))
actual = cfg.get("mcp", {})
problems = []
for name, spec in expected.items():
    if name not in actual:
        problems.append(f"missing mcp entry: {name}")
    elif actual[name].get("url") != spec["url"]:
        problems.append(f"url drift for {name}:\n  expected: {spec['url']}\n  actual:   {actual[name].get('url')}")
for name in actual:
    if name not in expected:
        problems.append(f"extra mcp entry in opencode.jsonc (not in servers.json): {name}")
if problems:
    print("opencode global mcp section out of sync with servers.json:")
    for p in problems:
        print(f"  - {p}")
    sys.exit(1)
print("ok  opencode global mcp section matches servers.json")
PYEOF
then
  exit_code=1
fi

# ---------------------------------------------------------------- per-project
while IFS= read -r pname; do
  [ -n "$pname" ] || continue
  pdata=$(python3 -c "
import json, sys
d = json.loads(sys.argv[1])
print(json.dumps(d['projects'][sys.argv[2]]))
" "$PY_EMIT" "$pname")
  ppath=$(python3 -c "import json,sys; print(json.loads(sys.argv[1])['path'])" "$pdata")
  servers_json=$(python3 -c "
import json, sys
d = json.loads(sys.argv[1])
print(json.dumps([{'name': s['name'], 'type': 'remote', 'url': s['url']} for s in d['servers']], indent=2))
" "$pdata")

  # codex per-project profile (dotfiles-owned, dotter-deployed).
  # Generated BEFORE the dirty-worktree guard: project dirtiness must not
  # block the dotfiles-owned profile (broken dotter mapping otherwise).
  profile="$CODEX_PROFILES_DIR/$pname.config.toml"
  expected_profile=$(python3 - "$pdata" <<'PYEOF'
import json, sys
pdata = json.loads(sys.argv[1])
lines = []
for s in pdata["servers"]:
    lines.append(f'[mcp_servers.{s["name"]}]')
    lines.append(f'url = "{s["url"]}"')
    lines.append("")
print("\n".join(lines))
PYEOF
)
  if [ -f "$profile" ] && [ "$(cat "$profile")" = "$expected_profile" ]; then
    plan "$MODE" "$pname: codex profile up to date"
  else
    plan "$MODE" "$pname: codex profile (re)generated"
    if [ "$MODE" = "apply" ]; then
      mkdir -p "$CODEX_PROFILES_DIR"
      printf '%s' "$expected_profile" > "$profile"
      echo "    wrote $profile (dotter deploys to ~/.codex/$pname.config.toml)"
    fi
    [ "$MODE" = "check" ] && exit_code=1
  fi

  if [ ! -d "$ppath/.git" ]; then
    echo "  - skipping $pname: not a git repo at $ppath" >&2
    continue
  fi

  # dirty worktree guard (apply mode; guards only project writes)
  dirty=$(git -C "$ppath" status --porcelain 2>/dev/null || true)
  if [ -n "$dirty" ] && [ "$MODE" = "apply" ] && [ "$FORCE" -ne 1 ]; then
    echo "ERROR: $pname has uncommitted changes; refusing to write (use --force to override):" >&2
    echo "$dirty" | sed 's/^/  /' >&2
    exit_code=1
    continue
  fi

  opencode_file="$ppath/opencode.json"
  expected_opencode=$(python3 - "$servers_json" <<'PYEOF'
import json, sys
servers = json.loads(sys.argv[1])
body = {"$schema": "https://opencode.ai/config.json", "mcp": {s["name"]: {"type": "remote", "url": s["url"]} for s in servers}}
print(json.dumps(body, indent=2) + "\n")
PYEOF
)

  if [ -f "$opencode_file" ]; then
    current=$(cat "$opencode_file")
    if [ "$current" != "$expected_opencode" ]; then
      plan "$MODE" "$pname: opencode.json drift (expected: regen, actual: differs)"
      if [ "$MODE" = "apply" ]; then
        printf '%s' "$expected_opencode" > "$opencode_file"
        echo "    wrote $opencode_file (review + commit manually)"
      else
        echo "    diff -- $opencode_file" >&2
      fi
      [ "$MODE" = "check" ] && exit_code=1
    else
      plan "$MODE" "$pname: opencode.json up to date"
    fi
  else
    plan "$MODE" "$pname: opencode.json missing (generating)"
    if [ "$MODE" = "apply" ]; then
      printf '%s' "$expected_opencode" > "$opencode_file"
      echo "    wrote $opencode_file (review + commit manually)"
    fi
    [ "$MODE" = "check" ] && exit_code=1
  fi

  # claude per-project: vendor mutator keeps .mcp.json in sync
  mcpjson="$ppath/.mcp.json"
  if [ "$MODE" = "check" ]; then
    if [ -f "$mcpjson" ]; then
      if ! python3 - "$mcpjson" "$pdata" <<'PYEOF'
import json, sys
expected = {s["name"]: {"type": "http", "url": s["url"]} for s in json.loads(sys.argv[2])["servers"]}
actual = json.load(open(sys.argv[1])).get("mcpServers", {})
ok = True
for name, spec in expected.items():
    if actual.get(name, {}).get("url") != spec["url"]:
        print(f"  - {sys.argv[1]}: url drift for {name}")
        ok = False
sys.exit(0 if ok else 1)
PYEOF
      then
        exit_code=1
      fi
    else
      echo "  - $pname: .mcp.json missing (run without --check to create via claude mcp add)" >&2
      exit_code=1
    fi
  else
    if [ "$MODE" = "dry-run" ]; then
      python3 - "$pdata" <<'PYEOF'
import json, sys, shlex
pdata = json.loads(sys.argv[1])
for s in pdata["servers"]:
    print(f"  [dry]   claude mcp add -s project --transport http {s['name']} {shlex.quote(s['url'])} (in {pdata['path']})")
PYEOF
    else
      python3 - "$pdata" <<'PYEOF'
import json, sys, subprocess
pdata = json.loads(sys.argv[1])
for s in pdata["servers"]:
    args = ["claude", "mcp", "add", "-s", "project", "--transport", "http", s["name"], s["url"]]
    r = subprocess.run(args, cwd=pdata["path"], capture_output=True, text=True)
    combined = (r.stdout + r.stderr).strip()
    if r.returncode != 0:
        if "already exists" in combined:
            # claude mcp add refuses existing entries; verify the entry
            # actually matches, and re-add after removal when it drifts
            with open(f"{pdata['path']}/.mcp.json") as f:
                cur = json.load(f).get("mcpServers", {}).get(s["name"], {}).get("url")
            if cur != s["url"]:
                subprocess.run(["claude", "mcp", "remove", "-s", "project", s["name"]],
                               cwd=pdata["path"], capture_output=True, text=True)
                r2 = subprocess.run(args, cwd=pdata["path"], capture_output=True, text=True)
                if r2.returncode != 0:
                    print(f"ERROR: re-add failed for {s['name']} in {pdata['path']}", file=sys.stderr)
                    print((r2.stdout + r2.stderr).strip(), file=sys.stderr)
                    sys.exit(1)
            else:
                print(f"  [apply] claude: {s['name']} already registered with matching url")
        else:
            print(f"ERROR: claude mcp add failed for {s['name']} in {pdata['path']}", file=sys.stderr)
            print(combined, file=sys.stderr)
            sys.exit(1)
PYEOF
      plan "$MODE" "$pname: claude .mcp.json synced via claude mcp add"
    fi
  fi
done < <(python3 -c "
import json, sys
d = json.loads(sys.argv[1])
print('\n'.join(d['projects'].keys()))
" "$PY_EMIT")

# ---------------------------------------------------------------- global mutators
# single registry parser, shared by check and apply (same data, same drift logic)
if ! python3 - "$PY_EMIT" "$MODE" <<'PYEOF'
import json, sys, subprocess, shlex, re

emit = json.loads(sys.argv[1])
mode = sys.argv[2]
global_servers = emit["global"]

def codex_registered():
    out = subprocess.run(["codex", "mcp", "list"], capture_output=True, text=True).stdout
    reg = {}
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 2 and parts[1].startswith("http"):
            reg[parts[0]] = parts[1]
    return reg

def claude_registered():
    out = subprocess.run(["claude", "mcp", "list"], capture_output=True, text=True).stdout
    reg = {}
    for line in out.splitlines():
        m = re.match(r"^\s*(?:[\w.]+ )*([\w.-]+):\s+(https?://\S+)", line)
        if m:
            reg[m.group(1)] = m.group(2)
    return reg

regs = {"codex": codex_registered(), "claude": claude_registered()}

for s in global_servers:
    for tool in ("codex", "claude"):
        name, url = s["name"], s["url"]
        reg = regs[tool]
        if name in reg:
            if reg[name] == url:
                if mode == "check":
                    print(f"ok  {tool} global mcp: {name} present with matching url")
                else:
                    print(f"  [apply] {tool}: {name} already registered with matching url")
            else:
                print(f"ERROR: {tool} global mcp {name}: url drift", file=sys.stderr)
                print(f"  registered: {reg[name]}", file=sys.stderr)
                print(f"  expected:   {url}", file=sys.stderr)
                print(f"  fix: {tool} mcp remove {name} && re-run (codex re-add re-triggers OAuth)", file=sys.stderr)
                sys.exit(1)
        else:
            if mode == "check":
                print(f"  - {tool} global mcp: {name} missing (run without --check to add)", file=sys.stderr)
                sys.exit(1)
            if mode == "dry-run":
                args = ["claude", "mcp", "add", "-s", "user", "--transport", "http", name, url] if tool == "claude" \
                       else ["codex", "mcp", "add", name, "--url", url]
                print(f"  [dry]   would run: {shlex.join(args)}")
            else:
                args = ["claude", "mcp", "add", "-s", "user", "--transport", "http", name, url] if tool == "claude" \
                       else ["codex", "mcp", "add", name, "--url", url]
                subprocess.run(args, check=True)
                print(f"  [apply] {tool}: registered {name}")
PYEOF
then
  exit_code=1
fi

if [ "$MODE" = "apply" ]; then
  echo "done. Restart opencode. Codex per-project MCP: spawn with codex -p <project>."
  echo "Remember: dotter deploy needed for new codex profile mappings."
fi

exit $exit_code
