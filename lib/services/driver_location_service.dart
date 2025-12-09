import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:relygo/services/location_service.dart';

/// Service to manage real-time driver location updates for live tracking
class DriverLocationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Location _location = Location();

  // Timer for periodic location updates
  static Timer? _locationUpdateTimer;

  /// Start broadcasting driver location to Firestore every interval seconds
  /// Call this when driver accepts a ride and payment is made
  static Future<void> startLocationTracking(
    String driverId, {
    int intervalSeconds = 5,
  }) async {
    // Stop existing timer if running
    stopLocationTracking();

    // Get initial location and update
    await _updateDriverLocationToFirebase(driverId);

    // Set up periodic updates
    _locationUpdateTimer = Timer.periodic(Duration(seconds: intervalSeconds), (
      _,
    ) async {
      await _updateDriverLocationToFirebase(driverId);
    });

    print('Driver location tracking started for $driverId');
  }

  /// Stop broadcasting driver location
  /// Call this when ride is completed
  static void stopLocationTracking() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    print('Driver location tracking stopped');
  }

  /// Fetch current location and update Firestore
  static Future<void> _updateDriverLocationToFirebase(String driverId) async {
    try {
      final LocationData? locationData =
          await LocationService.getCurrentLocation();

      if (locationData != null &&
          locationData.latitude != null &&
          locationData.longitude != null) {
        await _firestore.collection('drivers').doc(driverId).update({
          'latitude': locationData.latitude,
          'longitude': locationData.longitude,
          'lastLocationUpdate': FieldValue.serverTimestamp(),
          'isActive': true, // Mark driver as active while tracking
        });

        print(
          'Location updated: ${locationData.latitude}, ${locationData.longitude}',
        );
      }
    } catch (e) {
      print('Error updating driver location: $e');
      // Continue trying even if update fails
    }
  }

  /// Get real-time driver location stream for tracking
  static Stream<Map<String, dynamic>?> getDriverLocationStream(
    String driverId,
  ) {
    return _firestore.collection('drivers').doc(driverId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          return {
            'latitude': data['latitude'],
            'longitude': data['longitude'],
            'lastLocationUpdate': data['lastLocationUpdate'],
            'isActive': data['isActive'] ?? true,
          };
        }
      }
      return null;
    });
  }

  /// Mark driver as inactive (offline)
  /// Call this when driver goes offline
  static Future<void> markDriverInactive(String driverId) async {
    try {
      await _firestore.collection('drivers').doc(driverId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking driver inactive: $e');
    }
  }

  /// Mark driver as active (online)
  /// Call this when driver comes online
  static Future<void> markDriverActive(String driverId) async {
    try {
      await _firestore.collection('drivers').doc(driverId).update({
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking driver active: $e');
    }
  }
}
