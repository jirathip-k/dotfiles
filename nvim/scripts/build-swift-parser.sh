#!/usr/bin/env bash
# Build & install the tree-sitter Swift parser for nvim-treesitter (master branch).
#
# Why: on Neovim's tree-sitter ABI 15, the master branch can't auto-generate
# grammars that ship only a grammar.js (swift, latex). We generate + compile the
# parser ourselves with the modern `tree-sitter` CLI, which handles ABI 15 fine.
#
# Requirements: `tree-sitter` CLI (cargo install tree-sitter-cli), a C compiler,
# git. nvim-treesitter must already be installed by lazy.nvim.
#
# Usage: nvim/scripts/build-swift-parser.sh
set -euo pipefail

PARSER_DIR="${HOME}/.local/share/nvim/lazy/nvim-treesitter/parser"
if [[ ! -d "$PARSER_DIR" ]]; then
	echo "error: $PARSER_DIR not found — open nvim once so lazy.nvim installs nvim-treesitter." >&2
	exit 1
fi

if ! command -v tree-sitter >/dev/null; then
	echo "error: tree-sitter CLI not found. Install with: cargo install tree-sitter-cli" >&2
	exit 1
fi

# Pin to the revision nvim-treesitter's master lockfile expects, so the parser
# matches master's bundled swift queries (highlights/indents/...).
SWIFT_REV="aca5a52aa3cab858944d3c02701ccf5b2d8fd0f9"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Cloning tree-sitter-swift @ ${SWIFT_REV}..."
git clone -q https://github.com/alex-pinkus/tree-sitter-swift "$tmp/swift"
cd "$tmp/swift"
git checkout -q "$SWIFT_REV"

echo "Generating parser..."
tree-sitter generate >/dev/null

echo "Building swift.so..."
tree-sitter build -o swift.so .

cp swift.so "$PARSER_DIR/swift.so"
echo "Installed: $PARSER_DIR/swift.so"
