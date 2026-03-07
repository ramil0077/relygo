import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:relygo/constants.dart';

class EmailService {
  /// Send approval email to driver using EmailJS REST API.
  ///
  /// Note: EmailJS REST API requires the 'accessToken' (private key) in the
  /// request body when called from non-browser environments (like a Flutter app).
  /// Get your private key from EmailJS Dashboard → Account → API Keys.
  /// Set it in `constants.dart` as EmailJsConfig.privateKey.
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
        'template_id': EmailJsConfig.approvalTemplateId,
        'user_id': EmailJsConfig.userId,
        'accessToken':
            EmailJsConfig.privateKey, // Required for non-browser calls
        'template_params': templateParams,
      });

      final resp = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'http://localhost',
        },
        body: body,
      );

      if (resp.statusCode == 200) {
        print('Approval email sent successfully to $toEmail');
        return true;
      } else {
        print(
          'EmailJS approval send failed: ${resp.statusCode} - "${resp.body}"',
        );
        return false;
      }
    } catch (e) {
      print('EmailJS approval send error: $e');
      return false;
    }
  }

  /// Send rejection email to driver using EmailJS REST API.
  static Future<bool> sendDriverRejectionEmail({
    required String driverName,
    required String driverEmail,
    required String reason,
  }) async {
    try {
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

      // Build rejection message with details
      final rejectionMessage = _buildRejectionMessage(driverName, reason);

      final templateParams = {
        'to_email': driverEmail,
        'to_name': driverName,
        'app_name': 'RelyGo',
        'approval_message':
            rejectionMessage, // Using same key as approval for consistency in template if reused
        'approval_date': DateTime.now().toString().split(' ')[0], // YYYY-MM-DD
        'approval_status': 'REJECTED',
        'rejection_reason': reason,
        'next_steps':
            'You can apply again after addressing the reasons for rejection.',
      };

      final body = jsonEncode({
        'service_id': EmailJsConfig.serviceId,
        'template_id': EmailJsConfig.rejectionTemplateId,
        'user_id': EmailJsConfig.userId,
        'accessToken':
            EmailJsConfig.privateKey, // Required for non-browser calls
        'template_params': templateParams,
      });

      final resp = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'http://localhost',
        },
        body: body,
      );

      if (resp.statusCode == 200) {
        print('Rejection email sent successfully to $driverEmail');
        return true;
      } else {
        print(
          'EmailJS rejection send failed: ${resp.statusCode} - "${resp.body}"',
        );
        return false;
      }
    } catch (e) {
      print('EmailJS rejection send error: $e');
      return false;
    }
  }

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

  /// Build a detailed rejection message for the driver
  static String _buildRejectionMessage(String driverName, String reason) {
    return '''
Dear $driverName,

Thank you for your interest in joining RelyGo as a driver. Our admin team has reviewed your application.

Unfortunately, we are unable to approve your application at this time for the following reason(s):

$reason

If you believe this decision was made in error or if you have addressed the issues mentioned above, you are welcome to submit a new application in the future.

Thank you for your understanding.
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
  }
}
