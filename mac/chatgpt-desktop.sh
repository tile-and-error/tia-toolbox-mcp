#!/usr/bin/env bash
# Connect the ChatGPT desktop app to docs-mcp-server.
#
# Docs: https://learn.chatgpt.com/docs/extend/mcp?surface=app
#
# The ChatGPT desktop app shares its MCP config with Codex (~/.codex/config.toml),
# so this runs codex.sh.
#
# Manual alternative in the app:
#   Settings > MCP servers > Add server > STDIO
#     Name:    docs-mcp-server
#     Command: npx -y @arabold/docs-mcp-server@latest
#   Save, then Restart.
set -euo pipefail

"$(dirname "$0")/codex.sh"
printf '[OK]    Restart the ChatGPT desktop app (or Settings > MCP servers > Restart).\n'
