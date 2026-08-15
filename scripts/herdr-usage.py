#!/usr/bin/env python3
"""
herdr-usage — AI coding agent usage monitor (opencode / Claude Code / Codex).

Reports token + cost usage per agent, per workspace/project, per day,
similar to Orca's old "live board". Read-only: never writes to any agent
store. Python stdlib only (sqlite3, json, datetime) — no pip deps.

Query strategy (why this is fast on a 10.7 GB opencode.db):
  * The bulk of the DB size lives in the `part` and `event` tables
    (message content blobs / event sourcing). We never touch those.
  * `message` is small (~30k rows) and `session` is tiny (~300 rows).
    We filter by time_created in SQL BEFORE json_extract, so the JSON
    parse only runs on the time-bounded slice of rows.
  * opencode.db is opened with sqlite in read-only URI mode + query_only;
    it still reads the WAL (live DB), but can never checkpoint or write.
  * Claude Code and Codex are JSONL transcript dirs: we skip files whose
    mtime predates the requested window before parsing any lines.

Usage:
  herdr-usage                human-readable board (default: all data, bounded)
  herdr-usage --json         same data as JSON (for cron / Telegram digest)
  herdr-usage --today        today only (local time)
  herdr-usage --days N       last N days
  herdr-usage --all          explicit: no time bound (same as default)
"""

import argparse
import json
import os
import sqlite3
import sys
from datetime import datetime, timedelta

OPCODE_DB = os.path.expanduser("~/.local/share/opencode/opencode.db")
CLAUDE_DIR = os.path.expanduser("~/.claude/projects")
CODEX_DIR = os.path.expanduser("~/.codex/sessions")

AGENTS = ["opencode", "claude", "codex"]
DAY_MS = 86400000
WARNINGS = []


def local_date(ms):
    return datetime.fromtimestamp(ms / 1000.0).strftime("%Y-%m-%d")


def parse_iso_ts(ts):
    s = str(ts)
    for fmt in (
        "%Y-%m-%dT%H:%M:%S.%fZ",
        "%Y-%m-%dT%H:%M:%SZ",
        "%Y-%m-%dT%H:%M:%S.%f",
        "%Y-%m-%dT%H:%M:%S",
    ):
        try:
            return datetime.strptime(s, fmt)
        except ValueError:
            continue
    return None


def fmt_tokens(n):
    n = int(n or 0)
    if n >= 1e9:
        return f"{n / 1e9:.2f}B"
    if n >= 1e6:
        return f"{n / 1e6:.2f}M"
    if n >= 1e3:
        return f"{n / 1e3:.1f}K"
    return str(n)


def fmt_cost(c):
    if c is None:
        return "-"
    return f"${c:.4f}" if abs(c) >= 0.01 else f"${c:.6f}"


def workspace_label(path):
    """Short human label for a workspace path (last 2 meaningful parts)."""
    if not path:
        return "(unknown)"
    p = path.rstrip("/")
    parts = [x for x in p.split("/") if x]
    if len(parts) >= 2:
        return f"{parts[-2]}/{parts[-1]}"
    return p


def short_model(model, length=18):
    if not model or model == "mixed":
        return "mixed" if model else "-"
    return model if len(model) <= length else model[: length - 3] + "..."


# ---------------------------------------------------------------- opencode


def collect_opencode(rows, start_ms, end_ms):
    """Read token/cost usage from opencode's SQLite store (read-only)."""
    if not os.path.exists(OPCODE_DB):
        WARNINGS.append(f"opencode: DB not found at {OPCODE_DB} — skipped")
        return
    try:
        conn = sqlite3.connect(f"file:{OPCODE_DB}?mode=ro", uri=True, timeout=10)
    except sqlite3.Error as e:
        WARNINGS.append(f"opencode: read-only open failed ({e}); skipped")
        return
    try:
        conn.execute("PRAGMA query_only=ON")
    except sqlite3.Error as e:
        WARNINGS.append(f"opencode: read-only open failed ({e}); skipped")
        return
    try:
        sessions = {}
        for sid, directory, smodel in conn.execute(
            "SELECT id, directory, model FROM session"
        ):
            m = None
            if smodel:
                try:
                    m = json.loads(smodel).get("id")
                except (ValueError, AttributeError):
                    m = None
            sessions[sid] = (directory or "", m or "")
        cur = conn.execute(
            "SELECT session_id, time_created, data FROM message "
            "WHERE time_created >= ? AND time_created <= ?",
            (int(start_ms), int(end_ms)),
        )
        for session_id, t, data in cur:
            try:
                d = json.loads(data)
            except ValueError:
                continue
            tokens = d.get("tokens") or {}
            cache = tokens.get("cache") or {}
            directory, smodel = sessions.get(session_id, ("", ""))
            cwd = (d.get("path") or {}).get("cwd") or directory
            rows.append(
                {
                    "agent": "opencode",
                    "workspace": workspace_label(cwd),
                    "workspace_path": cwd,
                    "day": local_date(t),
                    "model": d.get("modelID") or smodel or "",
                    "input": tokens.get("input") or 0,
                    "output": tokens.get("output") or 0,
                    "cache_read": cache.get("read") or 0,
                    "cache_write": cache.get("write") or 0,
                    "cost": d.get("cost"),
                }
            )
    except sqlite3.Error as e:
        WARNINGS.append(f"opencode: query failed ({e}); skipped")
    finally:
        conn.close()


