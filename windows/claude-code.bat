@echo off
REM Connect Claude Code (CLI) to docs-mcp-server.
REM
REM Docs:
REM   https://github.com/arabold/docs-mcp-server/blob/main/docs/guides/mcp-clients.md#claude-code
REM   https://docs.anthropic.com/en/docs/claude-code/mcp
REM
REM Config is written by the `claude` CLI itself:
REM   user    -> %USERPROFILE%\.claude.json, all projects (default)
REM   local   -> %USERPROFILE%\.claude.json, current project only
REM   project -> .\.mcp.json, shared via the repo
REM
REM On native Windows, npx must be wrapped in `cmd /c` for Claude Code to launch it.
REM
REM Usage: windows\claude-code.bat [user^|local^|project]
setlocal
set "RC=0"
set "NAME=docs-mcp-server"
set "SCOPE=%~1"
if "%SCOPE%"=="" set "SCOPE=user"

if /i not "%SCOPE%"=="user" if /i not "%SCOPE%"=="local" if /i not "%SCOPE%"=="project" (set "ERR=Unknown scope '%SCOPE%'. Use user, local or project." & goto :fail)
where npx >nul 2>&1 || (set "ERR=npx not found. Run windows\1-install-node.bat first, then open a new terminal." & goto :fail)
where claude >nul 2>&1 || (set "ERR=Claude Code not found. Install it: https://docs.anthropic.com/en/docs/claude-code/setup" & goto :fail)

call claude mcp get %NAME% >nul 2>&1 && (
  echo [OK]    %NAME% is already connected to Claude Code.
  goto :end
)

echo [INFO]  Adding %NAME% to Claude Code (scope: %SCOPE%)...
call claude mcp add --scope %SCOPE% %NAME% -- cmd /c npx -y @arabold/docs-mcp-server@latest
if errorlevel 1 (set "ERR='claude mcp add' failed. See the message above." & goto :fail)

echo [OK]    Connected. Restart any open Claude Code sessions.
goto :end

:fail
echo [ERROR] %ERR% 1>&2
set "RC=1"

:end
REM Keep the window open when double-clicked.
echo "%CMDCMDLINE%" | find /i "%~nx0" >nul && pause
exit /b %RC%
