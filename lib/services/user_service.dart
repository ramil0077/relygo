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
}
