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
