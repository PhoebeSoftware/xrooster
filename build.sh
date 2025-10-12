#!/bin/bash
set -e 

COMMIT_ID=$(git rev-parse HEAD)

echo "🔧 Building Flutter app with commit: $COMMIT_ID"

flutter clean

flutter pub get

flutter build apk --dart-define=GIT_COMMIT=$COMMIT_ID

echo "----------------------------------------------------------------------"
echo "✅ Build complete. Commit: $COMMIT_ID"
echo "You can find the APK at build/app/outputs/flutter-apk/app-release.apk"