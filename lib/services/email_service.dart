import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  // EmailJS Credentials - These should be provided by the USER
  // For now, using placeholders
  static const String _serviceId = 'service_418nip9 ';
  static const String _templateId = 'template_2hvhyzd';
  static const String _userId = 'DUxMvuZFPNxopEw8A';

  /// Send approval email to driver
  static Future<bool> sendDriverApprovalEmail({
    required String driverName,
    required String driverEmail,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost', // Required by EmailJS for some plans
        },
        body: json.encode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _userId,
          'template_params': {
            'to_name': driverName,
            'to_email': driverEmail,
            'subject': 'Welcome to RelyGo! - Your Driver Account is Approved',
            'message': 'Congratulations $driverName, your application to join RelyGo as a driver has been approved. You can now log in to the app and start accepting rides.',
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Approval email sent successfully to $driverEmail');
        return true;
      } else {
        print('Failed to send email: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending approval email: $e');
      return false;
    }
  }

  /// Send rejection email to driver
  static Future<bool> sendDriverRejectionEmail({
    required String driverName,
    required String driverEmail,
    required String reason,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: json.encode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _userId,
          'template_params': {
            'to_name': driverName,
            'to_email': driverEmail,
            'subject': 'Update on your RelyGo Driver Application',
            'message': 'Hi $driverName, thank you for your interest in RelyGo. Unfortunately, your application has not been approved at this time for the following reason: $reason',
          },
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending rejection email: $e');
      return false;
    }
  }
}
