import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:relygo/api_keys.dart';

class AIService {
  // Groq Configuration
  final String groqModel = 'llama-3.3-70b-versatile';
  final String groqFallbackModel = 'llama-3.1-8b-instant';

  // Gemini Configuration (Backup)
  final String geminiApiKey = 'AIzaSyDS5cxy2YkwFY34C51WeKBi6qpzzx2vb4U';
  final String geminiModel = 'gemini-1.5-flash';

  Future<String> getAIResponse(
    String query,
    Map<String, dynamic> contextData,
  ) async {
    final String groqApiKey = ApiKeys.groqApiKey;

    final totalEarnings = contextData['totalEarnings']?.toString() ?? '0';
    final totalRides = contextData['totalRides']?.toString() ?? '0';
    final todayEarnings = contextData['todayEarnings']?.toString() ?? '0';
    final todayRides = contextData['todayRides']?.toString() ?? '0';
    final topLocations = contextData['topLocations'] ?? 'No data';
    final recentRides = contextData['recentRides'] ?? 'No history';

    final prompt =
        """
You are RelyGo Assistant, a dedicated AI for RelyGo rideshare driver partners.
Use this real-time data to help the driver:
- Total Earnings: ₹$totalEarnings
- Today's Earnings: ₹$todayEarnings
- Total Rides: $totalRides
- Today's Rides: $todayRides
- Recent History: $recentRides
- Top Performance Areas: $topLocations

User Question: $query

Provide a concise, professional, and encouraging response.
""";

    // Try Groq Primary
    try {
      final response = await _callGroq(groqApiKey, groqModel, prompt);
      if (response != null && response.isNotEmpty) return response;

      // Try Groq Fallback
      final fallbackResponse = await _callGroq(
        groqApiKey,
        groqFallbackModel,
        prompt,
      );
      if (fallbackResponse != null && fallbackResponse.isNotEmpty)
        return fallbackResponse;
    } catch (e) {
      print('Groq completely failed: $e');
    }

    // Try Gemini Backup
    try {
      final geminiResponse = await _callGemini(
        geminiApiKey,
        geminiModel,
        prompt,
      );
      if (geminiResponse != null && geminiResponse.isNotEmpty) {
        return geminiResponse + "\n\n(Note: Generated via Backup AI)";
      }
    } catch (e) {
      print('Gemini also failed: $e');
    }

    return "I'm having trouble connecting to my AI systems. Please check your internet connection or try again later.";
  }

  Future<String?> _callGroq(String apiKey, String model, String prompt) async {
    if (apiKey.contains("YOUR_GROQ_API_KEY") || apiKey.isEmpty) return null;

    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              "model": model,
              "messages": [
                {
                  "role": "system",
                  "content":
                      "You are a helpful assistant for rideshare drivers.",
                },
                {"role": "user", "content": prompt},
              ],
              "temperature": 0.5,
              "max_tokens": 500,
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      }
    } catch (e) {
      print('Groq call to $model failed: $e');
    }
    return null;
  }

  Future<String?> _callGemini(
    String apiKey,
    String model,
    String prompt,
  ) async {
    if (apiKey.isEmpty) return null;

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "contents": [
                {
                  "parts": [
                    {"text": prompt},
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      }
    } catch (e) {
      print('Gemini call failed: $e');
    }
    return null;
  }
}
