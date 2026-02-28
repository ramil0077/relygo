import 'package:cloud_firestore/cloud_firestore.dart';

class DriverService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Update driver availability status
  static Future<Map<String, dynamic>> updateAvailability(
    String driverId,
    bool isAvailable,
  ) async {
    try {
      await _firestore.collection('users').doc(driverId).update({
        'isAvailable': isAvailable,
        'lastAvailabilityUpdate': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'message': 'Availability updated'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to update availability: $e'};
    }
  }

  /// Get driver's availability status
  static Stream<bool> getAvailabilityStream(String driverId) {
    return _firestore
        .collection('users')
        .doc(driverId)
        .snapshots()
        .map((doc) => doc.data()?['isAvailable'] ?? false);
  }

  /// Get pending booking requests for driver
  /// Shows both requests directed at this driver AND open/unassigned requests
  static Stream<List<Map<String, dynamic>>> getPendingBookingsStream(
    String driverId,
  ) {
    // Stream directed requests for this driver
    final directedStream = _firestore
        .collection('ride_requests')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'pending')
        .snapshots();

    // Merge: use directed stream and fetch all pending for deduplication
    return directedStream.asyncMap((snapshot) async {
      final List<Map<String, dynamic>> results = [];
      // Get open (no driverId) pending requests as well
      final openSnap = await _firestore
          .collection('ride_requests')
          .where('status', isEqualTo: 'pending')
          .get();

      for (final doc in openSnap.docs) {
        final data = doc.data();
        final docDriverId = data['driverId'];
        // Include if directed at this driver OR no driver assigned
        if (docDriverId == driverId ||
            docDriverId == null ||
            docDriverId == '') {
          data['id'] = doc.id;
          // fetch userName if missing
          if ((data['userName'] == null ||
                  data['userName'].toString().isEmpty) &&
              data['userId'] != null) {
            try {
              final userDoc = await _firestore
                  .collection('users')
                  .doc(data['userId'].toString())
                  .get();
              if (userDoc.exists) {
                data['userName'] =
                    userDoc.data()?['name'] ??
                    userDoc.data()?['fullName'] ??
                    'User';
                data['userPhone'] = userDoc.data()?['phone'] ?? '';
              }
            } catch (_) {}
          }
          // Map pickup/destination field variations
          data['pickupLocation'] ??= data['pickup'] ?? '';
          data['dropoffLocation'] ??= data['destination'] ?? '';
          results.add(data);
        }
      }
      return results;
    });
  }

  /// Get all bookings for driver (for history)
  static Stream<List<Map<String, dynamic>>> getDriverBookingsStream(
    String driverId,
  ) {
    return _firestore
        .collection('ride_requests')
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          // Sort client-side
          items.sort((a, b) {
            final aTime = a['createdAt'] as Timestamp?;
            final bTime = b['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

          return items;
        });
  }

  /// Accept booking request and set fare
  static Future<Map<String, dynamic>> acceptBooking(
    String bookingId,
    double fare,
    String driverName,
  ) async {
    try {
      final bookingRef = _firestore.collection('ride_requests').doc(bookingId);
      final bookingDoc = await bookingRef.get();

      if (!bookingDoc.exists) {
        return {'success': false, 'error': 'Request not found'};
      }

      final bookingData = bookingDoc.data()!;
      final userId = bookingData['userId'];

      // resolvedDriverName comes from caller (the driver's actual name)
      final String resolvedDriverName = driverName;

      // Update ride_request
      await bookingRef.update({
        'status': 'accepted',
        'fare': fare,
        'driverName': resolvedDriverName,
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send notification to user
      if (userId != null) {
        await _firestore.collection('notifications').add({
          'userId': userId,
          'title': 'Ride Accepted',
          'message':
              'Your ride request has been accepted by $resolvedDriverName. Fare: ₹$fare',
          'type': 'booking_accepted',
          'bookingId': bookingId,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return {'success': true, 'message': 'Request accepted'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to accept: $e'};
    }
  }

  /// Reject booking request
  static Future<Map<String, dynamic>> rejectBooking(
    String bookingId,
    String? reason,
  ) async {
    try {
      final bookingRef = _firestore.collection('ride_requests').doc(bookingId);
      final bookingDoc = await bookingRef.get();

      if (!bookingDoc.exists) {
        return {'success': false, 'error': 'Request not found'};
      }

      final bookingData = bookingDoc.data()!;
      final userId = bookingData['userId'];

      // Update ride_request
      await bookingRef.update({
        'status': 'rejected',
        'rejectionReason': reason,
        'rejectedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send notification to user
      if (userId != null) {
        await _firestore.collection('notifications').add({
          'userId': userId,
          'title': 'Ride Request Declined',
          'message':
              'Sorry, your ride request was declined. Please try booking another driver.',
          'type': 'booking_rejected',
          'bookingId': bookingId,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return {'success': true, 'message': 'Request rejected'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to reject: $e'};
    }
  }

  /// Mark booking as completed
  static Future<Map<String, dynamic>> completeBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'message': 'Booking completed'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to complete booking: $e'};
    }
  }

  /// Get driver earnings
  static Future<Map<String, dynamic>> getDriverEarnings(String driverId) async {
    try {
      final completedBookings = await _firestore
          .collection('bookings')
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: 'completed')
          .where('isPaid', isEqualTo: true)
          .get();

      double totalEarnings = 0;
      int totalRides = completedBookings.docs.length;

      for (var doc in completedBookings.docs) {
        final fare = doc.data()['fare'];
        if (fare != null) {
          totalEarnings += (fare as num).toDouble();
        }
      }

      // Get today's earnings
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final todayBookings = await _firestore
          .collection('bookings')
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: 'completed')
          .where('isPaid', isEqualTo: true)
          .where(
            'completedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .get();

      double todayEarnings = 0;
      for (var doc in todayBookings.docs) {
        final fare = doc.data()['fare'];
        if (fare != null) {
          todayEarnings += (fare as num).toDouble();
        }
      }

      return {
        'success': true,
        'totalEarnings': totalEarnings,
        'totalRides': totalRides,
        'todayEarnings': todayEarnings,
        'todayRides': todayBookings.docs.length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to get earnings: $e',
        'totalEarnings': 0.0,
        'totalRides': 0,
        'todayEarnings': 0.0,
        'todayRides': 0,
      };
    }
  }

  /// Get driver notifications
  static Stream<List<Map<String, dynamic>>> getDriverNotificationsStream(
    String driverId,
  ) {
    return _firestore
        .collection('notifications')
        .where('driverId', isEqualTo: driverId)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'read': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get driver's rating
  static Future<Map<String, dynamic>> getDriverRating(String driverId) async {
    try {
      final reviews = await _firestore
          .collection('reviews')
          .where('driverId', isEqualTo: driverId)
          .get();

      if (reviews.docs.isEmpty) {
        return {'success': true, 'averageRating': 0.0, 'totalReviews': 0};
      }

      double totalRating = 0;
      for (var doc in reviews.docs) {
        final rating = doc.data()['rating'];
        if (rating != null) {
          totalRating += (rating as num).toDouble();
        }
      }

      return {
        'success': true,
        'averageRating': totalRating / reviews.docs.length,
        'totalReviews': reviews.docs.length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to get rating: $e',
        'averageRating': 0.0,
        'totalReviews': 0,
      };
    }
  }
}
