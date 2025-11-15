import 'package:flutter/services.dart';

/// Phone number input formatter that only allows digits
class PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only allow digits (0-9)
    final filteredText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    return newValue.copyWith(
      text: filteredText,
      selection: TextSelection.collapsed(offset: filteredText.length),
    );
  }
}

/// Phone number validation utility
class PhoneValidation {
  /// Validates phone number format
  /// Returns null if valid, error message if invalid
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }

    // Remove spaces and special characters for validation
    final cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanedValue.isEmpty) {
      return 'Phone number cannot be empty';
    }

    if (cleanedValue.length < 10) {
      return 'Please enter a valid phone number (minimum 10 digits)';
    }

    if (cleanedValue.length > 13) {
      return 'Phone number is too long (maximum 13 digits)';
    }

    // Check if all characters are digits
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanedValue)) {
      return 'Phone number can only contain digits';
    }

    return null;
  }

  /// Checks if phone number contains only digits
  static bool isValidDigitsOnly(String value) {
    return RegExp(r'^[0-9]*$').hasMatch(value);
  }

  /// Formats phone number with spaces (e.g., 9876543210 -> 98765 43210)
  static String formatPhoneNumber(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length <= 5) {
      return cleaned;
    } else if (cleaned.length <= 10) {
      return '${cleaned.substring(0, 5)} ${cleaned.substring(5)}';
    } else {
      return '${cleaned.substring(0, 5)} ${cleaned.substring(5, 10)} ${cleaned.substring(10)}';
    }
  }
}
