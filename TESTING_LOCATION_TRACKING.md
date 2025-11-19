# Testing Driver Location Tracking - APK Build Guide

## ✅ Yes, You Can Build APK and Test!

Your app is ready to build and test. Here's everything you need to know.

## 🚀 Quick Build Commands

### For Testing (Recommended):
```bash
flutter build apk --debug
```
**Output:** `build/app/outputs/flutter-apk/app-debug.apk`

### For Release Testing:
```bash
flutter build apk --release
```
**Output:** `build/app/outputs/flutter-apk/app-release.apk`

## 📱 Install on Android Device

### Method 1: Direct Install (Easiest)
1. Build the APK: `flutter build apk --release`
2. Copy `build/app/outputs/flutter-apk/app-release.apk` to your Android device
3. Open file manager on device
4. Tap the APK file
5. Allow "Install from unknown sources" if prompted
6. Install

### Method 2: Via USB (ADB)
```bash
# Connect device via USB
# Enable USB debugging in Developer Options
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 🔧 Pre-Build Checklist

### 1. Check Flutter Setup
```bash
flutter doctor
```
Make sure Android toolchain is installed and configured.

### 2. Get Dependencies
```bash
flutter pub get
```

### 3. Clean Build (if needed)
```bash
flutter clean
flutter pub get
```

## 📍 Location Permissions Setup

✅ **Already Configured!** Your `AndroidManifest.xml` includes:
- `ACCESS_FINE_LOCATION` - For precise GPS location
- `ACCESS_COARSE_LOCATION` - For approximate location
- `ACCESS_BACKGROUND_LOCATION` - For continuous tracking

The app will automatically request these permissions when:
- Driver accepts a booking (starts location sharing)
- User opens tracking screen (gets user location)

## 🧪 Testing Location Tracking

### Test Scenario 1: Driver Accepts Booking
1. **Driver Side:**
   - Login as driver
   - Accept a booking request
   - ✅ Location sharing should start automatically
   - ✅ App will request location permission (if first time)
   - ✅ Grant permission when prompted

2. **User Side:**
   - Login as user
   - Go to dashboard
   - Tap "Track Driver" button
   - ✅ Should see map with driver location
   - ✅ Should see distance and ETA

### Test Scenario 2: Real-Time Updates
1. Driver accepts booking (location sharing active)
2. Driver moves to different location
3. User refreshes/views tracking screen
4. ✅ Driver marker should update on map
5. ✅ Distance and ETA should recalculate

### Test Scenario 3: External Maps
1. User is on tracking screen
2. Tap "Open in Maps" button (top right icon)
3. ✅ Should open Google Maps app with driver location

## ⚠️ Important Testing Notes

### Location Permissions
- **First Time:** App will request location permission
- **Grant Permission:** Tap "Allow" or "Allow all the time" for best results
- **If Denied:** Location tracking won't work, but app will still function

### GPS Requirements
- **Enable GPS:** Make sure GPS is enabled on device
- **Outdoor Testing:** GPS works better outdoors
- **Indoor Testing:** May use Wi-Fi/Network location (less accurate)

### Two Devices Needed
- **Device 1:** Driver account (accepts booking, shares location)
- **Device 2:** User account (views tracking screen)
- Or use same device with different accounts

## 🔍 Troubleshooting

### Location Not Showing?
1. ✅ Check location permissions are granted
2. ✅ Verify GPS is enabled
3. ✅ Check internet connection
4. ✅ Ensure driver accepted the booking
5. ✅ Try restarting the app

### Build Fails?
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Permission Issues?
- Go to Android Settings → Apps → Relygo → Permissions
- Enable "Location" permission
- For Android 10+: Enable "Allow all the time" for background location

## 📋 Testing Checklist

- [ ] Build APK successfully
- [ ] Install on Android device
- [ ] Login as driver
- [ ] Accept a booking
- [ ] Location permission requested
- [ ] Location sharing starts
- [ ] Login as user
- [ ] View tracking screen
- [ ] See driver location on map
- [ ] See distance and ETA
- [ ] Open in external maps works
- [ ] Location updates in real-time

## 🎯 Quick Test Steps

1. **Build:**
   ```bash
   flutter build apk --release
   ```

2. **Install on 2 devices:**
   - Device 1: Install APK, login as driver
   - Device 2: Install APK, login as user

3. **Test Flow:**
   - User creates booking
   - Driver accepts booking
   - User opens "Track Driver"
   - Verify map shows driver location

## 📱 Google Maps API Key (Optional)

For production, you may want to add a Google Maps API key:
1. Get API key from Google Cloud Console
2. Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_API_KEY"/>
   ```

**Note:** For testing, Google Maps works without API key (with usage limits).

## ✅ You're Ready!

Everything is configured. Just build the APK and test on real devices!

```bash
flutter build apk --release
```

Good luck with testing! 🚀

