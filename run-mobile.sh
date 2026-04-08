#!/usr/bin/env bash
set -e

DO_CLEAN=false
APP=""

for arg in "$@"; do
    case "$arg" in
        --clean) DO_CLEAN=true ;;
        passenger|driver) APP="$arg" ;;
        *) echo "Unknown argument: $arg" ;;
    esac
done

if [ "$APP" != "passenger" ] && [ "$APP" != "driver" ]; then
    echo "Usage: ./run-mobile.sh [passenger|driver] [--clean]"
    exit 1
fi

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

echo "--- Running $APP app ---"
if [ -f "../.env" ]; then
    flutter run --dart-define-from-file=../.env
else
    flutter run
fi
