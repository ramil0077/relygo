import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class RideCompletionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check and update ride completion status based on drop time
  // Only auto-completes if ride is paid and not already completed
  static Future<void> checkAndUpdateRideCompletion() async {
    final now = DateTime.now();

    // Get all accepted/ongoing rides that should be completed
    final ridesSnapshot = await _firestore
        .collection('ride_requests')
        .where('status', whereIn: ['accepted', 'ongoing', 'paid'])
        .get();

    for (final doc in ridesSnapshot.docs) {
      final data = doc.data();
      final dropTime = data['dropTime'] as Timestamp?;
      final isPaid = data['isPaid'] ?? false;
      final status = (data['status'] ?? '').toString().toLowerCase();

      // Only auto-complete if paid and status is accepted/ongoing/paid
      if (isPaid && 
          (status == 'accepted' || status == 'ongoing' || status == 'paid') &&
          dropTime != null) {
        final dropDateTime = dropTime.toDate();

        // If current time is past drop time, mark as completed
        if (now.isAfter(dropDateTime)) {
          await _firestore.collection('ride_requests').doc(doc.id).update({
            'status': 'completed',
            'completedAt': Timestamp.now(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }

    // Also check bookings collection
    final bookingsSnapshot = await _firestore
        .collection('bookings')
        .where('status', whereIn: ['accepted', 'ongoing'])
        .get();

    for (final doc in bookingsSnapshot.docs) {
      final data = doc.data();
      final dropTime = data['dropTime'] as Timestamp?;
      final isPaid = data['isPaid'] ?? false;
      final status = (data['status'] ?? '').toString().toLowerCase();

      // Only auto-complete if paid and status is accepted/ongoing
      if (isPaid && 
          (status == 'accepted' || status == 'ongoing') &&
          dropTime != null) {
        final dropDateTime = dropTime.toDate();

        // If current time is past drop time, mark as completed
        if (now.isAfter(dropDateTime)) {
          await _firestore.collection('bookings').doc(doc.id).update({
            'status': 'completed',
            'completedAt': Timestamp.now(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }
  }

  // Set drop time when driver accepts a ride
  static Future<void> setDropTime(String rideId, DateTime dropTime) async {
    await _firestore.collection('ride_requests').doc(rideId).update({
      'dropTime': Timestamp.fromDate(dropTime),
    });
  }

  // Get rides that need completion check
  static Stream<QuerySnapshot<Map<String, dynamic>>>
  getRidesNeedingCompletion() {
    return _firestore
        .collection('ride_requests')
        .where('status', isEqualTo: 'accepted')
        .snapshots();
  }
}

class DriverLiveLocation {
  final _firestore = FirebaseFirestore.instance;
  final _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;
  String? _currentDriverId;

  /// Start sharing driver's live location to Firestore
  /// This automatically requests location permissions if needed
  Future<void> startLiveLocationUpdates(String driverId) async {
    try {
      // Request location service and permissions
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          print('Location service is disabled');
          return;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
      }

      if (permissionGranted != PermissionStatus.granted) {
        print('Location permission not granted');
        return;
      }

      // Stop any existing location updates
      await stopLiveLocationUpdates();

      _currentDriverId = driverId;

      // Listen to location changes and update Firestore
      _locationSubscription = _location.onLocationChanged.listen(
        (locationData) {
          if (locationData.latitude != null &&
              locationData.longitude != null &&
              _currentDriverId != null) {
            _firestore.collection('drivers').doc(_currentDriverId!).set({
              'latitude': locationData.latitude,
              'longitude': locationData.longitude,
              'timestamp': FieldValue.serverTimestamp(),
              'isActive': true,
            }, SetOptions(merge: true));
          }
        },
        onError: (error) {
          print('Location update error: $error');
        },
      );

      // Also get initial location immediately
      final currentLocation = await _location.getLocation();
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        _firestore.collection('drivers').doc(driverId).set({
          'latitude': currentLocation.latitude,
          'longitude': currentLocation.longitude,
          'timestamp': FieldValue.serverTimestamp(),
          'isActive': true,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error starting location updates: $e');
    }
  }

  /// Stop sharing driver's live location
  Future<void> stopLiveLocationUpdates() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;

    if (_currentDriverId != null) {
      // Mark location as inactive
      await _firestore.collection('drivers').doc(_currentDriverId!).set({
        'isActive': false,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _currentDriverId = null;
    }
  }

  /// Check if location tracking is currently active
  bool get isTrackingActive => _locationSubscription != null;
}
