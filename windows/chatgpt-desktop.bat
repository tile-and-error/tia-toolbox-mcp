@echo off
REM Connect the ChatGPT desktop app to docs-mcp-server.
REM
REM Docs: https://learn.chatgpt.com/docs/extend/mcp?surface=app
REM
REM The ChatGPT desktop app shares its MCP config with Codex (%USERPROFILE%\.codex\config.toml),
REM so this runs codex.bat.
REM
REM Manual alternative in the app:
REM   Settings ^> MCP servers ^> Add server ^> STDIO
REM     Name:    docs-mcp-server
REM     Command: cmd /c npx -y @arabold/docs-mcp-server@latest
REM   Save, then Restart.
setlocal
call "%~dp0codex.bat"
set "RC=%ERRORLEVEL%"
if "%RC%"=="0" echo [OK]    Restart the ChatGPT desktop app (or Settings ^> MCP servers ^> Restart).

REM Keep the window open when double-clicked.
echo "%CMDCMDLINE%" | find /i "%~nx0" >nul && pause
exit /b %RC%
