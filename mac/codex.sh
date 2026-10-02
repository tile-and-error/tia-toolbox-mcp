#!/usr/bin/env bash
# Connect OpenAI Codex (CLI + IDE extension) to docs-mcp-server.
#
# Not covered by the docs-mcp-server client guide; see OpenAI's docs:
#   https://learn.chatgpt.com/docs/extend/mcp?surface=cli
#
# Config file: ~/.codex/config.toml (or $CODEX_HOME/config.toml); backup saved as .bak.
# Shared by the Codex CLI, the Codex IDE extension and the ChatGPT desktop app.
#
# The TOML is written directly instead of via `codex mcp add` so startup_timeout_sec
# can be raised from 10s; the first `npx -y` download can take longer.
set -euo pipefail

info() { printf '[INFO]  %s\n' "$*"; }
ok()   { printf '[OK]    %s\n' "$*"; }
fail() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }
trap 'fail "Unexpected failure at line $LINENO: $BASH_COMMAND"' ERR

NAME=docs-mcp-server
CONFIG="${CODEX_HOME:-$HOME/.codex}/config.toml"

NPX="$(command -v npx)" || fail "npx not found. Run mac/1-install-node.sh first."
NODE_DIR="$(dirname "$(command -v node)")"

mkdir -p "$(dirname "$CONFIG")" || fail "Cannot create $(dirname "$CONFIG")."
touch "$CONFIG" || fail "Cannot write $CONFIG."

if grep -q "^\[mcp_servers\.$NAME\]" "$CONFIG"; then
  ok "$NAME is already in $CONFIG. To change it, edit or delete its [mcp_servers.$NAME] block and re-run."
  exit 0
fi

cp "$CONFIG" "$CONFIG.bak" || fail "Cannot back up $CONFIG."
info "Writing $NAME to $CONFIG..."
cat >> "$CONFIG" <<TOML || fail "Cannot write $CONFIG."

[mcp_servers.$NAME]
command = "$NPX"
args = ["-y", "@arabold/docs-mcp-server@latest"]
startup_timeout_sec = 60

[mcp_servers.$NAME.env]
PATH = "$NODE_DIR:/usr/bin:/bin"
TOML

ok "Connected. Restart Codex; 'codex mcp list' should show $NAME."
