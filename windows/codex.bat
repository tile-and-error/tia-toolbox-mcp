@echo off
REM Connect OpenAI Codex (CLI + IDE extension) to docs-mcp-server.
REM
REM Not covered by the docs-mcp-server client guide; see OpenAI's docs:
REM   https://learn.chatgpt.com/docs/extend/mcp?surface=cli
REM
REM Config file: %USERPROFILE%\.codex\config.toml (or %CODEX_HOME%\config.toml); backup saved as .bak.
REM Shared by the Codex CLI, the Codex IDE extension and the ChatGPT desktop app.
REM
REM Notes on the entry written below:
REM   - npx is launched via `cmd /c` because npx is a .cmd script on Windows.
REM   - startup_timeout_sec is raised from 10s; the first `npx -y` download can take longer.
REM   - env_vars forwards variables Codex doesn't pass by default; npm and the
REM     docs-mcp-server index (%LOCALAPPDATA%\docs-mcp-server) depend on them.
setlocal
set "RC=0"
set "NAME=docs-mcp-server"
set "DIR=%USERPROFILE%\.codex"
if defined CODEX_HOME set "DIR=%CODEX_HOME%"
set "CFG=%DIR%\config.toml"

where npx >nul 2>&1 || (set "ERR=npx not found. Run windows\1-install-node.bat first, then open a new terminal." & goto :fail)

if not exist "%DIR%" mkdir "%DIR%" || (set "ERR=Cannot create %DIR%." & goto :fail)
if not exist "%CFG%" type nul > "%CFG%" || (set "ERR=Cannot write %CFG%." & goto :fail)

findstr /b /l /c:"[mcp_servers.%NAME%]" "%CFG%" >nul && (
  echo [OK]    %NAME% is already in %CFG%. To change it, edit or delete its [mcp_servers.%NAME%] block and re-run.
  goto :end
)

copy /y "%CFG%" "%CFG%.bak" >nul || (set "ERR=Cannot back up %CFG%." & goto :fail)
echo [INFO]  Writing %NAME% to %CFG%...
>>"%CFG%" (
  echo.
  echo [mcp_servers.%NAME%]
  echo command = "cmd"
  echo args = ["/c", "npx", "-y", "@arabold/docs-mcp-server@latest"]
  echo startup_timeout_sec = 60
  echo env_vars = ["APPDATA", "LOCALAPPDATA", "USERPROFILE", "TEMP", "TMP", "PATHEXT", "SYSTEMROOT", "COMSPEC"]
) || (set "ERR=Cannot write %CFG%." & goto :fail)

echo [OK]    Connected. Restart Codex; 'codex mcp list' should show %NAME%.
goto :end

:fail
echo [ERROR] %ERR% 1>&2
set "RC=1"

:end
REM Keep the window open when double-clicked.
echo "%CMDCMDLINE%" | find /i "%~nx0" >nul && pause
exit /b %RC%
