# Global preferences

- Prefer modern CLI tools: `rg` over grep, `fd` over find, `eza` over ls, `bat` over cat.
- Use `mise` for language runtime/version management.
- Use the `gh` CLI for GitHub operations (PRs, issues, checks).
- Primary stacks: TypeScript/JS, Swift/iOS, and Python (`uv` + `ruff` + `pyright`).
- Editor: Neovim.
- Commit message style: `component: imperative summary` (e.g. `nvim: fix lualine theme name`).
- Always use the `orca-cli` skill to create worktrees and spawn agents — not raw
  `git worktree` or direct `codex`/agent invocations.
- Spawn agents in yolo mode so they never stop for permission prompts:
  `claude --dangerously-skip-permissions`, `codex --dangerously-bypass-approvals-and-sandbox`.
