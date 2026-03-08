import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:relygo/api_keys.dart';

class AIService {
  final String model = 'llama-3.1-8b-instant';

  Future<String> getAIResponse(
    String query,
    Map<String, dynamic> contextData,
  ) async {
    final String groqApiKey = ApiKeys.groqApiKey;

    final totalEarnings = contextData['totalEarnings']?.toString() ?? '0';
    final totalRides = contextData['totalRides']?.toString() ?? '0';
    final topLocations = contextData['topLocations'] ?? 'No data';

    final prompt =
        """
You are an AI assistant for a RelyGo rideshare driver.
Help the driver understand their performance based on this data:
- Total Earnings: ₹$totalEarnings
- Total Rides: $totalRides
- Top Locations: $topLocations

User Question: $query

Provide a helpful, concise response.
""";

    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $groqApiKey',
    };

    final body = jsonEncode({
      "model": model,
      "messages": [
        {
          "role": "system",
          "content": "You are a helpful assistant for rideshare drivers.",
        },
        {"role": "user", "content": prompt},
      ],
      "temperature": 0.5,
      "max_tokens": 500,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ??
            "I couldn't generate a response.";
      } else {
        print('Groq API error: ${response.statusCode} - ${response.body}');
        return "Error from AI assistant. Please try again later.";
      }
    } catch (e) {
      print('Groq request failed: $e');
      return "Connection failed. Please check your internet.";
    }
  }
}
