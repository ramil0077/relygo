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
  static Stream<List<Map<String, dynamic>>> getPendingBookingsStream(
    String driverId,
  ) {
    return _firestore
        .collection('bookings')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get all bookings for driver (for history)
  static Stream<List<Map<String, dynamic>>> getDriverBookingsStream(
    String driverId,
  ) {
    return _firestore
        .collection('bookings')
        .where('driverId', isEqualTo: driverId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Accept booking request and set fare
  static Future<Map<String, dynamic>> acceptBooking(
    String bookingId,
    double fare,
    String driverName,
  ) async {
    try {
      final bookingRef = _firestore.collection('bookings').doc(bookingId);
      final bookingDoc = await bookingRef.get();
      
      if (!bookingDoc.exists) {
        return {'success': false, 'error': 'Booking not found'};
      }

      final bookingData = bookingDoc.data()!;
      final userId = bookingData['userId'];

      // Update booking
      await bookingRef.update({
        'status': 'accepted',
        'fare': fare,
        'driverName': driverName,
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send notification to user
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': 'Booking Accepted',
        'message':
            'Your booking has been accepted by $driverName. Fare: ₹$fare',
        'type': 'booking_accepted',
        'bookingId': bookingId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'message': 'Booking accepted'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to accept booking: $e'};
    }
  }

  /// Reject booking request
  static Future<Map<String, dynamic>> rejectBooking(
    String bookingId,
    String? reason,
  ) async {
    try {
      final bookingRef = _firestore.collection('bookings').doc(bookingId);
      final bookingDoc = await bookingRef.get();
      
      if (!bookingDoc.exists) {
        return {'success': false, 'error': 'Booking not found'};
      }

      final bookingData = bookingDoc.data()!;
      final userId = bookingData['userId'];

      // Update booking
      await bookingRef.update({
        'status': 'rejected',
        'rejectionReason': reason,
        'rejectedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send notification to user
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': 'Booking Rejected',
        'message':
            'Sorry, your booking request was declined. Please try booking another driver.',
        'type': 'booking_rejected',
        'bookingId': bookingId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'message': 'Booking rejected'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to reject booking: $e'};
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
          .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
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
        .orderBy('createdAt', descending: true)
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
        return {
          'success': true,
          'averageRating': 0.0,
          'totalReviews': 0,
        };
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
