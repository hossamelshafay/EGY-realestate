# EGY DEVELOPMENT — macOS & iOS Setup Guide

This guide explains how to clone, configure, and run **EGY DEVELOPMENT** on an **iOS Simulator** or **physical iPhone** on macOS.

---

## 1. Prerequisites

- **macOS** (Apple Silicon or Intel)
- **Xcode** (15.0+ recommended, with iOS Simulator runtime installed)
- **Flutter SDK** (3.x, matching `pubspec.yaml` Dart SDK `^3.12.2`)
- **CocoaPods** (`sudo gem install cocoapods` or `brew install cocoapods`)
- **Apple Account** (a free Personal Apple ID works for development testing on a physical iPhone; an Apple Developer Program membership is only required for TestFlight / App Store distribution)
- **Firebase iOS Config (`GoogleService-Info.plist`)** — see Section 3 below

---

## 2. Quick Bootstrap

Clone the repository and run the bootstrap script:

```bash
git clone https://github.com/hossamelshafay/EGY-realestate.git
cd EGY-realestate
chmod +x scripts/setup_ios.sh
./scripts/setup_ios.sh
```

The script verifies macOS, Flutter, Xcode CLI tools, CocoaPods, runs `flutter pub get`, runs `pod install` inside `ios/`, and checks for `ios/Runner/GoogleService-Info.plist`.

---

## 3. Firebase iOS Configuration

`lib/firebase_options.dart` already contains the `DefaultFirebaseOptions.ios` configuration for Firebase project `real-estate-e1418` (`iosBundleId: com.example.egy`).

However, `ios/Runner/GoogleService-Info.plist` is **not** committed with machine/OAuth secrets. Before running on iOS:

### Option A — FlutterFire CLI (Recommended)
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=real-estate-e1418 --platforms=ios
```
This downloads `ios/Runner/GoogleService-Info.plist` and keeps `lib/firebase_options.dart` aligned.

### Option B — Manual Firebase Console Download
1. Open [Firebase Console](https://console.firebase.google.com/) → Project **real-estate-e1418** → **Project Settings** → **Your apps** → iOS app (`com.example.egy`).
2. Download `GoogleService-Info.plist`.
3. Place it at `ios/Runner/GoogleService-Info.plist` and add it to the `Runner` target in Xcode (`ios/Runner.xcworkspace`).

### Google Sign-In URL Scheme (Required for "Continue with Google")
1. Open `ios/Runner/GoogleService-Info.plist` and copy the `REVERSED_CLIENT_ID` value (e.g. `com.googleusercontent.apps.88328486417-...`).
2. In Xcode, select **Runner** → **Info** → **URL Types** → **+** and paste `REVERSED_CLIENT_ID` into **URL Schemes** (or add `CFBundleURLTypes` to `ios/Runner/Info.plist`).

---

## 4. Configure Xcode Signing

No Apple Team ID or certificates are committed to this repository.

1. Open the workspace (never `.xcodeproj` when using CocoaPods):
   ```bash
   open ios/Runner.xcworkspace
   ```
2. Select **Runner** in the left navigator → **Signing & Capabilities**.
3. Ensure **Automatically manage signing** is checked.
4. Select your **Team** (your Personal Apple ID or Apple Developer Team).
5. If Xcode reports a Bundle Identifier conflict on a personal team, temporarily change **Bundle Identifier** from `com.example.egy` to a unique reverse-domain ID (for example `com.yourname.egy`) — note that Firebase iOS / Google Sign-In must match the registered Bundle ID if you change it.

---

## 5. Backend Connectivity (`API_BASE_URL`)

The FastAPI backend is **not** hardcoded. Pass `API_BASE_URL` using `--dart-define`:

1. **iOS Simulator** (FastAPI running locally on the same Mac at port `8000`):
   ```bash
   flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000 --dart-define=ENABLE_LIVE_CHAT=true
   ```
2. **Physical iPhone** (FastAPI running on your Mac on the same Wi-Fi network, e.g. `192.168.1.8`):
   - Start FastAPI bound to `0.0.0.0:8000`.
   - Find your Mac's Wi-Fi IP (`ipconfig getifaddr en0`).
   - Run:
     ```bash
     flutter run --dart-define=API_BASE_URL=http://192.168.1.8:8000 --dart-define=ENABLE_LIVE_CHAT=true
     ```
   - `Info.plist` includes `NSAllowsLocalNetworking = true` so local development HTTP works without disabling HTTPS enforcement for internet traffic.
3. **Production / Publicly Hosted Backend** (Release builds require `https://`):
   ```bash
   flutter run --release --dart-define=API_BASE_URL=https://your-api.example.com --dart-define=ENABLE_LIVE_CHAT=true
   ```

> **Note:** If the backend is not deployed publicly, AI features (Recommendations, Price Prediction, AI Chat, Catalog) require starting the FastAPI backend locally on your Mac.

---

## 6. Run & Verify on iOS

### Check environment
```bash
flutter doctor -v
flutter devices
```

### Run on iOS Simulator
```bash
open -a Simulator
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000 --dart-define=ENABLE_LIVE_CHAT=true
```

### Run on a Physical iPhone
1. Connect iPhone via USB and tap **Trust This Computer**.
2. On iPhone: **Settings → Privacy & Security → Developer Mode → ON** (iOS 16+).
3. Configure signing in `ios/Runner.xcworkspace`.
4. Run:
   ```bash
   flutter run -d <iphone-device-id> --dart-define=API_BASE_URL=http://<MAC_LAN_IP>:8000 --dart-define=ENABLE_LIVE_CHAT=true
   ```

### Build Verification Commands
```bash
# Unsigned iOS build check
flutter build ios --no-codesign --dart-define=API_BASE_URL=https://your-api.example.com

# Signed iOS build (after selecting Team in Xcode)
flutter build ios --dart-define=API_BASE_URL=https://your-api.example.com
```

### Functional Verification Checklist
- [ ] Splash and Onboarding screens
- [ ] Login, Registration (with 6-avatar selection), Password Reset, and Google Sign-In
- [ ] Home, Property Search, and Property Details
- [ ] AI Recommendations, Price Prediction, and AI Chatbot
- [ ] Favorites and Firestore synchronization
- [ ] Profile, Settings, Light/Dark Mode reveal, and Arabic/English RTL/LTR
- [ ] App restart / Firebase session restoration

---

## 7. Troubleshooting

- **CocoaPods `IPHONEOS_DEPLOYMENT_TARGET` warnings/errors:** `ios/Podfile` and `project.pbxproj` are set to `15.0`. If Pods cache stale settings, run:
  ```bash
  cd ios && rm -rf Pods Podfile.lock && pod install --repo-update && cd ..
  ```
- **Missing `GoogleService-Info.plist`:** Run `flutterfire configure --project=real-estate-e1418 --platforms=ios` or download it from Firebase Console into `ios/Runner/`.
- **Signing error ("Requires a development team"):** Open `ios/Runner.xcworkspace`, select **Runner → Signing & Capabilities**, and pick your Apple Team.
- **Physical iPhone cannot reach FastAPI:** Ensure FastAPI listens on `0.0.0.0:8000`, macOS Firewall allows incoming Python/uvicorn connections, and `API_BASE_URL` uses your Mac's LAN IP (not `127.0.0.1`).
