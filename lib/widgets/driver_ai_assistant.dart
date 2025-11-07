import 'package:flutter/material.dart';
import 'package:relygo/services/ai_services.dart';

import '../services/driver_service.dart';

class DriverAIAssistantScreen extends StatefulWidget {
  final String driverId;

  const DriverAIAssistantScreen({Key? key, required this.driverId}) : super(key: key);

  @override
  State<DriverAIAssistantScreen> createState() => _DriverAIAssistantScreenState();
}

class _DriverAIAssistantScreenState extends State<DriverAIAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final AIService _aiService = AIService();
  final DriverService _driverService = DriverService();

  List<Map<String, dynamic>> _messages = [];
  bool _loading = false;
  Map<String, dynamic>? _driverContext;

  final List<String> quickQuestions = [
    "What’s my total earnings?",
    "Which locations bring the most rides?",
    "Show rides I did in Kozhikode.",
    "When do I get the most rides?",
    "Any suggestions to earn more?",
  ];

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  Future<void> _loadDriverData() async {
    final data = await _driverService.getDriverContext(widget.driverId);
    setState(() => _driverContext = data);
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    setState(() {
      _messages.add({'text': message, 'isUser': true});
      _loading = true;
    });

    final reply = await _aiService.getAIResponse(message, _driverContext ?? {});
    setState(() {
      _messages.add({'text': reply, 'isUser': false});
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        backgroundColor: theme.primaryColor,
      ),
      body: Column(
        children: [
          // 🔹 Quick Question Cards
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              itemBuilder: (_, i) {
                return GestureDetector(
                  onTap: () => _sendMessage(quickQuestions[i]),
                  child: Container(
                    width: 180,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: theme.colorScheme.secondary, width: 1),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        quickQuestions[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: quickQuestions.length,
            ),
          ),

          // 🔹 Chat Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'];
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? theme.primaryColor.withOpacity(0.85)
                          : theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: CircularProgressIndicator(),
            ),

          // 🔹 Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            color: theme.scaffoldBackgroundColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask something...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: theme.primaryColor,
                  onPressed: () {
                    _sendMessage(_controller.text);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
