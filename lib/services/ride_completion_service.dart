import 'package:cloud_firestore/cloud_firestore.dart';

class RideCompletionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check and update ride completion status based on drop time
  static Future<void> checkAndUpdateRideCompletion() async {
    final now = DateTime.now();

    // Get all accepted rides that should be completed
    final ridesSnapshot = await _firestore
        .collection('ride_requests')
        .where('status', isEqualTo: 'accepted')
        .get();

    for (final doc in ridesSnapshot.docs) {
      final data = doc.data();
      final dropTime = data['dropTime'] as Timestamp?;

      if (dropTime != null) {
        final dropDateTime = dropTime.toDate();

        // If current time is past drop time, mark as completed
        if (now.isAfter(dropDateTime)) {
          await _firestore.collection('ride_requests').doc(doc.id).update({
            'status': 'completed',
            'completedAt': Timestamp.now(),
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
