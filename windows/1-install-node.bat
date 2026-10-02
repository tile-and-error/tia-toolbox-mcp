@echo off
REM Install Node.js (which provides npx). docs-mcp-server needs Node.js 22+.
REM Uses winget if present, otherwise the official installer from nodejs.org.
REM
REM Docs: https://nodejs.org/en/download
setlocal
set "RC=0"
set "REQUIRED=22"

call :node_ok && (
  for /f %%v in ('node -v') do echo [OK]    Node.js %%v already installed.
  goto :end
)

where winget >nul 2>&1 || goto :msi
echo [INFO]  Installing Node.js LTS with winget...
winget install --id OpenJS.NodeJS.LTS -e --silent --accept-source-agreements --accept-package-agreements
if errorlevel 1 (set "ERR=winget could not install Node.js. See the message above, or install manually from https://nodejs.org" & goto :fail)
goto :verify

:msi
echo [INFO]  winget not found. Installing Node.js LTS from nodejs.org (approve the admin prompt)...
set "ARCH=x64"
if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "ARCH=arm64"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; try { [Net.ServicePointManager]::SecurityProtocol='Tls12'; $b='https://nodejs.org/dist/latest-v24.x'; $l=((Invoke-WebRequest -UseBasicParsing ($b+'/SHASUMS256.txt')).Content -split [char]10 | Where-Object { $_ -match '-%ARCH%\.msi$' }); $sha,$f=$l.Trim() -split '\s+'; $o=Join-Path $env:TEMP $f; Invoke-WebRequest -UseBasicParsing ($b+'/'+$f) -OutFile $o; if ((Get-FileHash $o -Algorithm SHA256).Hash -ne $sha) { throw 'Checksum mismatch (corrupted download)' }; $p=Start-Process msiexec -ArgumentList '/i',('\"'+$o+'\"'),'/passive' -Wait -PassThru; if ($p.ExitCode -ne 0) { throw ('msiexec exit code ' + $p.ExitCode) } } catch { Write-Host ('[ERROR] ' + $_.Exception.Message); exit 1 }"
if errorlevel 1 (set "ERR=Node.js download or install failed. Check your internet connection and admin rights, or install manually from https://nodejs.org" & goto :fail)

:verify
REM The installer updates PATH for new windows only; add it for this one too.
set "PATH=%ProgramFiles%\nodejs;%PATH%"
call :node_ok || (set "ERR=Node.js %REQUIRED%+ still not found. Open a new terminal and re-run. If an older Node.js (e.g. nvm-windows) is first on PATH, update or remove it." & goto :fail)
for /f %%v in ('node -v') do echo [OK]    Node.js %%v and npx ready. Open a new terminal before the next step.
goto :end

:node_ok
where node >nul 2>&1 || exit /b 1
where npx >nul 2>&1 || exit /b 1
set "NODE_MAJOR=0"
for /f %%v in ('node -p "process.versions.node.split('.')[0]"') do set "NODE_MAJOR=%%v"
if %NODE_MAJOR% LSS %REQUIRED% exit /b 1
exit /b 0

:fail
echo [ERROR] %ERR% 1>&2
set "RC=1"

:end
REM Keep the window open when double-clicked.
echo "%CMDCMDLINE%" | find /i "%~nx0" >nul && pause
exit /b %RC%
