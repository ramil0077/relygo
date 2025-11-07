import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  final String apiKey = 'AIzaSyDS5cxy2YkwFY34C51WeKBi6qpzzx2vb4U'; // 🔑 Replace with your Gemini API key
  final String model = 'gemini-2.0-flash'; // Latest model

  Future<String> getAIResponse(String query, Map<String, dynamic> contextData) async {
    final totalEarnings = contextData['totalEarnings']?.toString() ?? '0';
    final topLocations = contextData['topLocations'] ?? {};

    final prompt = """
You are an AI assistant for a rideshare driver dashboard.

Use this Firestore data to answer naturally and briefly.

Driver Data:
- Total Earnings: ₹$totalEarnings
- Top Ride Locations: $topLocations

Question: $query

Answer clearly and helpfully in short sentences.
""";

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text ?? "I couldn't generate a response right now.";
      } else {
        print('Gemini API error: ${response.body}');
        return "Error ${response.statusCode}: check your API key or quota.";
      }
    } catch (e) {
      print('Gemini request failed: $e');
      return "Connection failed. Please check your internet.";
    }
  }
}
