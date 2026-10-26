#!/usr/bin/env bash
# Takes the README screenshots of the example app on an iOS simulator.
#
#   scripts/screenshots.sh
#
# Needs macOS with Xcode and Flutter. The script uses its own simulator
# (FlutterForge-iPhone18Pro, created on the first run), fixes the status bar
# at 9:41, builds the example once per screen with --dart-define=INITIAL_ROUTE
# and writes docs/screenshots/*.png. The todo list comes from the live
# jsonplaceholder.typicode.com API, so the Mac needs network access; the
# offline screen points the app at a host that does not resolve.
set -euo pipefail

cd "$(dirname "$0")/.."
device_name="${DEVICE_NAME:-FlutterForge-iPhone18Pro}"
device_type="com.apple.CoreSimulator.SimDeviceType.iPhone-18-Pro"
bundle_id="dev.flutterforge.forgeExample"
out="docs/screenshots"

udid="$(xcrun simctl list devices | grep -F "$device_name (" | grep -oE '[0-9A-F-]{36}' | head -n 1 || true)"
if [ -z "$udid" ]; then
  runtime="$(xcrun simctl list runtimes | grep -E '^iOS ' | grep -oE 'com\.apple\.CoreSimulator\.SimRuntime\.iOS-[0-9-]+' | tail -n 1)"
  udid="$(xcrun simctl create "$device_name" "$device_type" "$runtime")"
fi
xcrun simctl boot "$udid" 2>/dev/null || true
xcrun simctl bootstatus "$udid" -b >/dev/null
xcrun simctl status_bar "$udid" override --time 9:41 --batteryState charged --batteryLevel 100 \
  --cellularMode active --cellularBars 4 --wifiBars 3

mkdir -p "$out"
shot() {
  local name="$1" route="$2" appearance="$3" api="${4:-https://jsonplaceholder.typicode.com}"
  xcrun simctl ui "$udid" appearance "$appearance"
  (cd example && flutter build ios --simulator --debug \
    --dart-define=INITIAL_ROUTE="$route" --dart-define=API_BASE_URL="$api" >/dev/null)
  xcrun simctl install "$udid" example/build/ios/iphonesimulator/Runner.app
  xcrun simctl launch --terminate-running-process "$udid" "$bundle_id" >/dev/null
  # Startup, the network request and the first frame.
  sleep 10
  xcrun simctl io "$udid" screenshot --type=png "$out/$name.png" >/dev/null
  sips --resampleWidth 600 "$out/$name.png" >/dev/null
  echo "$out/$name.png"
}

shot home / light
shot todos /todos light
shot todos-dark /todos dark
# A host under the reserved .invalid domain never resolves, as when offline.
shot offline /todos light https://api.example.invalid
xcrun simctl ui "$udid" appearance light
xcrun simctl status_bar "$udid" clear
