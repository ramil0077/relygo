import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relygo/services/auth_service.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a deterministic conversation ID based on two user IDs
  static String _conversationIdFor(String userA, String userB) {
    final List<String> sorted = [userA, userB]..sort();
    return sorted.join('_');
  }

  /// Fetches a user's name from Firestore
  static Future<String?> _fetchUserName(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()?['name'] as String?;
  }

  /// Stream the current user's conversations ordered by last updated
  static Stream<List<Map<String, dynamic>>> getUserConversationsStream() {
    final String? userId = AuthService.currentUserId;
    if (userId == null) return const Stream.empty();
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots()
        .asyncMap((snapshot) async {
          final List<Map<String, dynamic>> conversations = [];
          for (final doc in snapshot.docs) {
            final data = doc.data();
            data['id'] = doc.id;

            final List<String> participants = List<String>.from(
              data['participants'] ?? [],
            );
            // Find the other participant (peer)
            String? peerId;
            for (final p in participants) {
              if (p != userId) {
                peerId = p;
                break;
              }
            }

            if (peerId != null) {
              final String? peerName = await _fetchUserName(peerId);
              data['peerName'] = peerName;
              data['peerId'] = peerId;
            }

            conversations.add(data);
          }
          return conversations;
        });
  }

  /// Stream messages for a given conversation
  static Stream<List<Map<String, dynamic>>> getMessagesStream(
    String conversationId,
  ) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  /// Send a message to a peer; creates conversation if missing
  static Future<void> sendMessage({
    required String peerId,
    required String text,
  }) async {
    final String? userId = AuthService.currentUserId;
    if (userId == null) return;

    final String conversationId = _conversationIdFor(userId, peerId);
    final DocumentReference convoRef = _firestore
        .collection('conversations')
        .doc(conversationId);

    // Ensure conversation exists
    await convoRef.set({
      'participants': [userId, peerId],
      'lastMessage': text,
      'lastSenderId': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Add message
    await convoRef.collection('messages').add({
      'senderId': userId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': [userId],
    });

    // Update conversation metadata
    await convoRef.update({
      'lastMessage': text,
      'lastSenderId': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Compute conversation ID for UI navigation
  static String conversationIdWithPeer(String peerId) {
    final String? userId = AuthService.currentUserId;
    if (userId == null) return peerId; // fallback
    return _conversationIdFor(userId, peerId);
  }
}
