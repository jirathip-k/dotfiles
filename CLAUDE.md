# CLAUDE.md

Guidance for agents (and humans) working in this repo.

## Repo layout

- `nvim/` — Neovim configuration written in Lua (the bulk of this repo's code).
- Other top-level dotfiles/config as applicable.

## Checks

This repo uses [StyLua](https://github.com/JohnnyMorganz/StyLua) as a formatting/lint gate
for the Lua config under `nvim/`. Configuration lives in `stylua.toml` at the repo root.

Run the lint check before committing changes under `nvim/`:

```sh
stylua --check nvim/
```

To auto-format in place:

```sh
stylua nvim/
```

A small number of pre-existing files that don't yet conform to the shared style are
temporarily listed in `.styluaignore` and are exempt from the check pending a follow-up
formatting pass. Do not add new files to `.styluaignore` — new/edited Lua files are
expected to pass `stylua --check nvim/` as written.