# ------------------------------------------------------------------ claude


def collect_claude(rows, start_ms, end_ms):
    """Read usage from Claude Code JSONL transcripts (~/.claude/projects)."""
    if not os.path.isdir(CLAUDE_DIR):
        WARNINGS.append(f"claude: no transcripts dir at {CLAUDE_DIR} — skipped")
        return
    margin = start_ms - DAY_MS
    min_day = local_date(start_ms) if start_ms else None
    found = 0
    for dirpath, _dirs, files in os.walk(CLAUDE_DIR):
        for fn in sorted(files):
            if not fn.endswith(".jsonl"):
                continue
            fp = os.path.join(dirpath, fn)
            try:
                if os.path.getmtime(fp) * 1000 < margin:
                    continue
            except OSError:
                continue
            workspace_path = None
            session_rows = []
            try:
                with open(fp, "r", errors="replace") as fh:
                    for line in fh:
                        line = line.strip()
                        if not line:
                            continue
                        try:
                            d = json.loads(line)
                        except ValueError:
                            continue
                        if not workspace_path:
                            ws = d.get("cwd")
                            if ws:
                                workspace_path = ws
                            elif d.get("type") == "session":
                                workspace_path = _claude_decode_dir(dirpath)
                        u = (d.get("message") or {}).get("usage")
                        if not isinstance(u, dict):
                            continue
                        ts = parse_iso_ts(d.get("timestamp"))
                        day = local_date(int(ts.timestamp() * 1000)) if ts else None
                        if day is None or (min_day and day < min_day):
                            continue
                        session_rows.append(
                            {
                                "agent": "claude",
                                "workspace": workspace_label(workspace_path or dirpath),
                                "workspace_path": workspace_path
                                or _claude_decode_dir(dirpath),
                                "day": day,
                                "model": "",
                                "input": u.get("input_tokens") or 0,
                                "output": u.get("output_tokens") or 0,
                                "cache_read": u.get("cache_read_input_tokens") or 0,
                                "cache_write": u.get("cache_creation_input_tokens")
                                or 0,
                                "cost": None,
                            }
                        )
            except OSError:
                continue
            rows.extend(session_rows)
            found += len(session_rows)
    if not found:
        WARNINGS.append("claude: no usage records found in transcripts")


def _claude_decode_dir(dirpath):
    """'/…/-Users-x-Projects-y' -> '/Users/x/Projects/y' (approx)."""
    name = os.path.basename(dirpath.rstrip("/")) if dirpath else ""
    return "/" + name.lstrip("-").replace("-", "/") if name else ""


# ------------------------------------------------------------------ codex


def collect_codex(rows, start_ms, end_ms):
    """Read usage from Codex rollout JSONL files (~/.codex/sessions)."""
    if not os.path.isdir(CODEX_DIR):
        WARNINGS.append(f"codex: no sessions dir at {CODEX_DIR} — skipped")
        return
    margin = start_ms - DAY_MS
    min_day = local_date(start_ms) if start_ms else None
    found = 0
    for dirpath, _dirs, files in os.walk(CODEX_DIR):
        for fn in sorted(files):
            if not (fn.startswith("rollout-") and fn.endswith(".jsonl")):
                continue
            fp = os.path.join(dirpath, fn)
            try:
                if os.path.getmtime(fp) * 1000 < margin:
                    continue
            except OSError:
                continue
            cwd = None
            best = None  # total_token_usage is cumulative per session: keep max
            day = None
            try:
                with open(fp, "r", errors="replace") as fh:
                    for line in fh:
                        line = line.strip()
                        if not line:
                            continue
                        try:
                            d = json.loads(line)
                        except ValueError:
                            continue
                        p = d.get("payload")
                        if d.get("type") == "session_meta" and isinstance(p, dict):
                            cwd = p.get("cwd") or cwd
                        if (
                            d.get("type") == "event_msg"
                            and isinstance(p, dict)
                            and p.get("type") == "token_count"
                        ):
                            info = p.get("info") or {}
                            tt = info.get("total_token_usage")
                            if isinstance(tt, dict):
                                best = (
                                    tt
                                    if best is None
                                    else (
                                        tt
                                        if (tt.get("input_tokens") or 0)
                                        > (best.get("input_tokens") or 0)
                                        else best
                                    )
                                )
                            if not day and info.get("total_tokens"):
                                d0 = fn.split("rollout-", 1)[-1][:10]
                                if len(d0) == 10 and d0[4] == "-":
                                    day = d0
            except OSError:
                continue
            if not best:
                continue
            day = day or local_date(os.path.getmtime(fp) * 1000)
            if min_day and day < min_day:
                continue
            rows.append(
                {
                    "agent": "codex",
                    "workspace": workspace_label(cwd),
                    "workspace_path": cwd or "",
                    "day": day or local_date(os.path.getmtime(fp) * 1000),
                    "model": "",
                    "input": best.get("input_tokens") or 0,
                    "output": best.get("output_tokens") or 0,
                    "cache_read": best.get("cached_input_tokens") or 0,
                    "cache_write": best.get("cache_write_input_tokens") or 0,
                    "cost": None,
                }
            )
            found += 1
    if not found:
        WARNINGS.append("codex: no rollout files with usage found")


