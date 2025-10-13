import 'package:flutter_test/flutter_test.dart';
import 'package:relygo/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    test('should have proper configuration', () {
      expect(AuthService.currentUser, isNull);
      expect(AuthService.isLoggedIn, isFalse);
    });

    test('should handle sign in with invalid credentials', () async {
      final result = await AuthService.signInWithEmailAndPassword(
        email: 'invalid@test.com',
        password: 'wrongpassword',
      );

      expect(result['success'], isFalse);
      expect(result['error'], isNotNull);
    });

    test('should handle password reset with invalid email', () async {
      final result = await AuthService.resetPassword('invalid@test.com');

      expect(result['success'], isFalse);
      expect(result['error'], isNotNull);
    });
  });
}
