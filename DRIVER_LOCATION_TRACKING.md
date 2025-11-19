# Driver Location Tracking Guide

## Overview
Driver location tracking is **automatically enabled** when a driver accepts a booking. Drivers do **NOT** need to manually enable any option - it happens automatically!

## How It Works

### For Drivers:

1. **Automatic Activation**: When a driver accepts a booking request, location tracking automatically starts
   - The app requests location permissions (if not already granted)
   - GPS location is shared in real-time to Firestore
   - Location updates continue until the ride is completed

2. **No Manual Steps Required**: 
   - ✅ Location tracking starts automatically when accepting a booking
   - ✅ No need to enable any setting or toggle
   - ✅ Location permissions are requested automatically

3. **Location Sharing**:
   - Driver's location is updated in real-time in Firestore (`drivers` collection)
   - Updates happen automatically as the driver moves
   - Users can see the driver's location on the map

### For Users:

1. **View Driver Location**: 
   - When a booking is accepted, users can track the driver in real-time
   - Open the "Track Driver" screen from the dashboard
   - See driver location on an interactive map

2. **Features Available**:
   - Real-time map view showing driver and user locations
   - Distance calculation between driver and user
   - Estimated Time of Arrival (ETA)
   - Option to open driver location in Google Maps app

## Technical Details

### Location Storage
- Driver locations are stored in Firestore: `drivers/{driverId}`
- Fields: `latitude`, `longitude`, `timestamp`, `isActive`

### Automatic Flow
1. Driver accepts booking → `DriverService.acceptBooking()` is called
2. Location tracking automatically starts → `DriverLiveLocation().startLiveLocationUpdates(driverId)`
3. Location updates are sent to Firestore in real-time
4. Users can view updates on the tracking screen

### Permissions
- Location permissions are requested automatically
- If denied, location tracking won't work (but booking acceptance still succeeds)
- Drivers should grant location permissions for the feature to work

## Troubleshooting

### Driver location not showing?
1. Check if location permissions are granted
2. Ensure GPS is enabled on the device
3. Verify the driver accepted the booking (location starts automatically on acceptance)

### Location not updating?
1. Check internet connection
2. Verify GPS signal strength
3. Restart the app if needed

## Code Reference

- **Location Service**: `lib/services/ride_completion_service.dart` - `DriverLiveLocation` class
- **Driver Service**: `lib/services/driver_service.dart` - `acceptBooking()` method
- **Tracking Screen**: `lib/screens/driver_tracking_screen.dart` - User-facing tracking UI

