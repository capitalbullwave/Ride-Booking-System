#!/bin/bash
# Run WaveGo Driver on iPhone Simulator (NOT browser)
set -e
cd "$(dirname "$0")/.."

echo "⏳ Opening iOS Simulator..."
open -a Simulator
sleep 5

# Prefer iOS 26.5 simulator (matches Xcode SDK)
DEVICE_ID=$(xcrun simctl list devices available | grep "iOS 26.5" -A 20 | grep "iPhone 17 (" | head -1 | grep -oE '[A-F0-9-]{36}')

if [ -z "$DEVICE_ID" ]; then
  DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone 17 (" | head -1 | grep -oE '[A-F0-9-]{36}')
fi

if [ -z "$DEVICE_ID" ]; then
  echo "❌ No iPhone 17 simulator found."
  exit 1
fi

echo "📱 Using simulator: $DEVICE_ID"
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
sleep 10

if ! flutter devices | grep -q "iPhone"; then
  echo "❌ iPhone simulator not detected. Wait a few seconds and retry."
  exit 1
fi

echo "🚀 Launching on iPhone Simulator..."
flutter run -d "$DEVICE_ID"
