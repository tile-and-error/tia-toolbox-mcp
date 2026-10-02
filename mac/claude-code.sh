#!/usr/bin/env bash
# Connect Claude Code (CLI) to docs-mcp-server.
#
# Docs:
#   https://github.com/arabold/docs-mcp-server/blob/main/docs/guides/mcp-clients.md#claude-code
#   https://docs.anthropic.com/en/docs/claude-code/mcp
#
# Config is written by the `claude` CLI itself:
#   user    -> ~/.claude.json, all projects (default)
#   local   -> ~/.claude.json, current project only
#   project -> ./.mcp.json, shared via the repo
#
# Usage: mac/claude-code.sh [user|local|project]
set -euo pipefail

info() { printf '[INFO]  %s\n' "$*"; }
ok()   { printf '[OK]    %s\n' "$*"; }
fail() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }
trap 'fail "Unexpected failure at line $LINENO: $BASH_COMMAND"' ERR

NAME=docs-mcp-server
SCOPE="${1:-user}"

[[ "$SCOPE" =~ ^(user|local|project)$ ]] || fail "Unknown scope '$SCOPE'. Use user, local or project."
command -v npx >/dev/null || fail "npx not found. Run mac/1-install-node.sh first."
command -v claude >/dev/null || fail "Claude Code not found. Install it: https://docs.anthropic.com/en/docs/claude-code/setup"

if claude mcp get "$NAME" >/dev/null 2>&1; then
  ok "$NAME is already connected to Claude Code."
  exit 0
fi

info "Adding $NAME to Claude Code (scope: $SCOPE)..."
claude mcp add --scope "$SCOPE" "$NAME" -- npx -y @arabold/docs-mcp-server@latest \
  || fail "'claude mcp add' failed. See the message above."

ok "Connected. Restart any open Claude Code sessions."
