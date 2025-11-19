import 'package:location/location.dart';
import 'dart:math' as math;

/// Service for location-related operations
class LocationService {
  static final Location _location = Location();

  /// Get current user location
  static Future<LocationData?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return null;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return null;
        }
      }

      return await _location.getLocation();
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Calculate distance between two coordinates in kilometers using Haversine formula
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Calculate estimated time of arrival in minutes
  /// Assuming average speed of 30 km/h in city traffic
  static int calculateETA(double distanceInKm, {double averageSpeedKmh = 30}) {
    if (distanceInKm <= 0) return 0;
    final timeInHours = distanceInKm / averageSpeedKmh;
    return (timeInHours * 60).round();
  }

  /// Format distance for display
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()} m';
    }
    return '${distanceInKm.toStringAsFixed(1)} km';
  }

  /// Get coordinates from address (geocoding) - placeholder
  /// In production, use Google Geocoding API or similar
  static Future<Map<String, double>?> getCoordinatesFromAddress(
    String address,
  ) async {
    // This is a placeholder - in production, integrate with geocoding service
    // For now, return null to indicate coordinates not available
    return null;
  }
}

