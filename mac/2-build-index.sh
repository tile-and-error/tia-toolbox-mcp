#!/usr/bin/env bash
# Scrape the TIA Toolbox docs into a local search index named "tia-docs".
# Re-run any time to refresh it. Stored in ~/Library/Application Support/docs-mcp-server.
#
# Docs: https://github.com/arabold/docs-mcp-server
set -euo pipefail

info() { printf '[INFO]  %s\n' "$*"; }
ok()   { printf '[OK]    %s\n' "$*"; }
fail() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }
trap 'fail "Unexpected failure at line $LINENO: $BASH_COMMAND"' ERR

PKG=@arabold/docs-mcp-server@latest
LIBRARY=tia-docs
URL=https://tia-toolbox.readthedocs.io/en/stable/

command -v npx >/dev/null || fail "npx not found. Run mac/1-install-node.sh first."

info "Scraping $URL into '$LIBRARY' (takes a few minutes)..."
npx -y "$PKG" scrape "$LIBRARY" "$URL" || fail "Scrape failed. Check your internet connection and that $URL loads in a browser."

info "Test search for \"stain normalization\":"
npx -y "$PKG" search "$LIBRARY" "stain normalization" --limit 1 --quiet | grep '"url"' \
  || fail "Index was built but a test search returned nothing. Re-run this script."

ok "Index '$LIBRARY' ready. Next: connect an app (see README)."
