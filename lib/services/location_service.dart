<<<<<<< HEAD
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

=======
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Simple mockup of popular locations for suggestions if API fails or not available
  static const List<String> _popularLocations = [
    "Malabar College, Kerala",
    "Calicut International Airport",
    "Kozhikode Railway Station",
    "Mananchira Square, Kozhikode",
    "HiLite Mall, Kozhikode",
    "Focus Mall, Kozhikode",
    "Lulu Mall, Kochi",
    "Thiruvananthapuram Central",
    "Technopark, Trivandrum",
    "Infopark, Kochi",
    "MGM Hill, Wayanad",
    "Pookode Lake, Wayanad",
  ];

  /// Get location suggestions based on query
  static Future<List<String>> getSuggestions(String query) async {
    if (query.length < 3) return [];

    try {
      // 1. Try to get real results using geocoding (limited but works for some addresses)
      List<Location> locations = await locationFromAddress(query).timeout(
        const Duration(seconds: 2),
        onTimeout: () => [],
      );
      
      List<String> results = [];
      
      if (locations.isNotEmpty) {
        for (var loc in locations.take(3)) {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            loc.latitude,
            loc.longitude,
          );
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            final address = [
              p.name,
              p.street,
              p.subLocality,
              p.locality,
              p.administrativeArea
            ].where((e) => e != null && e.isNotEmpty).toSet().join(", ");
            if (address.isNotEmpty) results.add(address);
          }
        }
      }

      // 2. Add matching popular locations
      final matches = _popularLocations
          .where((l) => l.toLowerCase().contains(query.toLowerCase()))
          .toList();
      results.addAll(matches);

      return results.toSet().toList(); // Remove duplicates
    } catch (e) {
      // Fallback to popular locations on error
      return _popularLocations
          .where((l) => l.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  /// Get detailed address from coordinates
  static Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.name,
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.postalCode
        ].where((e) => e != null && e.isNotEmpty).toSet();
        return parts.join(", ");
      }
      return "$lat, $lng";
    } catch (e) {
      return "$lat, $lng";
    }
  }
}
>>>>>>> 19c60511df77cf71534b179d6daa8ec8cebe0b10
