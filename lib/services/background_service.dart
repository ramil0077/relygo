import 'dart:async';
import 'package:relygo/services/ride_completion_service.dart';

class BackgroundService {
  static Timer? _timer;

  // Start the background service to check ride completion
  static void startRideCompletionChecker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      RideCompletionService.checkAndUpdateRideCompletion();
    });
  }

  // Stop the background service
  static void stopRideCompletionChecker() {
    _timer?.cancel();
    _timer = null;
  }
}
