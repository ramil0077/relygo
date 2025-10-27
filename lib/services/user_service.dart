import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relygo/services/auth_service.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream approved/active drivers (basic details)
  static Stream<List<Map<String, dynamic>>> getDriversStream() {
    return _firestore
        .collection('users')
        .where('userType', whereIn: ['driver', 'Driver'])
        .where('status', whereIn: ['approved', 'active', 'Approved', 'Active'])
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  /// Stream a single user's document by id
  static Stream<Map<String, dynamic>?> streamUserById(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;
      return {...data, 'id': doc.id};
    });
  }

  /// Update user document with partial fields
  static Future<void> updateUserFields(
    String userId,
    Map<String, dynamic> fields,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .set(fields, SetOptions(merge: true));
  }

  /// Update personal profile fields
  static Future<void> updatePersonalInfo({
    required String userId,
    String? name,
    String? email,
    String? phone,
    String? licenseNumber,
    String? photoUrl,
  }) async {
    final update = <String, dynamic>{};
    if (name != null) update['name'] = name;
    if (email != null) update['email'] = email;
    if (phone != null) update['phone'] = phone;
    if (licenseNumber != null) update['licenseNumber'] = licenseNumber;
    if (photoUrl != null) update['photoUrl'] = photoUrl;
    if (update.isEmpty) return;
    update['updatedAt'] = FieldValue.serverTimestamp();
    await updateUserFields(userId, update);
  }

  /// Update vehicle details for a driver
  static Future<void> updateVehicleInfo({
    required String userId,
    String? vehicleType,
    String? vehicleModel,
    String? registrationNumber,
    String? yearOfManufacture,
  }) async {
    final update = <String, dynamic>{};
    if (vehicleType != null) update['vehicle.type'] = vehicleType;
    if (vehicleModel != null) update['vehicle.model'] = vehicleModel;
    if (registrationNumber != null)
      update['vehicle.registrationNumber'] = registrationNumber;
    if (yearOfManufacture != null) update['vehicle.year'] = yearOfManufacture;
    if (update.isEmpty) return;
    update['updatedAt'] = FieldValue.serverTimestamp();
    await updateUserFields(userId, update);
  }

  /// Update bank details for payouts
  static Future<void> updateBankDetails({
    required String userId,
    String? bankName,
    String? accountNumber,
    String? ifsc,
  }) async {
    final update = <String, dynamic>{};
    if (bankName != null) update['bank.bankName'] = bankName;
    if (accountNumber != null) update['bank.accountNumber'] = accountNumber;
    if (ifsc != null) update['bank.ifsc'] = ifsc;
    if (update.isEmpty) return;
    update['updatedAt'] = FieldValue.serverTimestamp();
    await updateUserFields(userId, update);
  }

  /// Get all available drivers
  static Stream<List<Map<String, dynamic>>> getAvailableDriversStream() {
    return _firestore
        .collection('users')
        .where('userType', whereIn: ['driver', 'Driver'])
        .where('status', whereIn: ['approved', 'Approved'])
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  /// Stream current user's rides (recent first)
  static Stream<List<Map<String, dynamic>>> getCurrentUserRidesStream() {
    final userId = AuthService.currentUserId;
    if (userId == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('rides')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  /// Create a new booking
  static Future<Map<String, dynamic>> createBooking({
    required String userId,
    required String userName,
    required String userPhone,
    required String driverId,
    required String pickupLocation,
    required String dropoffLocation,
    required String bookingType,
    Map<String, dynamic>? additionalDetails,
  }) async {
    try {
      final bookingRef = await _firestore.collection('bookings').add({
        'userId': userId,
        'userName': userName,
        'userPhone': userPhone,
        'driverId': driverId,
        'pickupLocation': pickupLocation,
        'dropoffLocation': dropoffLocation,
        'bookingType': bookingType,
        'status': 'pending',
        'isPaid': false,
        'additionalDetails': additionalDetails,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send notification to driver
      await _firestore.collection('notifications').add({
        'driverId': driverId,
        'title': 'New Booking Request',
        'message': 'You have a new booking request from $userName',
        'type': 'booking_request',
        'bookingId': bookingRef.id,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Booking created successfully',
        'bookingId': bookingRef.id,
      };
    } catch (e) {
      return {'success': false, 'error': 'Failed to create booking: $e'};
    }
  }

  /// Get user's bookings
  static Stream<List<Map<String, dynamic>>> getUserBookingsStream(
    String userId,
  ) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
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

  /// Process payment for booking
  static Future<Map<String, dynamic>> processPayment(
    String bookingId,
    String paymentMethod,
  ) async {
    try {
      final bookingRef = _firestore.collection('bookings').doc(bookingId);
      final bookingDoc = await bookingRef.get();

      if (!bookingDoc.exists) {
        return {'success': false, 'error': 'Booking not found'};
      }

      final bookingData = bookingDoc.data()!;
      final driverId = bookingData['driverId'];

      // Simulate payment processing (in production, integrate with payment gateway)
      final paymentId = 'PAY_${DateTime.now().millisecondsSinceEpoch}';

      // Update booking
      await bookingRef.update({
        'isPaid': true,
        'paymentId': paymentId,
        'paymentMethod': paymentMethod,
        'paymentDate': FieldValue.serverTimestamp(),
        'status': 'ongoing',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notify driver about payment
      await _firestore.collection('notifications').add({
        'driverId': driverId,
        'title': 'Payment Received',
        'message':
            'Payment has been received for booking #${bookingId.substring(0, 8)}',
        'type': 'payment_received',
        'bookingId': bookingId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Payment processed successfully',
        'paymentId': paymentId,
      };
    } catch (e) {
      return {'success': false, 'error': 'Failed to process payment: $e'};
    }
  }

  /// Submit review and rating
  static Future<Map<String, dynamic>> submitReview({
    required String bookingId,
    required String userId,
    required String userName,
    required String driverId,
    required double rating,
    required String review,
  }) async {
    try {
      await _firestore.collection('reviews').add({
        'bookingId': bookingId,
        'userId': userId,
        'userName': userName,
        'driverId': driverId,
        'rating': rating,
        'review': review,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Also add to feedback collection for admin
      await _firestore.collection('feedback').add({
        'bookingId': bookingId,
        'userId': userId,
        'userName': userName,
        'driverId': driverId,
        'rating': rating,
        'feedback': review,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'message': 'Review submitted successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to submit review: $e'};
    }
  }

  /// Get user notifications
  static Stream<List<Map<String, dynamic>>> getUserNotificationsStream(
    String userId,
  ) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
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

  /// Cancel booking
  static Future<Map<String, dynamic>> cancelBooking(
    String bookingId,
    String reason,
  ) async {
    try {
      final bookingRef = _firestore.collection('bookings').doc(bookingId);
      final bookingDoc = await bookingRef.get();

      if (!bookingDoc.exists) {
        return {'success': false, 'error': 'Booking not found'};
      }

      final bookingData = bookingDoc.data()!;
      final driverId = bookingData['driverId'];

      await bookingRef.update({
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notify driver
      if (driverId != null) {
        await _firestore.collection('notifications').add({
          'driverId': driverId,
          'title': 'Booking Cancelled',
          'message':
              'Booking #${bookingId.substring(0, 8)} has been cancelled by user',
          'type': 'booking_cancelled',
          'bookingId': bookingId,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return {'success': true, 'message': 'Booking cancelled successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to cancel booking: $e'};
    }
  }

  /// Get reviews for a driver
  static Stream<List<Map<String, dynamic>>> getDriverReviewsStream(
    String driverId,
  ) {
    return _firestore
        .collection('reviews')
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

  /// Submit a complaint
  static Future<Map<String, dynamic>> submitComplaint({
    required String userId,
    required String driverId,
    required String bookingId,
    required String subject,
    required String description,
    String? category,
  }) async {
    try {
      await _firestore.collection('complaints').add({
        'userId': userId,
        'driverId': driverId,
        'bookingId': bookingId,
        'subject': subject,
        'description': description,
        'category': category ?? 'general',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'message': 'Complaint submitted successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to submit complaint: $e'};
    }
  }

  /// Submit feedback/review for a completed ride
  static Future<Map<String, dynamic>> submitFeedback({
    required String userId,
    required String driverId,
    required String bookingId,
    required int rating,
    required String review,
    String? category,
  }) async {
    try {
      await _firestore.collection('feedback').add({
        'userId': userId,
        'driverId': driverId,
        'bookingId': bookingId,
        'rating': rating,
        'review': review,
        'category': category ?? 'general',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'message': 'Feedback submitted successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to submit feedback: $e'};
    }
  }

  /// Get user's booking history
  static Stream<List<Map<String, dynamic>>> getUserBookingHistoryStream(
    String userId,
  ) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          List<Map<String, dynamic>> bookingsWithDetails = [];

          for (var doc in snapshot.docs) {
            final bookingData = doc.data();
            bookingData['id'] = doc.id;

            try {
              // Get driver details
              if (bookingData['driverId'] != null) {
                final driverDoc = await _firestore
                    .collection('users')
                    .doc(bookingData['driverId'])
                    .get();
                if (driverDoc.exists) {
                  bookingData['driverDetails'] = driverDoc.data();
                }
              }

              bookingsWithDetails.add(bookingData);
            } catch (e) {
              print('Error getting booking details: $e');
              bookingsWithDetails.add(bookingData);
            }
          }

          return bookingsWithDetails;
        });
  }

  /// Get driver reviews and ratings from feedback collection
  static Stream<List<Map<String, dynamic>>> getDriverFeedbackStream(
    String driverId,
  ) {
    return _firestore
        .collection('feedback')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          List<Map<String, dynamic>> reviewsWithDetails = [];

          for (var doc in snapshot.docs) {
            final reviewData = doc.data();
            reviewData['id'] = doc.id;

            try {
              // Get user details
              if (reviewData['userId'] != null) {
                final userDoc = await _firestore
                    .collection('users')
                    .doc(reviewData['userId'])
                    .get();
                if (userDoc.exists) {
                  reviewData['userDetails'] = userDoc.data();
                }
              }

              reviewsWithDetails.add(reviewData);
            } catch (e) {
              print('Error getting review details: $e');
              reviewsWithDetails.add(reviewData);
            }
          }

          return reviewsWithDetails;
        });
  }

  /// Get driver average rating
  static Future<Map<String, dynamic>> getDriverRatingStats(
    String driverId,
  ) async {
    try {
      final QuerySnapshot feedbackQuery = await _firestore
          .collection('feedback')
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: 'active')
          .get();

      if (feedbackQuery.docs.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalReviews': 0,
          'ratingBreakdown': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        };
      }

      double totalRating = 0;
      Map<int, int> ratingBreakdown = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (var doc in feedbackQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final rating = data['rating'] ?? 0;
        totalRating += rating.toDouble();
        ratingBreakdown[rating] = (ratingBreakdown[rating] ?? 0) + 1;
      }

      return {
        'averageRating': totalRating / feedbackQuery.docs.length,
        'totalReviews': feedbackQuery.docs.length,
        'ratingBreakdown': ratingBreakdown,
      };
    } catch (e) {
      print('Error getting driver rating stats: $e');
      return {
        'averageRating': 0.0,
        'totalReviews': 0,
        'ratingBreakdown': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      };
    }
  }

  /// Get user's active booking for tracking
  static Stream<Map<String, dynamic>?> getActiveBookingStream(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'accepted', 'ongoing'])
        .limit(1)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) return null;

          final bookingData = snapshot.docs.first.data();
          bookingData['id'] = snapshot.docs.first.id;

          try {
            // Get driver details
            if (bookingData['driverId'] != null) {
              final driverDoc = await _firestore
                  .collection('users')
                  .doc(bookingData['driverId'])
                  .get();
              if (driverDoc.exists) {
                bookingData['driverDetails'] = driverDoc.data();
              }
            }

            return bookingData;
          } catch (e) {
            print('Error getting active booking details: $e');
            return bookingData;
          }
        });
  }
}
