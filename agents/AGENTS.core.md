# Agent core conventions

Shared by every harness (Claude Code, Codex, OpenCode). Process rules only —
never technical judgment about code, so an implementer and its reviewer never
inherit the same blind spot.

## Hard rules

- **Never modify GitHub state without explicit approval from Guy**: no pushes to
  shared branches, no opening/closing issues, no creating or merging PRs, no
  releases, no repo settings. Local commits on your own worktree branch are fine.
- Always use Herdr for worktrees and agent sessions (`herdr` TUI/CLI; Hermes
  orchestrates and delegates). Don't hand-spawn competing agent sessions
  outside herdr.

## Review discipline

- **Every worktree gets two independent agents: an implementer, then a reviewer.**
  The reviewer is a *different model* from the implementer — independence is the
  whole point — spawned only after the implementer finishes, given a read-only
  brief (no edits, no commits, no push) and told to be adversarial rather than
  agreeable. Every commit on a branch gets reviewed, not just the first: a
  follow-up commit made after a review needs another review pass. Never merge on
  the implementer's own say-so.
- **Ask which model takes which role — don't assume.** Ask once when starting a
  piece of work, then reuse that pairing for the whole branch (a re-review should
  come from the same reviewer that raised the findings).

## Tooling

- Prefer modern CLI tools: `rg` over grep, `fd` over find, `eza` over ls, `bat` over cat.
- Use `mise` for language runtime/version management.
- Use the `gh` CLI for GitHub operations (read freely; writes need approval).
- Primary stacks: TypeScript/JS, Swift/iOS, and Python (`uv` + `ruff` + `pyright`).
- Editor: Neovim.
- Commit message style: `component: imperative summary` (e.g. `nvim: fix lualine theme name`).
- Spawn agents in yolo mode so they never stop for permission prompts:
  `claude --dangerously-skip-permissions`, `codex --dangerously-bypass-approvals-and-sandbox`.
- `fleet` (`~/.local/bin/fleet`) is the read-only status board for worktrees of one
  repo — agent state, commits ahead, uncommitted files, PR/CI, live models, and a
  delta since the last run. `fleet -v` for per-terminal detail, `-r <repo>` for
  another repo.

## Cost

- DeepSeek V4 Flash bills 2x during 08:00-11:00 and 13:00-17:00 Bangkok time.
  Prefer overnight or the 11:00-13:00 midday window for heavy unattended runs.
