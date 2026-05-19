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
if "%APP%"=="passenger" set "TARGET_AVD=Pixel_9_Pro"
if "%APP%"=="driver" set "TARGET_AVD=Pixel_9_Pro_2"

set "DEVICE_ID="
echo Querying if %TARGET_AVD% is already running...

for /f "usebackq tokens=*" %%k in (`powershell -NoProfile -Command "$target = '%TARGET_AVD%'; $id = ''; $devices = adb devices | Select-String 'emulator-' | ForEach-Object { ($_ -split '\s+')[0] }; foreach ($d in $devices) { $avd = (adb -s $d emu avd name | Select-Object -First 1).Trim(); if ($avd -eq $target) { $id = $d; break } }; Write-Output $id"`) do (
    set "DEVICE_ID=%%k"
)

if not "%DEVICE_ID%"=="" goto emulator_ready

echo Launching emulator %TARGET_AVD%...
call flutter emulators --launch %TARGET_AVD%

echo Waiting for emulator to boot and connect...
set /a ATTEMPTS=0

:wait_loop
set /a ATTEMPTS+=1
if !ATTEMPTS! gtr 20 (
    echo [WARNING] Emulator did not connect within 40 seconds. Running without specific target...
    goto emulator_ready
)

for /f "usebackq tokens=*" %%k in (`powershell -NoProfile -Command "$target = '%TARGET_AVD%'; $id = ''; $devices = adb devices | Select-String 'emulator-' | ForEach-Object { ($_ -split '\s+')[0] }; foreach ($d in $devices) { $avd = (adb -s $d emu avd name | Select-Object -First 1).Trim(); if ($avd -eq $target) { $id = $d; break } }; Write-Output $id"`) do (
    set "DEVICE_ID=%%k"
)

if "!DEVICE_ID!"=="" (
    echo Waiting for emulator connection (attempt !ATTEMPTS!/20)...
    timeout /t 2 /nobreak >nul
    goto wait_loop
)

:emulator_ready
if not "!DEVICE_ID!"=="" (
    echo Target emulator detected: !DEVICE_ID!
) else (
    echo No emulator targeted.
)

echo --- Running %APP% app ---
set "RUN_FLAGS="
if not "!DEVICE_ID!"=="" (
    set "RUN_FLAGS=-d !DEVICE_ID!"
)

if exist "..\.env" (
    call flutter run !RUN_FLAGS! --dart-define-from-file=..\.env
) else (
    call flutter run !RUN_FLAGS!
)
cd ..\..
goto :eof
