# Orca integration

When running inside an Orca terminal or worktree (detectable via the
`ORCA_CLI_COMMAND` environment variable being set, or `orca status --json`
succeeding):

- Load the **orca-cli** skill before issuing any `orca` command and follow its
  executable-resolution rules (`ORCA_CLI_COMMAND` → `orca-dev` → `orca-ide` → `orca`).
- Use the **orchestration** skill for multi-agent coordination flows (handoffs,
  task DAGs, decision gates) and **computer-use** for desktop UI automation.
- Prefer `--json` output for agent-driven Orca calls.
