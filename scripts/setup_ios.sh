#!/usr/bin/env bash
set -euo pipefail

echo "=== EGY DEVELOPMENT — iOS Bootstrap ==="

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: iOS setup and builds require macOS (current OS: $(uname -s))."
  exit 1
fi

for cmd in flutter xcodebuild pod; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: '$cmd' is not installed or not in PATH."
    exit 1
  fi
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "1. Checking Flutter environment..."
flutter --version

echo "2. Installing Flutter packages..."
flutter pub get

echo "3. Installing iOS CocoaPods dependencies..."
cd "$REPO_ROOT/ios"
pod install
cd "$REPO_ROOT"

PLIST_PATH="$REPO_ROOT/ios/Runner/GoogleService-Info.plist"
if [[ ! -f "$PLIST_PATH" ]]; then
  echo ""
  echo "WARNING: Missing $PLIST_PATH"
  echo "Run one of the following before launching on iOS:"
  echo "  flutterfire configure --project=real-estate-e1418 --platforms=ios"
  echo "  OR download GoogleService-Info.plist from Firebase Console (project: real-estate-e1418)"
  echo "  and place it at ios/Runner/GoogleService-Info.plist."
fi

echo ""
echo "=== Bootstrap Complete ==="
echo "Next steps:"
echo "  1. Open Xcode workspace to select your Apple Signing Team:"
echo "       open ios/Runner.xcworkspace"
echo "  2. Start the FastAPI backend locally (or use your hosted HTTPS URL)."
echo "  3. Run on iOS Simulator:"
echo "       flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000 --dart-define=ENABLE_LIVE_CHAT=true"
echo "  4. Or run on a physical iPhone (replace <MAC_LAN_IP> with your Mac's Wi-Fi IP):"
echo "       flutter run --dart-define=API_BASE_URL=http://<MAC_LAN_IP>:8000 --dart-define=ENABLE_LIVE_CHAT=true"