# --------------------------------------------------------------- merge/io


def merge_rows(rows):
    """Aggregate per (agent, workspace_path, day); keep distinct models."""
    merged = {}
    for r in rows:
        key = (r["agent"], r["workspace_path"], r["day"])
        m = merged.setdefault(
            key,
            {
                "agent": r["agent"],
                "workspace": r["workspace"],
                "workspace_path": r["workspace_path"],
                "day": r["day"],
                "models": set(),
                "input": 0,
                "output": 0,
                "cache_read": 0,
                "cache_write": 0,
                "cost": 0.0,
                "cost_known": False,
            },
        )
        m["input"] += r["input"]
        m["output"] += r["output"]
        m["cache_read"] += r["cache_read"]
        m["cache_write"] += r["cache_write"]
        if r["model"]:
            m["models"].add(r["model"])
        if r["cost"] is not None:
            m["cost"] += r["cost"]
            m["cost_known"] = True
    out = []
    for m in merged.values():
        out.append(
            {
                "agent": m["agent"],
                "workspace": m["workspace"],
                "workspace_path": m["workspace_path"],
                "day": m["day"],
                "model": sorted(m["models"])[0]
                if len(m["models"]) == 1
                else ("mixed" if m["models"] else ""),
                "models": sorted(m["models"]),
                "input_tokens": m["input"],
                "output_tokens": m["output"],
                "cache_read_tokens": m["cache_read"],
                "cache_write_tokens": m["cache_write"],
                "cost_usd": m["cost"] if m["cost_known"] else None,
            }
        )
    out.sort(
        key=lambda r: (
            AGENTS.index(r["agent"]),
            r["day"],
            r["cost_usd"] is None,
            -(r["cost_usd"] or 0),
        )
    )
    out.sort(key=lambda r: r["day"], reverse=True)
    out.sort(key=lambda r: AGENTS.index(r["agent"]))
    return out


def agent_totals(rows):
    totals = {}
    for r in rows:
        t = totals.setdefault(
            r["agent"],
            {
                "input": 0,
                "output": 0,
                "cache_read": 0,
                "cache_write": 0,
                "cost": 0.0,
                "cost_known": False,
                "workspaces": set(),
            },
        )
        t["input"] += r["input_tokens"]
        t["output"] += r["output_tokens"]
        t["cache_read"] += r["cache_read_tokens"]
        t["cache_write"] += r["cache_write_tokens"]
        t["workspaces"].add(r["workspace_path"])
        if r["cost_usd"] is not None:
            t["cost"] += r["cost_usd"]
            t["cost_known"] = True
    return totals


