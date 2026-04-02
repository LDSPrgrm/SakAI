@echo off
set APP=%1

if "%APP%"=="passenger" goto run
if "%APP%"=="driver" goto run

echo Usage: run-mobile.bat [passenger^|driver]
exit /b 1

:run
echo --- Cleaning and installing api_client dependencies ---
cd mobile\shared\lib\api_client
call flutter clean
call flutter pub get
cd ..\..\..\..

echo --- Cleaning and installing shared dependencies ---
cd mobile\shared
call flutter clean
call flutter pub get
cd ..\..

echo --- Cleaning and installing %APP% dependencies ---
cd mobile\%APP%
call flutter clean
call flutter pub get

echo --- Running %APP% app ---
if exist "..\.env" (
    call flutter run --dart-define-from-file=..\.env
) else (
    call flutter run
)
