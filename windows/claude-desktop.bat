@echo off
REM Connect Claude Desktop to docs-mcp-server.
REM
REM Docs:
REM   https://github.com/arabold/docs-mcp-server/blob/main/docs/guides/mcp-clients.md#claude-desktop
REM   https://modelcontextprotocol.io/quickstart/user
REM
REM Config file: %APPDATA%\Claude\claude_desktop_config.json
REM   (Microsoft Store installs use %LOCALAPPDATA%\Packages\<Claude package>\LocalCache\Roaming\Claude instead;
REM    detected below. Claude Desktop > Settings > Developer > Edit Config opens the real file.)
REM A backup is saved next to it as .bak.
REM
REM npx is launched via `cmd /c` because npx is a .cmd script on Windows.
setlocal
set "RC=0"
set "NAME=docs-mcp-server"
set "CFG=%APPDATA%\Claude\claude_desktop_config.json"
for /d %%d in ("%LOCALAPPDATA%\Packages\*Claude*") do if exist "%%d\LocalCache\Roaming\Claude" set "CFG=%%d\LocalCache\Roaming\Claude\claude_desktop_config.json"

where node >nul 2>&1 || (set "ERR=Node.js not found. Run windows\1-install-node.bat first, then open a new terminal." & goto :fail)

if exist "%CFG%" copy /y "%CFG%" "%CFG%.bak" >nul || (set "ERR=Cannot back up %CFG%." & goto :fail)

echo [INFO]  Writing %NAME% to %CFG%...
REM Merge into the existing config so other servers and settings are kept.
node -e "const fs=require('fs'),path=require('path'),p=process.env.CFG,n=process.env.NAME;let c={};try{const t=fs.existsSync(p)?fs.readFileSync(p,'utf8').replace(/^\uFEFF/,'').trim():'';if(t)c=JSON.parse(t)}catch(e){console.error('[ERROR] '+p+' is not valid JSON ('+e.message+'). Fix or delete it, then re-run.');process.exit(1)}c.mcpServers=Object.assign({},c.mcpServers);c.mcpServers[n]={command:'cmd',args:['/c','npx','-y','@arabold/docs-mcp-server@latest']};fs.mkdirSync(path.dirname(p),{recursive:true});fs.writeFileSync(p,JSON.stringify(c,null,2)+'\n')"
if errorlevel 1 (set "ERR=Could not update %CFG%." & goto :fail)

echo [OK]    Connected. Fully quit Claude Desktop (tray icon ^> Quit) and reopen it.
goto :end

:fail
echo [ERROR] %ERR% 1>&2
set "RC=1"

:end
REM Keep the window open when double-clicked.
echo "%CMDCMDLINE%" | find /i "%~nx0" >nul && pause
exit /b %RC%
