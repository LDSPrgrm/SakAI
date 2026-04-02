#!/usr/bin/env bash
set -e

APP=$1

if [ "$APP" != "passenger" ] && [ "$APP" != "driver" ]; then
    echo "Usage: ./run-mobile.sh [passenger|driver]"
    exit 1
fi

echo "--- Cleaning and installing api_client dependencies ---"
cd mobile/shared/lib/api_client
flutter clean
flutter pub get
cd ../../../..

echo "--- Cleaning and installing shared dependencies ---"
cd mobile/shared
flutter clean
flutter pub get
cd ../..

echo "--- Cleaning and installing $APP dependencies ---"
cd mobile/$APP
flutter clean
flutter pub get

echo "--- Running $APP app ---"
if [ -f "../.env" ]; then
    flutter run --dart-define-from-file=../.env
else
    flutter run
fi
