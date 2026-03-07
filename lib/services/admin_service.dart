import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relygo/services/email_service.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all pending driver applications
  static Future<List<Map<String, dynamic>>> getPendingDrivers() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'driver')
          .where('status', isEqualTo: 'pending')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting pending drivers: $e');
      return [];
    }
  }

  /// Get all drivers (pending, approved, rejected)
  static Future<List<Map<String, dynamic>>> getAllDrivers() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'driver')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting all drivers: $e');
      return [];
    }
  }

  /// Approve a driver application
  static Future<Map<String, dynamic>> approveDriver(String driverId) async {
    try {
      final docRef = _firestore.collection('users').doc(driverId);
      final doc = await docRef.get();
      
      if (!doc.exists) return {'success': false, 'error': 'Driver not found'};
      final data = doc.data()!;

      await docRef.update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Try to send approval email to driver (non-fatal if it fails)
      try {
        final doc = await _firestore.collection('users').doc(driverId).get();
        if (doc.exists) {
          final dataRaw = doc.data();
          String? email;
          String? name;
          if (dataRaw is Map<String, dynamic>) {
            email = dataRaw['email']?.toString();
            name = dataRaw['name']?.toString();
          }

          if (email != null && email.isNotEmpty) {
            await EmailService.sendDriverApprovalEmail(
              toEmail: email,
              driverName: name ?? 'Driver',
            );
          }
        }
      } catch (e) {
        // Log but continue - approval already applied in Firestore
        print('Failed to send approval email: $e');
      }

      return {
        'success': true,
        'message': 'Driver application approved successfully',
      };
    } catch (e) {
      return {'success': false, 'error': 'Failed to approve driver: $e'};
    }
  }

  /// Reject a driver application
  static Future<Map<String, dynamic>> rejectDriver(
    String driverId,
    String reason,
  ) async {
    try {
      final docRef = _firestore.collection('users').doc(driverId);
      final doc = await docRef.get();
      
      if (!doc.exists) return {'success': false, 'error': 'Driver not found'};
      final data = doc.data()!;

      await docRef.update({
        'status': 'rejected',
        'rejectionReason': reason,
        'rejectedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send Rejection Email
      await EmailService.sendDriverRejectionEmail(
        driverName: data['name'] ?? 'Driver',
        driverEmail: data['email'] ?? '',
        reason: reason,
      );

      // Send In-app Notification
      await _firestore.collection('notifications').add({
        'userId': driverId,
        'title': 'Application Rejected',
        'message': 'Your driver application has been rejected. Reason: $reason',
        'type': 'account_rejection',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      return {
        'success': true,
        'message': 'Driver application rejected successfully',
      };
    } catch (e) {
      return {'success': false, 'error': 'Failed to reject driver: $e'};
    }
  }

  /// Get driver application details
  static Future<Map<String, dynamic>?> getDriverDetails(String driverId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(driverId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting driver details: $e');
      return null;
    }
  }

  /// Get application statistics
  static Future<Map<String, int>> getApplicationStats() async {
    try {
      final QuerySnapshot pendingQuery = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'driver')
          .where('status', isEqualTo: 'pending')
          .get();

      final QuerySnapshot approvedQuery = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'driver')
          .where('status', isEqualTo: 'approved')
          .get();

      final QuerySnapshot rejectedQuery = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'driver')
          .where('status', isEqualTo: 'rejected')
          .get();

      return {
        'pending': pendingQuery.docs.length,
        'approved': approvedQuery.docs.length,
        'rejected': rejectedQuery.docs.length,
        'total':
            pendingQuery.docs.length +
            approvedQuery.docs.length +
            rejectedQuery.docs.length,
      };
    } catch (e) {
      print('Error getting application stats: $e');
      return {'pending': 0, 'approved': 0, 'rejected': 0, 'total': 0};
    }
  }

  /// Listen to pending drivers in real-time
  static Stream<List<Map<String, dynamic>>> getPendingDriversStream() {
    return _firestore
        .collection('users')
        .where('userType', isEqualTo: 'driver')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  /// Listen to all drivers in real-time
  static Stream<List<Map<String, dynamic>>> getAllDriversStream() {
    return _firestore
        .collection('users')
        .where('userType', isEqualTo: 'driver')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  /// Listen to all app users (non-drivers) in real-time
  static Stream<List<Map<String, dynamic>>> getAllAppUsersStream() {
    return _firestore
        .collection('users')
        .where('userType', isEqualTo: 'user')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  /// Listen to all users (drivers and non-drivers) in real-time
  static Stream<List<Map<String, dynamic>>> getAllUsersAndDriversStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Listen to feedback/reviews with optional filters
  static Stream<List<Map<String, dynamic>>> getFeedbackStream({
    String? userId,
    String? driverId,
  }) {
    Query query = _firestore.collection('feedback');
    if (userId != null && userId.isNotEmpty) {
      query = query.where('userId', isEqualTo: userId);
    }
    if (driverId != null && driverId.isNotEmpty) {
      query = query.where('driverId', isEqualTo: driverId);
    }
    return query.snapshots().asyncMap((snapshot) async {
      final List<Map<String, dynamic>> enriched = [];

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        // Enrich with user name if missing
        // Check for both user_id (snake_case) and userId (camelCase)
        final userId = data['user_id'] ?? data['userId'];
        if ((data['userName'] == null ||
                (data['userName'] as String).isEmpty) &&
            userId != null) {
          try {
            final userDoc = await _firestore
                .collection('users')
                .doc(userId.toString())
                .get();
            if (userDoc.exists) {
              final u = userDoc.data() as Map<String, dynamic>;
              data['userName'] = u['name'] ?? userId.toString();
            }
          } catch (_) {
            // ignore enrichment failure; leave userId as fallback
          }
        }

        enriched.add(data);
      }

      return enriched;
    });
  }

  /// Get bookings for a specific user
  static Stream<List<Map<String, dynamic>>> getUserBookingsStream(
    String userId,
  ) {
    return _firestore
        .collection('ride_requests')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final bookings = snapshot.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data() as Map);
            data['id'] = doc.id;
            // Normalize field names
            if (data['pickupLocation'] == null && data['pickup'] != null) {
              data['pickupLocation'] = data['pickup'];
            }
            if (data['dropoffLocation'] == null &&
                data['destination'] != null) {
              data['dropoffLocation'] = data['destination'];
            }
            // Normalize status: 'paid' -> 'completed'
            if (data['status']?.toString().toLowerCase() == 'paid') {
              data['status'] = 'completed';
            }
            return data;
          }).toList();

          // Sort in memory by createdAt (newest first) to avoid index requirement
          bookings.sort((a, b) {
            final aTime = a['createdAt'] ?? a['updatedAt'] ?? a['paidAt'];
            final bTime = b['createdAt'] ?? b['updatedAt'] ?? b['paidAt'];
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            if (aTime is Timestamp && bTime is Timestamp) {
              return bTime.compareTo(aTime); // descending
            }
            return 0;
          });

          return bookings;
        });
  }

  /// Get all complaints
  static Stream<List<Map<String, dynamic>>> getComplaintsStream() {
    return _firestore.collection('complaints').snapshots().asyncMap((
      snapshot,
    ) async {
      final List<Map<String, dynamic>> enriched = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        // Normalize status for consistent filtering
        final rawStatus = (data['status'] ?? 'open').toString();
        data['status'] = rawStatus.toLowerCase();

        // Enrich with user name if missing
        if ((data['userName'] == null ||
                (data['userName'] as String).isEmpty) &&
            data['userId'] != null) {
          try {
            final userDoc = await _firestore
                .collection('users')
                .doc(data['userId'])
                .get();
            if (userDoc.exists) {
              final u = userDoc.data() as Map<String, dynamic>;
              data['userName'] = u['name'] ?? data['userId'];
            }
          } catch (_) {
            // ignore enrichment failure; leave userId as fallback
          }
        }

        enriched.add(data);
      }

      return enriched;
    });
  }

  /// Get complaints by user
  static Stream<List<Map<String, dynamic>>> getUserComplaintsStream(
    String userId,
  ) {
    return _firestore
        .collection('complaints')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  /// Update complaint status and add admin response
  static Future<Map<String, dynamic>> updateComplaintStatus(
    String complaintId,
    String status,
    String adminResponse,
  ) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).update({
        'status': status,
        'adminResponse': adminResponse,
        'respondedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'message': 'Complaint updated successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to update complaint: $e'};
    }
  }

  /// Send message to driver
  static Future<Map<String, dynamic>> sendMessageToDriver(
    String driverId,
    String message,
  ) async {
    try {
      await _firestore.collection('messages').add({
        'driverId': driverId,
        'senderId': 'admin',
        'senderType': 'admin',
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      return {'success': true, 'message': 'Message sent successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to send message: $e'};
    }
  }

  /// Get chat messages with driver
  static Stream<List<Map<String, dynamic>>> getDriverChatStream(
    String driverId,
  ) {
    return _firestore
        .collection('messages')
        .where('driverId', isEqualTo: driverId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  /// Send message to user
  static Future<Map<String, dynamic>> sendMessageToUser(
    String userId,
    String message,
  ) async {
    try {
      await _firestore.collection('user_messages').add({
        'userId': userId,
        'senderId': 'admin',
        'senderType': 'admin',
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      return {'success': true, 'message': 'Message sent successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to send message: $e'};
    }
  }

  /// Get chat messages with user
  static Stream<List<Map<String, dynamic>>> getUserChatStream(
    String userId,
  ) {
    return _firestore
        .collection('user_messages')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  /// Get feedback statistics
  static Future<Map<String, dynamic>> getFeedbackStats() async {
    try {
      final QuerySnapshot feedbackQuery = await _firestore
          .collection('feedback')
          .get();

      double totalRating = 0;
      int count = feedbackQuery.docs.length;

      for (var doc in feedbackQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalRating += (data['rating'] ?? 0).toDouble();
      }

      return {
        'totalFeedback': count,
        'averageRating': count > 0 ? totalRating / count : 0.0,
      };
    } catch (e) {
      print('Error getting feedback stats: $e');
      return {'totalFeedback': 0, 'averageRating': 0.0};
    }
  }

  /// Get recent activities from multiple collections
  static Stream<List<Map<String, dynamic>>> getRecentActivitiesStream() async* {
    // We'll combine different activity types
    await for (var _ in Stream.periodic(const Duration(seconds: 5))) {
      List<Map<String, dynamic>> activities = [];

      try {
        // Get recent bookings
        final bookingsSnapshot = await _firestore
            .collection('bookings')
            .limit(3)
            .get();

        for (var doc in bookingsSnapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          data['activityType'] = 'booking';
          activities.add(data);
        }

        // Get recent drivers (pending)
        final driversSnapshot = await _firestore
            .collection('users')
            .where('userType', whereIn: ['driver', 'Driver'])
            .where('status', whereIn: ['pending', 'Pending'])
            .limit(2)
            .get();

        for (var doc in driversSnapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          data['activityType'] = 'driver_registration';
          activities.add(data);
        }

        // Get recent SOS alerts
        final emergenciesSnapshot = await _firestore
            .collection('emergencies')
            .orderBy('timestamp', descending: true)
            .limit(3)
            .get();

        for (var doc in emergenciesSnapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          data['activityType'] = 'sos';
          activities.add(data);
        }

        // Get recent complaints
        final complaintsSnapshot = await _firestore
            .collection('complaints')
            .limit(2)
            .get();

        for (var doc in complaintsSnapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          data['activityType'] = 'complaint';
          activities.add(data);
        }

        // Get recent feedback
        final feedbackSnapshot = await _firestore
            .collection('feedback')
            .limit(2)
            .get();

        for (var doc in feedbackSnapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          data['activityType'] = 'feedback';

          // Enrich with user name if missing
          // Check for both user_id (snake_case) and userId (camelCase)
          final userId = data['user_id'] ?? data['userId'];
          if ((data['userName'] == null ||
                  (data['userName'] as String).isEmpty) &&
              userId != null) {
            try {
              final userDoc = await _firestore
                  .collection('users')
                  .doc(userId.toString())
                  .get();
              if (userDoc.exists) {
                final u = userDoc.data() as Map<String, dynamic>;
                data['userName'] = u['name'] ?? userId.toString();
              }
            } catch (_) {
              // ignore enrichment failure; leave userId as fallback
            }
          }

          activities.add(data);
        }

        // Sort all activities by createdAt
        activities.sort((a, b) {
          final aTime = a['createdAt'] as Timestamp?;
          final bTime = b['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        // Return top 8 activities
        yield activities.take(8).toList();
      } catch (e) {
        print('Error getting recent activities: $e');
        yield [];
      }
    }
  }

  /// Get service report data
  static Future<Map<String, dynamic>> getServiceReport() async {
    try {
      // Get total bookings
      final QuerySnapshot bookingsQuery = await _firestore
          .collection('bookings')
          .get();

      // Get completed bookings
      final QuerySnapshot completedQuery = await _firestore
          .collection('bookings')
          .where('status', isEqualTo: 'completed')
          .get();

      // Get cancelled bookings
      final QuerySnapshot cancelledQuery = await _firestore
          .collection('bookings')
          .where('status', isEqualTo: 'cancelled')
          .get();

      // Get feedback stats
      final feedbackStats = await getFeedbackStats();

      // Get active drivers
      final QuerySnapshot activeDriversQuery = await _firestore
          .collection('users')
          .where('userType', whereIn: ['driver', 'Driver'])
          .where('status', whereIn: ['approved', 'Approved'])
          .get();

      // Get total users
      final QuerySnapshot usersQuery = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'user')
          .get();

      // Calculate total revenue
      double totalRevenue = 0;
      for (var doc in completedQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalRevenue += (data['fare'] ?? 0).toDouble();
      }

      return {
        'totalBookings': bookingsQuery.docs.length,
        'completedBookings': completedQuery.docs.length,
        'cancelledBookings': cancelledQuery.docs.length,
        'totalRevenue': totalRevenue,
        'totalFeedback': feedbackStats['totalFeedback'],
        'averageRating': feedbackStats['averageRating'],
        'activeDrivers': activeDriversQuery.docs.length,
        'totalUsers': usersQuery.docs.length,
      };
    } catch (e) {
      print('Error getting service report: $e');
      return {
        'totalBookings': 0,
        'completedBookings': 0,
        'cancelledBookings': 0,
        'totalRevenue': 0.0,
        'totalFeedback': 0,
        'averageRating': 0.0,
        'activeDrivers': 0,
        'totalUsers': 0,
      };
    }
  }

  /// Suspend a driver
  static Future<Map<String, dynamic>> suspendDriver(String driverId) async {
    try {
      await _firestore.collection('users').doc(driverId).update({
        'status': 'suspended',
        'suspendedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'message': 'Driver suspended successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to suspend driver: $e'};
    }
  }

  /// Reactivate a suspended driver
  static Future<Map<String, dynamic>> reactivateDriver(String driverId) async {
    try {
      await _firestore.collection('users').doc(driverId).update({
        'status': 'approved',
        'reactivatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'message': 'Driver reactivated successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to reactivate driver: $e'};
    }
  }

  /// Delete a driver
  static Future<Map<String, dynamic>> deleteDriver(String driverId) async {
    try {
      await _firestore.collection('users').doc(driverId).delete();

      return {'success': true, 'message': 'Driver deleted successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to delete driver: $e'};
    }
  }

  /// Update feedback status
  static Future<Map<String, dynamic>> updateFeedbackStatus(
    String feedbackId,
    String status,
  ) async {
    try {
      await _firestore.collection('feedback').doc(feedbackId).update({
        'status': status,
        'moderatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Feedback status updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to update feedback status: $e',
      };
    }
  }

  /// Get all bookings with user and driver details
  static Stream<List<Map<String, dynamic>>> getAllBookingsStream() {
    return _firestore.collection('bookings').snapshots().asyncMap((
      snapshot,
    ) async {
      List<Map<String, dynamic>> bookingsWithDetails = [];

      for (var doc in snapshot.docs) {
        final bookingData = doc.data();
        bookingData['id'] = doc.id;

        try {
          // Get user details
          if (bookingData['userId'] != null) {
            final userDoc = await _firestore
                .collection('users')
                .doc(bookingData['userId'])
                .get();
            if (userDoc.exists) {
              bookingData['userDetails'] = userDoc.data();
            }
          }

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

  /// Get booking statistics stream (real-time updates)
  static Stream<Map<String, dynamic>> getBookingStatsStream() {
    return _firestore.collection('ride_requests').snapshots().map((snapshot) {
      int completedCount = 0;
      int cancelledCount = 0;
      int ongoingCount = 0;
      int pendingCount = 0;
      double totalRevenue = 0;

      for (var doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data() as Map);
        final status = (data['status'] ?? '').toString().toLowerCase();

        if (status == 'completed' || status == 'paid') {
          completedCount++;
          totalRevenue += (data['fare'] ?? data['price'] ?? data['amount'] ?? 0)
              .toDouble();
        } else if (status == 'cancelled') {
          cancelledCount++;
        } else if (status == 'ongoing' || status == 'accepted') {
          ongoingCount++;
        } else if (status == 'pending') {
          pendingCount++;
        }
      }

      return {
        'totalBookings': snapshot.docs.length,
        'completedBookings': completedCount,
        'cancelledBookings': cancelledCount,
        'ongoingBookings': ongoingCount,
        'pendingBookings': pendingCount,
        'totalRevenue': totalRevenue,
        'averageFare': completedCount > 0 ? totalRevenue / completedCount : 0.0,
      };
    });
  }

  /// Get booking statistics
  static Future<Map<String, dynamic>> getBookingStats() async {
    try {
      // Get all bookings from ride_requests collection
      final QuerySnapshot allBookings = await _firestore
          .collection('ride_requests')
          .get();

      // Count by status (including 'paid' as completed)
      int completedCount = 0;
      int cancelledCount = 0;
      int ongoingCount = 0;
      int pendingCount = 0;
      double totalRevenue = 0;

      for (var doc in allBookings.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = (data['status'] ?? '').toString().toLowerCase();

        if (status == 'completed' || status == 'paid') {
          completedCount++;
          totalRevenue += (data['fare'] ?? data['price'] ?? data['amount'] ?? 0)
              .toDouble();
        } else if (status == 'cancelled') {
          cancelledCount++;
        } else if (status == 'ongoing' || status == 'accepted') {
          ongoingCount++;
        } else if (status == 'pending') {
          pendingCount++;
        }
      }

      return {
        'totalBookings': allBookings.docs.length,
        'completedBookings': completedCount,
        'cancelledBookings': cancelledCount,
        'ongoingBookings': ongoingCount,
        'pendingBookings': pendingCount,
        'totalRevenue': totalRevenue,
        'averageFare': completedCount > 0 ? totalRevenue / completedCount : 0.0,
      };
    } catch (e) {
      print('Error getting booking stats: $e');
      return {
        'totalBookings': 0,
        'completedBookings': 0,
        'cancelledBookings': 0,
        'ongoingBookings': 0,
        'pendingBookings': 0,
        'totalRevenue': 0.0,
        'averageFare': 0.0,
      };
    }
  }

  /// Get bookings by status
  static Stream<List<Map<String, dynamic>>> getBookingsByStatusStream(
    String status,
  ) {
    return _firestore
        .collection('bookings')
        .where('status', isEqualTo: status)
        .snapshots()
        .asyncMap((snapshot) async {
          List<Map<String, dynamic>> bookingsWithDetails = [];

          for (var doc in snapshot.docs) {
            final bookingData = doc.data();
            bookingData['id'] = doc.id;

            try {
              // Get user details
              if (bookingData['userId'] != null) {
                final userDoc = await _firestore
                    .collection('users')
                    .doc(bookingData['userId'])
                    .get();
                if (userDoc.exists) {
                  bookingData['userDetails'] = userDoc.data();
                }
              }

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

  /// Unified bookings stream: merges 'bookings' and legacy 'ride_requests'
  static Stream<List<Map<String, dynamic>>> getUnifiedBookingsStream({
    String? status,
  }) {
    final Stream<QuerySnapshot<Map<String, dynamic>>> baseStream = _firestore
        .collection('bookings')
        .snapshots();

    return baseStream.asyncMap((snapshot) async {
      List<Map<String, dynamic>> results = [];

      Future<Map<String, dynamic>> enrich(
        Map<String, dynamic> bookingData,
      ) async {
        // Attach id if missing
        bookingData['id'] = bookingData['id'] ?? '';

        // Normalize status for legacy rides
        final rawStatus = (bookingData['status'] ?? '')
            .toString()
            .toLowerCase();
        if (rawStatus == 'paid') bookingData['status'] = 'completed';

        // Ensure createdAt exists
        bookingData['createdAt'] =
            bookingData['createdAt'] ??
            bookingData['updatedAt'] ??
            bookingData['paidAt'];

        try {
          if (bookingData['userId'] != null) {
            final userDoc = await _firestore
                .collection('users')
                .doc(bookingData['userId'])
                .get();
            if (userDoc.exists) {
              bookingData['userDetails'] = userDoc.data();
            }
          }
          if (bookingData['driverId'] != null) {
            final driverDoc = await _firestore
                .collection('users')
                .doc(bookingData['driverId'])
                .get();
            if (driverDoc.exists) {
              bookingData['driverDetails'] = driverDoc.data();
            }
          }
        } catch (e) {
          // swallow but keep data
        }
        return bookingData;
      }

      // Current 'bookings' collection
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        if (status == null ||
            (data['status']?.toString().toLowerCase() ==
                status.toLowerCase())) {
          results.add(await enrich(data));
        }
      }

      // Legacy 'ride_requests' collection
      try {
        Query rrQuery = _firestore.collection('ride_requests');
        if (status != null) {
          // Map completed<->paid for legacy store
          final wanted = status.toLowerCase() == 'completed'
              ? ['completed', 'paid']
              : [status.toLowerCase()];
          // Due to Firestore constraints, use simple equality if not 'completed'
          if (wanted.length == 1) {
            rrQuery = rrQuery.where('status', isEqualTo: wanted.first);
          } else {
            // best-effort: fetch recent and filter client-side
            rrQuery = rrQuery.orderBy('createdAt', descending: true).limit(200);
          }
        } else {
          rrQuery = rrQuery.orderBy('createdAt', descending: true).limit(200);
        }

        final rrSnap = await rrQuery.get();
        for (var doc in rrSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = data['id'] ?? doc.id;
          // Filter client-side when needed
          if (status != null) {
            final s = (data['status'] ?? '').toString().toLowerCase();
            final normalized = s == 'paid' ? 'completed' : s;
            if (normalized != status.toLowerCase()) continue;
          }
          results.add(await enrich(data));
        }
      } catch (e) {
        // ignore missing collection or indexing issues
      }

      // Sort newest first by createdAt if available
      results.sort((a, b) {
        final ta = a['createdAt'] as Timestamp?;
        final tb = b['createdAt'] as Timestamp?;
        if (ta == null && tb == null) return 0;
        if (ta == null) return 1;
        if (tb == null) return -1;
        return tb.compareTo(ta);
      });

      return results;
    });
  }

  /// Get booking details by ID
  static Future<Map<String, dynamic>?> getBookingDetails(
    String bookingId,
  ) async {
    try {
      final DocumentSnapshot bookingDoc = await _firestore
          .collection('bookings')
          .doc(bookingId)
          .get();

      if (!bookingDoc.exists) return null;

      final bookingData = bookingDoc.data() as Map<String, dynamic>;
      bookingData['id'] = bookingDoc.id;

      // Get user details
      if (bookingData['userId'] != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(bookingData['userId'])
            .get();
        if (userDoc.exists) {
          bookingData['userDetails'] = userDoc.data();
        }
      }

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
      print('Error getting booking details: $e');
      return null;
    }
  }

  /// Update booking status
  static Future<Map<String, dynamic>> updateBookingStatus(
    String bookingId,
    String status,
    String? adminNote,
  ) async {
    try {
      final Map<String, dynamic> updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (adminNote != null && adminNote.isNotEmpty) {
        updateData['adminNote'] = adminNote;
      }

      await _firestore.collection('bookings').doc(bookingId).update(updateData);

      return {
        'success': true,
        'message': 'Booking status updated successfully',
      };
    } catch (e) {
      return {'success': false, 'error': 'Failed to update booking status: $e'};
    }
  }

  /// Get bookings by date range
  static Stream<List<Map<String, dynamic>>> getBookingsByDateRangeStream(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection('bookings')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .snapshots()
        .asyncMap((snapshot) async {
          List<Map<String, dynamic>> bookingsWithDetails = [];

          for (var doc in snapshot.docs) {
            final bookingData = doc.data();
            bookingData['id'] = doc.id;

            try {
              // Get user details
              if (bookingData['userId'] != null) {
                final userDoc = await _firestore
                    .collection('users')
                    .doc(bookingData['userId'])
                    .get();
                if (userDoc.exists) {
                  bookingData['userDetails'] = userDoc.data();
                }
              }

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
}