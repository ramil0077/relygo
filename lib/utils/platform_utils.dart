import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Platform detection utilities
class PlatformUtils {
  /// Check if the app is running on web
  static bool get isWeb => kIsWeb;

  /// Check if the app is running on mobile (Android/iOS)
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Check if the app is running on desktop (Windows/Mac/Linux)
  static bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  /// Check if payment features should be enabled
  /// Payment is disabled on web
  static bool get isPaymentEnabled => !isWeb;

  /// Check if location tracking features should be enabled
  /// Location tracking is disabled on web
  static bool get isLocationTrackingEnabled => !isWeb;

  /// Check if background services should be enabled
  /// Background services are disabled on web
  static bool get isBackgroundServiceEnabled => !isWeb;
}

