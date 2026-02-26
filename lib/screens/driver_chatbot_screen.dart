import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relygo/services/auth_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class DriverChatbotScreen extends StatefulWidget {
  const DriverChatbotScreen({super.key});

  @override
  State<DriverChatbotScreen> createState() => _DriverChatbotScreenState();
}

class _DriverChatbotScreenState extends State<DriverChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // Driver stats cached for chatbot
  int _totalRides = 0;
  int _todayRides = 0;
  double _totalEarnings = 0;
  double _todayEarnings = 0;
  double _averageRating = 0;

  @override
  void initState() {
    super.initState();
    _fetchDriverStats();
    _addBotMessage(
      "Hello! I am your RelyGo Assistant. You can ask me about your rides, earnings, and ratings.",
    );
  }

  Future<void> _fetchDriverStats() async {
    final driverId = AuthService.currentUserId;
    if (driverId == null) return;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      // Rides & Earnings
      final ridesSnap = await FirebaseFirestore.instance
          .collection('ride_requests')
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: 'completed')
          .get();

      int totRides = 0;
      int todRides = 0;
      double totEarnings = 0;
      double todEarnings = 0;

      for (var doc in ridesSnap.docs) {
        totRides++;
        final data = doc.data();
        final fare = (data['fare'] ?? 0) as num;
        totEarnings += fare.toDouble();

        final createdAt = data['createdAt'] as Timestamp?;
        if (createdAt != null && createdAt.toDate().isAfter(startOfDay)) {
          todRides++;
          todEarnings += fare.toDouble();
        }
      }

      // Ratings
      final reviewsSnap = await FirebaseFirestore.instance
          .collection('reviews')
          .where('driverId', isEqualTo: driverId)
          .get();

      double rating = 0;
      if (reviewsSnap.docs.isNotEmpty) {
        final total = reviewsSnap.docs.fold<double>(
          0,
          (sum, d) => sum + ((d.data()['rating'] ?? 0) as num).toDouble(),
        );
        rating = total / reviewsSnap.docs.length;
      }

      if (mounted) {
        setState(() {
          _totalRides = totRides;
          _todayRides = todRides;
          _totalEarnings = totEarnings;
          _todayEarnings = todEarnings;
          _averageRating = rating;
        });
      }
    } catch (e) {
      debugPrint("Error fetching driver stats for chatbot: $e");
    }
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _messageController.clear();
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _scrollToBottom();

    // Simulate network delay for typing effect
    Future.delayed(const Duration(milliseconds: 1000), () {
      _generateBotResponse(text);
    });
  }

  void _generateBotResponse(String userText) {
    String response = "";
    final lowerText = userText.toLowerCase();

    if (lowerText.contains("earning") ||
        lowerText.contains("money") ||
        lowerText.contains("paid")) {
      if (lowerText.contains("today")) {
        response =
            "You have earned ₹${_todayEarnings.toStringAsFixed(0)} today.";
      } else {
        response =
            "Your total earnings so far are ₹${_totalEarnings.toStringAsFixed(0)}.\nToday's earnings: ₹${_todayEarnings.toStringAsFixed(0)}.";
      }
    } else if (lowerText.contains("ride") || lowerText.contains("trip")) {
      if (lowerText.contains("today")) {
        response = "You have completed $_todayRides rides today.";
      } else {
        response =
            "You have completed a total of $_totalRides rides.\nToday's rides: $_todayRides.";
      }
    } else if (lowerText.contains("rating") ||
        lowerText.contains("review") ||
        lowerText.contains("star")) {
      response =
          "Your current average rating is ${_averageRating > 0 ? _averageRating.toStringAsFixed(1) : 'Not rated yet'} ⭐️ based on passenger feedback.";
    } else if (lowerText.contains("hi") ||
        lowerText.contains("hello") ||
        lowerText.contains("hey")) {
      response =
          "Hello again! Just let me know if you want to check your rides, earnings, or ratings.";
    } else {
      response =
          "I'm not quite sure. Try asking me about your 'earnings', 'rides', or 'ratings'!";
    }

    _addBotMessage(response);
  }

  void _addBotMessage(String text) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _messages.add(
        ChatMessage(text: text, isUser: false, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Mycolors.basecolor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy, color: Mycolors.basecolor, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Driver Assistant',
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Mycolors.basecolor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Assistant is typing...",
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: message.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          IntrinsicWidth(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? Mycolors.basecolor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: GoogleFonts.poppins(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}",
            style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Ask about your earnings...",
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: _handleSubmitted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _handleSubmitted(_messageController.text),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Mycolors.basecolor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
