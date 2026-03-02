import 'dart:convert';
import 'package:http/http.dart' as http;
<<<<<<< HEAD
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

      // Build rich approval message with details
      final approvalMessage = _buildApprovalMessage(driverName);

      final templateParams = {
        'to_email': toEmail,
        'to_name': driverName,
        'app_name': 'RelyGo',
        'approval_message': approvalMessage,
        'approval_date': DateTime.now().toString().split(' ')[0], // YYYY-MM-DD
        'approval_status': 'APPROVED',
        'next_steps': _buildNextSteps(),
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
        print('Approval email sent successfully to $toEmail');
        return true;
      } else {
        print('EmailJS send failed: ${resp.statusCode} ${resp.body}');
        return false;
      }
    } catch (e) {
      print('EmailJS send error: $e');
=======

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
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
      return false;
    }
  }

<<<<<<< HEAD
  /// Build a detailed approval message for the driver
  static String _buildApprovalMessage(String driverName) {
    return '''
Congratulations $driverName!

Your driver application for RelyGo has been reviewed and APPROVED by our admin team.

We are excited to have you as part of the RelyGo platform. Your profile has been verified and you are now authorized to accept ride requests and start earning.

Key Details:
• Your account status is now ACTIVE and APPROVED
• You can log in immediately to start receiving ride requests
• Your driver profile is visible to passengers searching for rides
• You will begin earning commissions on completed rides

Welcome aboard! Thank you for choosing RelyGo.
''';
  }

  /// Build next steps information
  static String _buildNextSteps() {
    return '''
1. Log in to your RelyGo driver account
2. Complete your profile (if not already done)
3. Enable location services on your device
4. Start accepting ride requests
5. Provide excellent service to passengers

If you have any questions, contact our support team at support@relygo.com
''';
=======
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
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
  }
}
