import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relygo/services/ride_completion_service.dart';

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

  /// Get pending booking requests for driver (unified from both collections)
  static Stream<List<Map<String, dynamic>>> getPendingBookingsStream(
    String driverId,
  ) {
    // Stream from 'bookings' collection
    final bookingsStream = _firestore
        .collection('bookings')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'pending')
        .snapshots();

    // Combine with 'ride_requests' collection
    return bookingsStream.asyncMap((bookingsSnapshot) async {
      // Get pending ride_requests
      final rideRequestsSnapshot = await _firestore
          .collection('ride_requests')
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: 'pending')
          .get();

      List<Map<String, dynamic>> allPending = [];

      // Process bookings collection
      for (var doc in bookingsSnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        // Normalize field names
        if (data['pickupLocation'] == null && data['pickup'] != null) {
          data['pickupLocation'] = data['pickup'];
        }
        if (data['dropoffLocation'] == null && data['destination'] != null) {
          data['dropoffLocation'] = data['destination'];
        }
        allPending.add(data);
      }

      // Process ride_requests collection
      for (var doc in rideRequestsSnapshot.docs) {
        final data = doc.data();
        data['id'] = data['id'] ?? doc.id;
        // Normalize field names
        if (data['pickupLocation'] == null && data['pickup'] != null) {
          data['pickupLocation'] = data['pickup'];
        }
        if (data['dropoffLocation'] == null && data['destination'] != null) {
          data['dropoffLocation'] = data['destination'];
        }
        // Map user fields if needed
        if (data['userName'] == null && data['name'] != null) {
          data['userName'] = data['name'];
        }
        if (data['userPhone'] == null && data['phone'] != null) {
          data['userPhone'] = data['phone'];
        }
        allPending.add(data);
      }

      // Remove duplicates based on document ID
      final uniquePending = <String, Map<String, dynamic>>{};
      for (var booking in allPending) {
        final id = booking['id']?.toString() ?? '';
        if (id.isNotEmpty && !uniquePending.containsKey(id)) {
          uniquePending[id] = booking;
        }
      }

      // Sort by createdAt (newest first)
      final sortedPending = uniquePending.values.toList();
      sortedPending.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      return sortedPending;
    });
  }

  /// Get all bookings for driver (for history)
  static Stream<List<Map<String, dynamic>>> getDriverBookingsStream(
    String driverId,
  ) {
    return _firestore
        .collection('bookings')
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  /// Unified driver bookings stream: merges 'bookings' and 'ride_requests' collections with user details
  static Stream<List<Map<String, dynamic>>> getUnifiedDriverBookingsStream(
    String driverId,
  ) {
    // Stream from 'bookings' collection
    final bookingsStream = _firestore
        .collection('bookings')
        .where('driverId', isEqualTo: driverId)
        .snapshots();

    // Combine both streams using asyncMap - listen to bookings and fetch ride_requests
    return bookingsStream.asyncMap((bookingsSnapshot) async {
      // Get ride_requests snapshot (fetch on each update)
      final rideRequestsSnapshot = await _firestore
          .collection('ride_requests')
          .where('driverId', isEqualTo: driverId)
          .get();

      List<Map<String, dynamic>> allBookings = [];

      // Process bookings collection
      for (var doc in bookingsSnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        // Normalize field names
        if (data['pickupLocation'] == null && data['pickup'] != null) {
          data['pickupLocation'] = data['pickup'];
        }
        if (data['dropoffLocation'] == null && data['destination'] != null) {
          data['dropoffLocation'] = data['destination'];
        }
        // Normalize status: 'paid' -> 'completed'
        if (data['status']?.toString().toLowerCase() == 'paid') {
          data['status'] = 'completed';
        }
        // Ensure createdAt exists
        if (data['createdAt'] == null) {
          data['createdAt'] = data['updatedAt'] ?? data['paidAt'];
        }
        // Fetch user name if userId exists (support both 'userId' and 'user_id')
        final possibleUserId =
            data['userId'] ?? data['user_id'] ?? data['passengerId'];
        if (possibleUserId != null &&
            (data['userName'] == null || data['userName'] == 'Unknown User')) {
          try {
            final userDoc = await _firestore
                .collection('users')
                .doc(possibleUserId.toString())
                .get();
            if (userDoc.exists) {
              data['userName'] = userDoc.data()?['name'] ?? 'Unknown User';
            }
          } catch (e) {
            data['userName'] = 'Unknown User';
          }
        }
        // Normalize fare
        if (data['fare'] == null) {
          data['fare'] = data['price'] ?? data['amount'] ?? data['cost'];
        }
        allBookings.add(data);
      }

      // Process ride_requests collection
      for (var doc in rideRequestsSnapshot.docs) {
        final data = doc.data();
        data['id'] = data['id'] ?? doc.id;
        // Normalize field names
        if (data['pickupLocation'] == null && data['pickup'] != null) {
          data['pickupLocation'] = data['pickup'];
        }
        if (data['dropoffLocation'] == null && data['destination'] != null) {
          data['dropoffLocation'] = data['destination'];
        }
        // Normalize status: 'paid' -> 'completed'
        if (data['status']?.toString().toLowerCase() == 'paid') {
          data['status'] = 'completed';
        }
        // Ensure createdAt exists
        if (data['createdAt'] == null) {
          data['createdAt'] = data['updatedAt'] ?? data['paidAt'];
        }
        // Use 'price' as 'fare' if fare doesn't exist
        if (data['fare'] == null && data['price'] != null) {
          data['fare'] = data['price'];
        }
        // Normalize fare further
        if (data['fare'] == null) {
          data['fare'] = data['amount'] ?? data['cost'];
        }
        // Fetch user name if userId exists (support multiple keys)
        final possibleUserId =
            data['userId'] ??
            data['user_id'] ??
            data['passengerId'] ??
            data['userid'];
        if (possibleUserId != null &&
            (data['userName'] == null || data['userName'] == 'Unknown User')) {
          try {
            final userDoc = await _firestore
                .collection('users')
                .doc(possibleUserId.toString())
                .get();
            if (userDoc.exists) {
              data['userName'] = userDoc.data()?['name'] ?? 'Unknown User';
            }
          } catch (e) {
            data['userName'] = 'Unknown User';
          }
        }
        allBookings.add(data);
      }

      // Remove duplicates based on document ID
      final uniqueBookings = <String, Map<String, dynamic>>{};
      for (var booking in allBookings) {
        final id = booking['id']?.toString() ?? '';
        if (id.isNotEmpty && !uniqueBookings.containsKey(id)) {
          uniqueBookings[id] = booking;
        }
      }

      // Sort by createdAt (newest first)
      final sortedBookings = uniqueBookings.values.toList();
      sortedBookings.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      return sortedBookings;
    });
  }

  /// Accept booking request and set fare (handles both collections)
  /// Automatically starts location tracking for the driver
  static Future<Map<String, dynamic>> acceptBooking(
    String bookingId,
    double fare,
    String driverName,
    String driverId, // Driver's user ID
  ) async {
    try {
      // Try to find booking in 'bookings' collection first
      DocumentReference? bookingRef;
      DocumentSnapshot? bookingDoc;
      String collectionName = 'bookings';

      bookingRef = _firestore.collection('bookings').doc(bookingId);
      bookingDoc = await bookingRef.get();

      // If not found in 'bookings', try 'ride_requests'
      if (!bookingDoc.exists) {
        bookingRef = _firestore.collection('ride_requests').doc(bookingId);
        bookingDoc = await bookingRef.get();
        collectionName = 'ride_requests';
      }

      if (!bookingDoc.exists) {
        return {'success': false, 'error': 'Booking not found'};
      }

      final bookingData = bookingDoc.data() as Map<String, dynamic>;
      final userId = bookingData['userId'];

      // Update booking - normalize field names for ride_requests
      final updateData = <String, dynamic>{
        'status': 'accepted',
        'fare': fare,
        'driverName': driverName,
        'driverId': driverId, // Ensure driverId is set
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // For ride_requests, also set 'price' field
      if (collectionName == 'ride_requests') {
        updateData['price'] = fare;
      }

      await bookingRef.update(updateData);

      // Automatically start location tracking for the driver
      try {
        final locationTracker = DriverLiveLocation();
        await locationTracker.startLiveLocationUpdates(driverId);
      } catch (e) {
        // Log error but don't fail the booking acceptance
        print('Failed to start location tracking: $e');
      }

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

  /// Reject booking request (handles both collections)
  static Future<Map<String, dynamic>> rejectBooking(
    String bookingId,
    String? reason,
  ) async {
    try {
      // Try to find booking in 'bookings' collection first
      DocumentReference? bookingRef;
      DocumentSnapshot? bookingDoc;

      bookingRef = _firestore.collection('bookings').doc(bookingId);
      bookingDoc = await bookingRef.get();

      // If not found in 'bookings', try 'ride_requests'
      if (!bookingDoc.exists) {
        bookingRef = _firestore.collection('ride_requests').doc(bookingId);
        bookingDoc = await bookingRef.get();
      }

      if (!bookingDoc.exists) {
        return {'success': false, 'error': 'Booking not found'};
      }

      final bookingData = bookingDoc.data() as Map<String, dynamic>;
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

  /// Mark booking as completed (handles both collections)
  /// Only works if booking is paid and status is ongoing or accepted
  static Future<Map<String, dynamic>> completeBooking(String bookingId) async {
    try {
      // Try to find booking in 'bookings' collection first
      DocumentReference? bookingRef;
      DocumentSnapshot? bookingDoc;

      bookingRef = _firestore.collection('bookings').doc(bookingId);
      bookingDoc = await bookingRef.get();

      // If not found in 'bookings', try 'ride_requests'
      if (!bookingDoc.exists) {
        bookingRef = _firestore.collection('ride_requests').doc(bookingId);
        bookingDoc = await bookingRef.get();
      }

      if (!bookingDoc.exists) {
        return {'success': false, 'error': 'Booking not found'};
      }

      final bookingData = bookingDoc.data() as Map<String, dynamic>;
      final isPaid = bookingData['isPaid'] ?? false;
      final status = (bookingData['status'] ?? '').toString().toLowerCase();

      // Only allow completion if paid and status is ongoing or accepted
      if (!isPaid) {
        return {
          'success': false,
          'error': 'Cannot complete ride. Payment not received yet.'
        };
      }

      if (status != 'ongoing' && status != 'accepted' && status != 'paid') {
        return {
          'success': false,
          'error': 'Ride can only be completed when status is ongoing or accepted'
        };
      }

      final userId = bookingData['userId'];

      // Update booking to completed
      // Note: Location tracking continues even after completion so user can track driver
      await bookingRef.update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // DO NOT stop location tracking - it should continue so user can track driver
      // Location tracking will only stop when the ride is truly finished (e.g., after drop time passes)

      // Send notification to user
      if (userId != null) {
        await _firestore.collection('notifications').add({
          'userId': userId,
          'title': 'Ride Completed',
          'message': 'Your ride has been completed by the driver.',
          'type': 'ride_completed',
          'bookingId': bookingId,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return {'success': true, 'message': 'Booking completed'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to complete booking: $e'};
    }
  }

  /// Get driver earnings from both bookings and ride_requests collections
  static Future<Map<String, dynamic>> getDriverEarnings(String driverId) async {
    try {
      // Get bookings and ride_requests with status either 'completed' or 'paid'
      final statusList = ['completed', 'paid'];

      final completedBookings = await _firestore
          .collection('bookings')
          .where('driverId', isEqualTo: driverId)
          .where('status', whereIn: statusList)
          .get();

      // Get completed/paid ride_requests
      final completedRideRequests = await _firestore
          .collection('ride_requests')
          .where('driverId', isEqualTo: driverId)
          .where('status', whereIn: statusList)
          .get();

      double totalEarnings = 0;
      int totalRides = 0;

      // Process bookings earnings (normalize fare keys)
      for (var doc in completedBookings.docs) {
        final data = doc.data();
        final fare =
            data['fare'] ?? data['price'] ?? data['amount'] ?? data['cost'];
        if (fare != null) {
          totalEarnings += (fare as num).toDouble();
        }
        totalRides++;
      }

      // Process ride_requests earnings (normalize price/fare keys)
      for (var doc in completedRideRequests.docs) {
        final data = doc.data();
        final fare =
            data['fare'] ?? data['price'] ?? data['amount'] ?? data['cost'];
        if (fare != null) {
          totalEarnings += (fare as num).toDouble();
        }
        totalRides++;
      }

      // Get today's earnings
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final todayTimestamp = Timestamp.fromDate(startOfDay);

      // Get today's bookings and ride_requests (status completed or paid)
      final todayBookings = await _firestore
          .collection('bookings')
          .where('driverId', isEqualTo: driverId)
          .where('status', whereIn: statusList)
          .where('completedAt', isGreaterThanOrEqualTo: todayTimestamp)
          .get();

      final todayRideRequests = await _firestore
          .collection('ride_requests')
          .where('driverId', isEqualTo: driverId)
          .where('status', whereIn: statusList)
          .where('completedAt', isGreaterThanOrEqualTo: todayTimestamp)
          .get();

      double todayEarnings = 0;
      int todayRides = 0;

      // Process today's bookings earnings
      for (var doc in todayBookings.docs) {
        final data = doc.data();
        final fare =
            data['fare'] ?? data['price'] ?? data['amount'] ?? data['cost'];
        if (fare != null) {
          todayEarnings += (fare as num).toDouble();
        }
        todayRides++;
      }

      // Process today's ride_requests earnings
      for (var doc in todayRideRequests.docs) {
        final data = doc.data();
        final fare =
            data['fare'] ?? data['price'] ?? data['amount'] ?? data['cost'];
        if (fare != null) {
          todayEarnings += (fare as num).toDouble();
        }
        todayRides++;
      }

      return {
        'success': true,
        'totalEarnings': totalEarnings,
        'totalRides': totalRides,
        'todayEarnings': todayEarnings,
        'todayRides': todayRides,
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

  Future<double> getTotalEarnings(String driverId) async {
    final rides = await _firestore
        .collection('ride_requests')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'paid')
        .get();

    double total = 0;
    for (var doc in rides.docs) {
      total += (doc['fare'] ?? 0).toDouble();
    }
    return total;
  }

  // Get rides from a specific pickup or destination location
  Future<List<Map<String, dynamic>>> getRidesByLocation(
    String driverId,
    String location,
  ) async {
    final rides = await _firestore
        .collection('ride_requests')
        .where('driverId', isEqualTo: driverId)
        .get();

    return rides.docs
        .where(
          (r) =>
              (r['pickup'] ?? '').toString().toLowerCase().contains(
                location.toLowerCase(),
              ) ||
              (r['destination'] ?? '').toString().toLowerCase().contains(
                location.toLowerCase(),
              ),
        )
        .map((r) => r.data())
        .toList();
  }

  // Get top pickup locations for the driver
  Future<Map<String, int>> getTopRideLocations(String driverId) async {
    final rides = await _firestore
        .collection('ride_requests')
        .where('driverId', isEqualTo: driverId)
        .get();

    final Map<String, int> counts = {};
    for (var doc in rides.docs) {
      final pickup = doc['pickup'] ?? 'Unknown';
      counts[pickup] = (counts[pickup] ?? 0) + 1;
    }

    // sort by frequency (descending)
    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries.take(5));
  }

  Future<Map<String, dynamic>> getDriverContext(String driverId) async {
    double totalEarnings = 0;
    Map<String, int> locationCount = {};

    final rides = await _firestore
        .collection('ride_requests')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'paid')
        .get();

    for (var doc in rides.docs) {
      totalEarnings += (doc['fare'] ?? 0).toDouble();
      final pickup = doc['pickup'] ?? 'Unknown';
      locationCount[pickup] = (locationCount[pickup] ?? 0) + 1;
    }

    final totalRides = rides.docs.length;
    final topLocations = locationCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final formattedLocations = topLocations
        .map((e) => "${e.key} (${e.value} rides)")
        .take(5)
        .join(", ");

    return {
      'totalEarnings': totalEarnings,
      'totalRides': totalRides,
      'topLocations': formattedLocations,
    };
  }
}
