# White Blank Screen APK Build - Fixed

## Problem
APK builds successfully but shows a white blank screen when run on device

## Root Causes Addressed

### 1. ✅ **Error Visibility (main.dart)**
- Added error-catching wrapper around app initialization
- Shows an error screen instead of white blank when Firebase/critical services fail
- Logs all uncaught exceptions to logcat for debugging

### 2. ✅ **Method Count Limit (android/app/build.gradle.kts)**
- Enabled `multidexEnabled = true` to support apps with >64K methods
- Large Firebase + plugin dependencies often exceed this limit

### 3. ✅ **ProGuard Rule  (android/app/proguard-rules.pro)**
- Added Firebase, Google Play Services, Flutter, and Razorpay keep rules
- Prevents code shrinking from removing essential classes
- Added common annotations and native methods preservation

### 4. ✅ **App State Debugging (lib/widgets/auth_wrapper.dart)**
- Added detailed logging to StreamBuilder/FutureBuilder
- Added 10-second timeout to Firebase user data fetch
- Shows error screens instead of hanging/blank

### 5. ✅ **Release Build Config (android/app/build.gradle.kts)**
- Simplified signing configuration for release builds

## Build Instructions

### Fresh Build
```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build debug APK first (faster to test)
flutter build apk --debug

# Or build release APK (smaller but slower)
flutter build apk --release
```

### Install & Run
```bash
# Install to connected device
adb install -r build/app/outputs/flutter-apk/app-release.apk

# View live logs  
adb logcat -s Flutter SystemErr packrat relygo

# Or search for errors
adb logcat | grep -i "error\|exception\|crash"
```

## What to Look For

If app still shows white screen:

1. **Check logcat for startup errors:**
   ```bash
   adb logcat | grep "Firebase\|error\|exception\|E/:"
   ```

2. **Common issues:**
   - `Firebase init error:` → Firebase config issue
   - `NoClassDefFoundError` → Multidex or ProGuard issue
   - `ClassNotFoundException` → Missing plugin platform channel
   - Timeout messages → Network/Firestore access issue

3. **If error screen shows:** Read the error message and search for solution
   - Format: "App error: [detailed message]"

## Files Modified

- `lib/main.dart` - Added error handling wrapper
- `lib/widgets/auth_wrapper.dart` - Added error screens and timeouts
- `android/app/build.gradle.kts` - Enabled multidex
- `android/app/proguard-rules.pro` - Added Firebase/plugin rules

## Next Steps If Issue Persists

1. Build debug APK: `flutter build apk --debug`
2. Install: `adb install build/app/outputs/flutter-apk/app-debug.apk`
3. Check logs: `adb logcat | grep "error\|Firebase\|Exception"`
4. Share the error message with the team

## Platform Notes

- **Minimum SDK:** Should be ≥21 for Firebase
- **Method Count:** With multidex, supports 100K+ methods
- **ProGuard:** Currently configured to keep all Firebase/plugin classes
- **Signing:** Using debug keys for now (change in production)
