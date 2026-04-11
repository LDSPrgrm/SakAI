@echo off
set DO_CLEAN=0
set APP=

:parse_args
if "%~1"=="" goto check_app
if "%~1"=="--clean" (
    set DO_CLEAN=1
    shift
    goto parse_args
)
if "%~1"=="passenger" (
    set APP=%~1
    shift
    goto parse_args
)
if "%~1"=="driver" (
    set APP=%~1
    shift
    goto parse_args
)
shift
goto parse_args

:check_app
if "%APP%"=="passenger" goto run
if "%APP%"=="driver" goto run

echo Usage: run-mobile.bat [passenger^|driver] [--clean]
exit /b 1

:run
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

echo --- Running %APP% app ---
if exist "..\.env" (
    call flutter run --dart-define-from-file=..\.env
) else (
    call flutter run
)
