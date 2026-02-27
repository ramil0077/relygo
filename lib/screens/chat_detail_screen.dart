import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/services/chat_service.dart';
import 'package:relygo/services/auth_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String peerName;
  final String? conversationId; // optional for backward compatibility
  final String? peerId; // optional for backward compatibility

  const ChatDetailScreen({
    super.key,
    required this.peerName,
    this.conversationId,
    this.peerId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Derive the peer id: use the explicit peerId first,
  /// or fall back to extracting it from the conversationId.
  String? get _effectivePeerId {
    if (widget.peerId != null && widget.peerId!.isNotEmpty) {
      return widget.peerId;
    }
    // conversationId is "uidA_uidB" — extract the peer's uid
    final convId = widget.conversationId ?? '';
    final parts = convId.split('_');
    if (parts.length == 2) {
      final myId = AuthService.currentUserId ?? '';
      return parts.firstWhere((p) => p != myId, orElse: () => '');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Mycolors.basecolor.withOpacity(0.1),
              child: Text(
                widget.peerName.isNotEmpty ? widget.peerName[0] : '?',
                style: GoogleFonts.poppins(
                  color: Mycolors.basecolor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.peerName,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: () {
                final String? convId =
                    widget.conversationId ??
                    (widget.peerId != null
                        ? ChatService.conversationIdWithPeer(widget.peerId!)
                        : null);
                if (convId == null || convId.isEmpty) {
                  return const Stream<List<Map<String, dynamic>>>.empty();
                }
                return ChatService.getMessagesStream(convId);
              }(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load messages',
                      style: GoogleFonts.poppins(color: Mycolors.red),
                    ),
                  );
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Say hello! 👋',
                      style: GoogleFonts.poppins(color: Mycolors.gray),
                    ),
                  );
                }
                // Auto-scroll to bottom
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    final String myId = AuthService.currentUserId ?? '';
                    final bool isMe = (m['senderId'] ?? '') == myId;
                    final String text = (m['text'] ?? '').toString();
                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Mycolors.basecolor : Mycolors.lightGray,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          text,
                          style: GoogleFonts.poppins(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Mycolors.basecolor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    final String? peer = _effectivePeerId;
    if (peer == null || peer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot send message: recipient not found',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Mycolors.red,
        ),
      );
      return;
    }
    await ChatService.sendMessage(peerId: peer, text: text);
    // Scroll to bottom after sending
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
}
