#!/usr/bin/env bash
set -e

CMD_TYPE=""
DO_CLEAN=false
APP=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        backend|--backend)
            CMD_TYPE="backend"
            shift
            ;;
        passenger|--passenger)
            CMD_TYPE="mobile"
            APP="passenger"
            shift
            ;;
        driver|--driver)
            CMD_TYPE="mobile"
            APP="driver"
            shift
            ;;
        --clean)
            DO_CLEAN=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

if [ -z "$CMD_TYPE" ]; then
    echo "Usage: ./run.sh --backend | --passenger | --driver [--clean]"
    echo "Tip: -- is needed for all main commands."
    exit 1
fi

if [ "$CMD_TYPE" == "backend" ]; then
    echo "--- Starting Backend ---"
    cd backend
    echo "--- Downloading Dependencies ---"
    go mod download
    echo "--- Running API ---"
    go run cmd/api/main.go
    cd ..
elif [ "$CMD_TYPE" == "mobile" ]; then
    echo "--- Running Mobile: $APP ---"
    
    echo "--- Installing api_client dependencies ---"
    cd mobile/shared/lib/api_client
    if [ "$DO_CLEAN" = true ]; then flutter clean; fi
    flutter pub get
    cd ../../../..

    echo "--- Installing shared dependencies ---"
    cd mobile/shared
    if [ "$DO_CLEAN" = true ]; then flutter clean; fi
    flutter pub get
    cd ../..

    echo "--- Installing $APP dependencies ---"
    cd mobile/$APP
    if [ "$DO_CLEAN" = true ]; then flutter clean; fi
    flutter pub get

    echo "--- Launching Emulator ---"
    if [ "$APP" == "passenger" ]; then
        flutter emulators --launch Pixel_9_Pro
    elif [ "$APP" == "driver" ]; then
        flutter emulators --launch Pixel_9_Pro_2
    fi

    echo "--- Running $APP app ---"
    if [ -f "../.env" ]; then
        flutter run --dart-define-from-file=../.env
    else
        flutter run
    fi
    cd ../..
fi
