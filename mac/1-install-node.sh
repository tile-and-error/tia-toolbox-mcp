#!/usr/bin/env bash
# Install Node.js (which provides npx). docs-mcp-server needs Node.js 22+.
# Uses Homebrew if present, otherwise the official installer from nodejs.org.
#
# Docs: https://nodejs.org/en/download
set -euo pipefail

info() { printf '[INFO]  %s\n' "$*"; }
ok()   { printf '[OK]    %s\n' "$*"; }
fail() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }
trap 'fail "Unexpected failure at line $LINENO: $BASH_COMMAND"' ERR

REQUIRED=22
node_major() { node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0; }

[[ "$(uname)" == Darwin ]] || fail "This script is for macOS. On Windows run windows\\1-install-node.bat."

if command -v node >/dev/null && (( $(node_major) >= REQUIRED )) && command -v npx >/dev/null; then
  ok "Node.js $(node -v) and npx $(npx -v) already installed."
  exit 0
fi

if command -v brew >/dev/null; then
  info "Installing Node.js with Homebrew..."
  if brew list node >/dev/null 2>&1; then
    brew upgrade node || fail "Homebrew could not upgrade Node.js. Run 'brew doctor' and retry."
  else
    brew install node || fail "Homebrew could not install Node.js. Run 'brew doctor' and retry."
  fi
else
  info "Homebrew not found. Installing Node.js LTS from nodejs.org (you'll be asked for your Mac password)..."
  BASE=https://nodejs.org/dist/latest-v24.x
  line="$(curl -fsSL "$BASE/SHASUMS256.txt" | grep '\.pkg$')" \
    || fail "Could not reach nodejs.org. Check your internet connection."
  sha="${line%% *}"; pkg="${line##* }"
  tmp="$(mktemp -d)"
  curl -fL --progress-bar -o "$tmp/$pkg" "$BASE/$pkg" || fail "Download of $pkg failed."
  echo "$sha  $tmp/$pkg" | shasum -a 256 -c --status \
    || fail "Checksum mismatch for $pkg (corrupted download). Re-run this script."
  sudo installer -pkg "$tmp/$pkg" -target / \
    || fail "Node.js installer failed. Your account needs admin rights."
  rm -rf "$tmp"
  export PATH="/usr/local/bin:$PATH"
fi

hash -r
command -v npx >/dev/null || fail "npx is still not on PATH. Open a new Terminal window and re-run this script."
(( $(node_major) >= REQUIRED )) \
  || fail "An older Node.js $(node -v) at $(command -v node) is still first on PATH. Update or remove it (e.g. 'nvm install 22'), then re-run."

ok "Node.js $(node -v) and npx $(npx -v) ready."
