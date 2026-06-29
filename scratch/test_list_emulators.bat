@echo off
setlocal enabledelayedexpansion

echo Listing all available emulators found by parsing:
set /a COUNT=0
for /f "tokens=1 delims= " %%i in ('flutter emulators ^| findstr "•" ^| findstr /v "Manufacturer"') do (
    set /a COUNT+=1
    set "EMU[!COUNT!]=%%i"
    echo Emulator !COUNT!: %%i
)

echo Total found: !COUNT!
