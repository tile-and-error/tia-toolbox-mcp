# TIA Toolbox Docs MCP

Lets Claude, Codex and ChatGPT search the [TIA Toolbox docs](https://tia-toolbox.readthedocs.io/en/stable/) from a local index, using [docs-mcp-server](https://github.com/arabold/docs-mcp-server).

There's no server to start: each app launches docs-mcp-server itself when it needs it.

Run the commands from this folder:
- **Mac:** in Terminal. If you get `permission denied`, run `chmod +x mac/*.sh` first.
- **Windows:** in Command Prompt, or double-click the `.bat` file.

## 1. Install Node.js

| Mac | Windows |
|---|---|
| `./mac/1-install-node.sh` | `windows\1-install-node.bat` |

**What it does:** installs Node.js 22 or newer, which provides `npx` (the command that runs docs-mcp-server). Skipped if a recent enough version is already installed.
- **Mac:** uses Homebrew if you have it. Otherwise it uses the official installer, which asks for your password.
- **Windows:** uses `winget`. Otherwise it uses the official installer, which shows an admin prompt.
- **Windows:** open a new terminal afterwards.

## 2. Build the docs index

| Mac | Windows |
|---|---|
| `./mac/2-build-index.sh` | `windows\2-build-index.bat` |

**What it does:** downloads the TIA Toolbox docs into a local search index named `tia-docs`, then runs a test search. Takes a few minutes. Re-run it any time to update the docs.

## 3. Connect your apps

Run the script for each app you use:

| App | Mac | Windows | Then |
|---|---|---|---|
| Claude Code | `./mac/claude-code.sh` | `windows\claude-code.bat` | Restart open sessions |
| Claude Desktop | `./mac/claude-desktop.sh` | `windows\claude-desktop.bat` | Fully quit and reopen |
| Codex (CLI / IDE) | `./mac/codex.sh` | `windows\codex.bat` | Restart Codex |
| ChatGPT Desktop | `./mac/chatgpt-desktop.sh` | `windows\chatgpt-desktop.bat` | Restart ChatGPT |

**What it does:** adds a `docs-mcp-server` entry to the app's MCP config. Your other settings are kept, and the old file is saved next to it as `.bak`. Running a script again changes nothing.

| App | Config file |
|---|---|
| Claude Code | `~/.claude.json`, written by `claude mcp add`. Add a scope to change where it goes: `user` (default, all projects), `local` (this project) or `project` (`./.mcp.json`) |
| Claude Desktop | Mac: `~/Library/Application Support/Claude/claude_desktop_config.json`. Windows: `%APPDATA%\Claude\claude_desktop_config.json` |
| Codex and ChatGPT Desktop | `~/.codex/config.toml` (Windows: `%USERPROFILE%\.codex\config.toml`). Both apps share this file |

## 4. Check it works

Ask the app:

```text
Search tia-docs for "stain normalization"
```

It should call the `search_docs` tool and answer from the TIA Toolbox docs.

## If something fails

Every script prints `[ERROR]` followed by the cause and the fix. Fix it, then re-run that script; nothing gets set up twice.

| Error | Fix |
|---|---|
| `npx not found` | Run step 1, then open a new terminal |
| `Claude Code not found` | [Install Claude Code](https://docs.anthropic.com/en/docs/claude-code/setup) |
| `... is not valid JSON` | Fix the config file it names, or restore its `.bak` copy |
| App doesn't show the tool | Fully restart the app. The first launch can take up to a minute while `npx` downloads docs-mcp-server |

## Reference

- [docs-mcp-server: client setup](https://github.com/arabold/docs-mcp-server/blob/main/docs/guides/mcp-clients.md) (Claude Desktop, Claude Code, others)
- [Codex and ChatGPT Desktop: MCP](https://learn.chatgpt.com/docs/extend/mcp)
- [Claude Code: MCP](https://docs.anthropic.com/en/docs/claude-code/mcp)
