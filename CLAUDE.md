# dotfiles

Managed with [dotter](https://github.com/SuperCuber/dotter). Deployed files
are symlinks — edits under this repo are live immediately, no redeploy needed.

- New file mapping: add it to `.dotter/global.toml` (and the package to
  `.dotter/local.toml` if it's a new package), then run `dotter deploy`.
- Refresh the package list: `brew bundle dump --file Brewfile --force`.
- Commit style: `component: imperative summary`.
- README.md has the full layout table — keep it updated when adding packages.
