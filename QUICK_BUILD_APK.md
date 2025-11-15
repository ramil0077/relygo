# Quick APK Build Guide

## 🚀 Fastest Way to Build APK

### For Testing (Debug APK):
```bash
flutter build apk --debug
```
**Location:** `build/app/outputs/flutter-apk/app-debug.apk`

### For Distribution (Release APK):
```bash
flutter build apk --release
```
**Location:** `build/app/outputs/flutter-apk/app-release.apk`

> **Note:** Release APK uses debug signing by default. For production, see full guide.

## 📱 Install on Device

### Method 1: Via ADB
```bash
# Connect device via USB
# Enable USB debugging
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Method 2: Manual
1. Copy APK to your Android device
2. Open file manager
3. Tap APK file
4. Allow installation from unknown sources
5. Install

## 🔧 Before Building

Check your setup:
```bash
flutter doctor
```

If Android toolchain shows issues:
```bash
flutter doctor --android-licenses
# Accept all licenses
```

## 📦 Build Options

```bash
# Single universal APK (~30-50 MB)
flutter build apk --release

# Split APKs by architecture (smaller, ~15-25 MB each)
flutter build apk --split-per-abi --release

# App Bundle for Play Store
flutter build appbundle --release
```

## ⚠️ Common Issues

**Build fails?**
```bash
flutter clean
flutter pub get
flutter build apk --release
```

**Gradle issues?**
```bash
cd android
./gradlew clean
cd ..
flutter build apk --release
```

## 📋 Full Guide

For detailed instructions including signing configuration, see `BUILD_APK_GUIDE.md`

---

**That's it! Your APK is ready! 📱**

