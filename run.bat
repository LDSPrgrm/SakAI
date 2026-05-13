@echo off
setlocal enabledelayedexpansion

set CMD_TYPE=
set DO_CLEAN=0
set APP=

:parse_args
if "%~1"=="" goto check_args
set ARG=%~1

if "%ARG%"=="--backend" (set "CMD_TYPE=backend"& shift& goto parse_args)
if "%ARG%"=="backend" (set "CMD_TYPE=backend"& shift& goto parse_args)
if "%ARG%"=="--passenger" (set "CMD_TYPE=mobile"& set "APP=passenger"& shift& goto parse_args)
if "%ARG%"=="passenger" (set "CMD_TYPE=mobile"& set "APP=passenger"& shift& goto parse_args)
if "%ARG%"=="--driver" (set "CMD_TYPE=mobile"& set "APP=driver"& shift& goto parse_args)
if "%ARG%"=="driver" (set "CMD_TYPE=mobile"& set "APP=driver"& shift& goto parse_args)
if "%ARG%"=="--clean" (set "DO_CLEAN=1"& shift& goto parse_args)

shift
goto parse_args

:check_args
if "%CMD_TYPE%"=="backend" goto run_backend
if "%CMD_TYPE%"=="mobile" goto run_mobile

echo Usage: run.bat --backend ^| --passenger ^| --driver [--clean]
echo Tip: -- is needed for all main commands.
exit /b 1

:run_backend
echo --- Starting Backend ---
echo --- Cleaning Port 8080 ---
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8080 ^| findstr LISTENING') do (
    taskkill /f /pid %%a >nul 2>&1
)
cd backend
echo --- Downloading Dependencies ---
call go mod download
echo --- Running API ---
call go run cmd/api/main.go
cd ..
goto :eof

:run_mobile
echo --- Running Mobile: %APP% ---

echo --- Installing api_client dependencies ---
cd mobile\shared\lib\api_client
if "%DO_CLEAN%"=="1" call flutter clean
call flutter pub get
cd ..\..\..\..

echo --- Installing shared dependencies ---
cd mobile\shared
if "%DO_CLEAN%"=="1" call flutter clean
call flutter pub get
cd ..\..

echo --- Installing %APP% dependencies ---
cd mobile\%APP%
if "%DO_CLEAN%"=="1" call flutter clean
call flutter pub get

echo --- Launching Emulator ---
if "%APP%"=="passenger" call flutter emulators --launch Pixel_9_Pro
if "%APP%"=="driver" call flutter emulators --launch Pixel_9_Pro_2

echo --- Running %APP% app ---
if exist "..\.env" (
    call flutter run --dart-define-from-file=..\.env
) else (
    call flutter run
)
cd ..\..
goto :eof
