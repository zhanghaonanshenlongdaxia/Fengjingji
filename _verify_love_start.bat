@echo off
setlocal
set LOVE="d:\godotProject\tools\love\love-11.5-win64\love.exe"
set PROJ="d:\godotProject\风景集"
set LOG=%TEMP%\love_风景集_start.log

echo === Killing old love processes ===
taskkill /F /IM love.exe /T 2>nul
timeout /t 1 /nobreak >nul

echo === Starting LÖVE for 风景集 ===
echo Working dir: %PROJ%
%LOVE% %PROJ% > %LOG% 2>&1
echo Exit code: %ERRORLEVEL%
echo === Log: %LOG% ===
type %LOG%
endlocal
