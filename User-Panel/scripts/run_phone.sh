#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if ! xcrun simctl list devices booted 2>/dev/null | grep -q Booted; then
  open -a Simulator
  sleep 10
fi

flutter run "$@"
