import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:relygo/constants.dart';

class EmailService {
  /// Send approval email to driver using EmailJS REST API.
  ///
  /// Note: EmailJS allows sending from client using the public user id, but
  /// the template must be configured in EmailJS dashboard. Replace the
  /// EmailJsConfig values in `constants.dart` with your account values.
  static Future<bool> sendDriverApprovalEmail({
    required String toEmail,
    required String driverName,
  }) async {
    try {
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

      final templateParams = {
        'to_email': toEmail,
        'to_name': driverName,
        'app_name': 'RelyGo',
        // any other template variables you defined in EmailJS
      };

      final body = jsonEncode({
        'service_id': EmailJsConfig.serviceId,
        'template_id': EmailJsConfig.templateId,
        'user_id': EmailJsConfig.userId,
        'template_params': templateParams,
      });

      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (resp.statusCode == 200) {
        return true;
      } else {
        print('EmailJS send failed: ${resp.statusCode} ${resp.body}');
        return false;
      }
    } catch (e) {
      print('EmailJS send error: $e');
      return false;
    }
  }
}
