@echo off
REM Scrape the TIA Toolbox docs into a local search index named "tia-docs".
REM Re-run any time to refresh it. Stored in %LOCALAPPDATA%\docs-mcp-server.
REM
REM Docs: https://github.com/arabold/docs-mcp-server
setlocal
set "RC=0"
set "PKG=@arabold/docs-mcp-server@latest"
set "LIBRARY=tia-docs"
set "URL=https://tia-toolbox.readthedocs.io/en/stable/"

where npx >nul 2>&1 || (set "ERR=npx not found. Run windows\1-install-node.bat first, then open a new terminal." & goto :fail)

echo [INFO]  Scraping %URL% into '%LIBRARY%' (takes a few minutes)...
call npx -y %PKG% scrape %LIBRARY% %URL%
if errorlevel 1 (set "ERR=Scrape failed. Check your internet connection and that %URL% loads in a browser." & goto :fail)

echo [INFO]  Test search for "stain normalization":
call npx -y %PKG% search %LIBRARY% "stain normalization" --limit 1 --quiet | find """url"""
if errorlevel 1 (set "ERR=Index was built but a test search returned nothing. Re-run this script." & goto :fail)

echo [OK]    Index '%LIBRARY%' ready. Next: connect an app (see README).
goto :end

:fail
echo [ERROR] %ERR% 1>&2
set "RC=1"

:end
REM Keep the window open when double-clicked.
echo "%CMDCMDLINE%" | find /i "%~nx0" >nul && pause
exit /b %RC%
