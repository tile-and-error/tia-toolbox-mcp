#!/usr/bin/env bash
# Connect Claude Desktop to docs-mcp-server.
#
# Docs:
#   https://github.com/arabold/docs-mcp-server/blob/main/docs/guides/mcp-clients.md#claude-desktop
#   https://modelcontextprotocol.io/quickstart/user
#
# Config file: ~/Library/Application Support/Claude/claude_desktop_config.json
# (a backup is saved next to it as .bak)
#
# Claude Desktop doesn't inherit your shell PATH, so we write the absolute path
# to npx and pass PATH through so it finds the same Node.js.
set -euo pipefail

info() { printf '[INFO]  %s\n' "$*"; }
ok()   { printf '[OK]    %s\n' "$*"; }
fail() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }
trap 'fail "Unexpected failure at line $LINENO: $BASH_COMMAND"' ERR

NAME=docs-mcp-server
CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

NPX="$(command -v npx)" || fail "npx not found. Run mac/1-install-node.sh first."
NODE_DIR="$(dirname "$(command -v node)")"

mkdir -p "$(dirname "$CONFIG")" || fail "Cannot create $(dirname "$CONFIG")."
if [[ -f "$CONFIG" ]]; then
  cp "$CONFIG" "$CONFIG.bak" || fail "Cannot back up $CONFIG."
fi

info "Writing $NAME to $CONFIG..."
# Merge into the existing config so other servers and settings are kept.
CONFIG="$CONFIG" NAME="$NAME" NPX="$NPX" NODE_DIR="$NODE_DIR" node -e '
const fs = require("fs");
const { CONFIG, NAME, NPX, NODE_DIR } = process.env;
let cfg = {};
try {
  const text = fs.existsSync(CONFIG) ? fs.readFileSync(CONFIG, "utf8").trim() : "";
  if (text) cfg = JSON.parse(text);
} catch (e) {
  console.error(`[ERROR] ${CONFIG} is not valid JSON (${e.message}). Fix or delete it, then re-run.`);
  process.exit(1);
}
cfg.mcpServers = { ...cfg.mcpServers, [NAME]: {
  command: NPX,
  args: ["-y", "@arabold/docs-mcp-server@latest"],
  env: { PATH: `${NODE_DIR}:/usr/bin:/bin` },
} };
fs.writeFileSync(CONFIG, JSON.stringify(cfg, null, 2) + "\n");
' || exit 1

ok "Connected. Fully quit Claude Desktop (Cmd+Q) and reopen it."
