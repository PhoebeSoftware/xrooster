#!/bin/bash
set -e 

echo "🔧 Building Flutter app "

flutter clean

flutter pub get

flutter build apk --release

echo "----------------------------------------------------------------------"
echo "✅ Build complete."
echo "You can find the APK at build/app/outputs/flutter-apk/app-release.apk"