def render_board(rows):
    totals = agent_totals(rows)
    lines = []
    w = max(28, max((len(r["workspace"]) for r in rows), default=10))
    for agent in AGENTS:
        agent_rows = [r for r in rows if r["agent"] == agent]
        if not agent_rows:
            continue
        n_ws = len(totals[agent]["workspaces"])
        lines.append(
            f"{agent}  ({len(agent_rows)} workspace-day rows, {n_ws} workspaces)"
        )
        lines.append(
            "  "
            + "  ".join(
                [
                    "DAY".ljust(10),
                    "WORKSPACE".ljust(w),
                    "MODEL".ljust(20),
                    "INPUT".rjust(9),
                    "OUTPUT".rjust(9),
                    "CACHE R/W".rjust(17),
                    "COST".rjust(11),
                ]
            )
        )
        for r in agent_rows:
            cache = f"{fmt_tokens(r['cache_read_tokens'])}/{fmt_tokens(r['cache_write_tokens'])}"
            cost = fmt_cost(r["cost_usd"])
            lines.append(
                "  "
                + "  ".join(
                    [
                        r["day"].ljust(10),
                        r["workspace"].ljust(w),
                        short_model(r["model"]).ljust(20),
                        fmt_tokens(r["input_tokens"]).rjust(9),
                        fmt_tokens(r["output_tokens"]).rjust(9),
                        cache.rjust(17),
                        cost.rjust(11),
                    ]
                )
            )
        t = totals[agent]
        cost = fmt_cost(t["cost"] if t["cost_known"] else None)
        lines.append(
            "  "
            + "  ".join(
                [
                    "TOTAL".ljust(10),
                    f"({len([r for r in agent_rows])} rows)".ljust(w),
                    "-".ljust(20),
                    fmt_tokens(t["input"]).rjust(9),
                    fmt_tokens(t["output"]).rjust(9),
                    f"{fmt_tokens(t['cache_read'])}/{fmt_tokens(t['cache_write'])}".rjust(
                        17
                    ),
                    cost.rjust(11),
                ]
            )
        )
        lines.append("")
    gt = {
        "input": 0,
        "output": 0,
        "cache_read": 0,
        "cache_write": 0,
        "cost": 0.0,
        "cost_known": False,
    }
    for r in rows:
        gt["input"] += r["input_tokens"]
        gt["output"] += r["output_tokens"]
        gt["cache_read"] += r["cache_read_tokens"]
        gt["cache_write"] += r["cache_write_tokens"]
        if r["cost_usd"] is not None:
            gt["cost"] += r["cost_usd"]
            gt["cost_known"] = True
    cost = fmt_cost(gt["cost"] if gt["cost_known"] else None)
    lines.append(
        "  ".join(
            [
                "GRAND TOTAL".ljust(10),
                f"({len(rows)} rows)".ljust(w),
                "-".ljust(20),
                fmt_tokens(gt["input"]).rjust(9),
                fmt_tokens(gt["output"]).rjust(9),
                f"{fmt_tokens(gt['cache_read'])}/{fmt_tokens(gt['cache_write'])}".rjust(
                    17
                ),
                cost.rjust(11),
            ]
        )
    )
    lines.append("")
    lines.append(
        "Cost: only opencode records USD; claude/codex show '-' (tokens only)."
    )
    return "\n".join(lines)


def main():
    ap = argparse.ArgumentParser(description="herdr-usage: AI agent usage monitor")
    ap.add_argument(
        "--json", action="store_true", help="emit JSON instead of the board"
    )
    ap.add_argument("--today", action="store_true", help="today only (local time)")
    ap.add_argument("--days", type=int, metavar="N", help="last N days")
    ap.add_argument("--all", action="store_true", help="all data (default)")
    args = ap.parse_args()

    now = datetime.now()
    now_ms = int(now.timestamp() * 1000)
    if args.today and args.days:
        ap.error("--today and --days are mutually exclusive")
    if args.today:
        start_dt = now.replace(hour=0, minute=0, second=0, microsecond=0)
    elif args.days:
        start_dt = now - timedelta(days=args.days)
    else:
        start_dt = None  # unbounded (all data)
    start_ms = int(start_dt.timestamp() * 1000) if start_dt else 0
    end_ms = now_ms

    rows = []
    collect_opencode(rows, start_ms, end_ms)
    collect_claude(rows, start_ms, end_ms)
    collect_codex(rows, start_ms, end_ms)
    merged = merge_rows(rows)

    if args.json:
        payload = {
            "generated_at": now.isoformat(timespec="seconds"),
            "range": {
                "start": local_date(start_ms) if start_ms else "all",
                "end": local_date(end_ms),
            },
            "rows": merged,
            "totals": {
                a: {
                    "input_tokens": t["input"],
                    "output_tokens": t["output"],
                    "cache_read_tokens": t["cache_read"],
                    "cache_write_tokens": t["cache_write"],
                    "cost_usd": t["cost"] if t["cost_known"] else None,
                    "workspaces": len(t["workspaces"]),
                }
                for a, t in agent_totals(merged).items()
            },
            "warnings": WARNINGS,
        }
        print(json.dumps(payload, indent=2))
        return 0

    print(render_board(merged))
    if WARNINGS:
        print("\nWarnings:")
        for w in WARNINGS:
            print(f"  - {w}")
    print("")
    print("Note: a small shell wrapper (e.g. ~/.local/bin/herdr-usage ->")
    print("'python3 ~/.local/share/herdr/herdr-usage.py' or a `herdr-usage`")
    print("alias in zsh aliases) is worth adding so cron/Telegram digests and")
    print("muscle memory can call 'herdr-usage --json --days 1' directly.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
