import 'package:cloud_firestore/cloud_firestore.dart';

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
          .orderBy('createdAt', descending: true)
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
      await _firestore.collection('users').doc(driverId).update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

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
      await _firestore.collection('users').doc(driverId).update({
        'status': 'rejected',
        'rejectionReason': reason,
        'rejectedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
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

  /// Listen to all drivers in real-time
  static Stream<List<Map<String, dynamic>>> getAllDriversStream() {
    return _firestore
        .collection('users')
        .where('userType', isEqualTo: 'driver')
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

  /// Listen to all app users (non-drivers) in real-time
  static Stream<List<Map<String, dynamic>>> getAllAppUsersStream() {
    return _firestore
        .collection('users')
        .where('userType', isEqualTo: 'user')
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

  /// Listen to all users (drivers and non-drivers) in real-time
  static Stream<List<Map<String, dynamic>>> getAllUsersAndDriversStream() {
    return _firestore
        .collection('users')
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
    return query.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}
