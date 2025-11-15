# Build APK for Android - Complete Guide

This guide will help you build an APK file for Android mobile devices.

## Prerequisites

1. **Flutter SDK** (version 3.8.1 or higher)
   - Verify: `flutter --version`

2. **Android Studio** (for Android SDK)
   - Download: https://developer.android.com/studio
   - Install Android SDK and build tools

3. **Java Development Kit (JDK)**
   - JDK 17 or higher recommended
   - Usually comes with Android Studio

## Quick Build (Debug APK)

### Step 1: Check Flutter Setup
```bash
flutter doctor
```
Make sure Android toolchain shows as installed.

### Step 2: Build Debug APK
```bash
flutter build apk --debug
```

The APK will be at: `build/app/outputs/flutter-apk/app-debug.apk`

### Step 3: Install on Device
```bash
# Connect your Android device via USB
# Enable USB debugging in Developer Options
flutter install
```

Or manually install:
```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
```

## Build Release APK (For Distribution)

### Step 1: Configure Signing (First Time Only)

1. **Create a keystore file:**
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   - Replace `~/upload-keystore.jks` with your desired path
   - Remember the password and alias name!

2. **Create `android/key.properties` file:**
   ```properties
   storePassword=<your-keystore-password>
   keyPassword=<your-key-password>
   keyAlias=upload
   storeFile=<path-to-your-keystore-file>
   ```
   
   Example:
   ```properties
   storePassword=yourpassword123
   keyPassword=yourpassword123
   keyAlias=upload
   storeFile=C:/Users/YourName/upload-keystore.jks
   ```

3. **Update `android/app/build.gradle.kts`:**
   
   Add this before `android {` block:
   ```kotlin
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }
   ```
   
   Update `android {` block to include signing:
   ```kotlin
   android {
       ...
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
               ...
           }
       }
   }
   ```

### Step 2: Build Release APK

**Option A: Single APK (Universal)**
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk` (~30-50 MB)

**Option B: Split APKs by ABI (Smaller size)**
```bash
flutter build apk --split-per-abi
```
This creates separate APKs:
- `app-armeabi-v7a-release.apk` (for 32-bit ARM)
- `app-arm64-v8a-release.apk` (for 64-bit ARM)
- `app-x86_64-release.apk` (for x86_64)

Each APK is smaller (~15-25 MB) and faster to download.

### Step 3: Build App Bundle (For Google Play Store)

For Google Play Store, use App Bundle instead of APK:
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

## Build Commands Reference

```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (single, universal)
flutter build apk --release

# Release APK (split by architecture)
flutter build apk --split-per-abi --release

# App Bundle (for Play Store)
flutter build appbundle --release

# Build with specific flavor (if configured)
flutter build apk --release --flavor production

# Build with specific target file
flutter build apk --release --target lib/main.dart
```

## APK File Locations

After building, find your APKs here:

- **Debug APK:**
  - `build/app/outputs/flutter-apk/app-debug.apk`

- **Release APK (Universal):**
  - `build/app/outputs/flutter-apk/app-release.apk`

- **Release APK (Split):**
  - `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
  - `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
  - `build/app/outputs/flutter-apk/app-x86_64-release.apk`

- **App Bundle:**
  - `build/app/outputs/bundle/release/app-release.aab`

## Testing the APK

### Method 1: Install via ADB
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Method 2: Transfer to Device
1. Copy APK to your Android device
2. Open file manager on device
3. Tap the APK file
4. Allow installation from unknown sources if prompted
5. Install

### Method 3: Share via Email/Cloud
1. Upload APK to Google Drive/Dropbox
2. Share link
3. Download and install on device

## Troubleshooting

### "Android toolchain not found"
```bash
flutter doctor --android-licenses
# Accept all licenses
```

### "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

### "Keystore file not found"
- Check path in `android/key.properties`
- Use absolute path or path relative to project root
- On Windows, use forward slashes or escaped backslashes

### "Signing config error"
- Verify `key.properties` file exists
- Check all passwords are correct
- Ensure keystore file path is correct

### Build is too slow
```bash
# Enable Gradle daemon (faster builds)
# Already enabled by default in newer Flutter versions
```

### APK size is too large
```bash
# Use split APKs
flutter build apk --split-per-abi --release

# Or enable ProGuard/R8 (already enabled in release builds)
```

## Optimizing APK Size

1. **Remove unused resources:**
   - Check `android/app/src/main/res/` for unused assets
   - Remove unused images/icons

2. **Enable code shrinking:**
   - Already enabled in release builds
   - Check `android/app/build.gradle.kts` for `minifyEnabled true`

3. **Use split APKs:**
   ```bash
   flutter build apk --split-per-abi --release
   ```

4. **Remove debug info:**
   - Release builds automatically strip debug info

## Version Management

Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1
# Format: version_name+build_number
```

Then rebuild:
```bash
flutter build apk --release
```

## Distribution Options

### 1. Direct Installation
- Share APK file directly
- Users install manually

### 2. Google Play Store
- Build App Bundle: `flutter build appbundle --release`
- Upload `app-release.aab` to Play Console
- Follow Play Store guidelines

### 3. Internal Testing
- Upload to Google Play Console → Internal Testing
- Share testing link with testers

### 4. Firebase App Distribution
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Distribute
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_APP_ID \
  --groups "testers"
```

## Quick Commands Cheat Sheet

```bash
# Check setup
flutter doctor

# Clean build
flutter clean && flutter pub get

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Build split APKs
flutter build apk --split-per-abi --release

# Build App Bundle
flutter build appbundle --release

# Install on connected device
flutter install

# Check connected devices
adb devices
```

## Security Notes

⚠️ **Important:**
- Never commit `key.properties` or keystore files to Git
- Add to `.gitignore`:
  ```
  android/key.properties
  *.jks
  *.keystore
  ```
- Keep keystore password secure
- Backup your keystore file safely

## Next Steps

1. ✅ Build your first APK
2. ✅ Test on a real device
3. ✅ Optimize APK size if needed
4. ✅ Prepare for Play Store (if distributing)

---

**Happy Building! 📱**

