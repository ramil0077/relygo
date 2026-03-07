import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';

class MapPickerScreen extends StatefulWidget {
  final String title;
  final LatLng? initialLocation;

  const MapPickerScreen({
    super.key,
    this.title = 'Choose Location',
    this.initialLocation,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late MapController _mapController;
  final TextEditingController _searchController = TextEditingController();

  // Default: Kerala, India
  LatLng _pickedLatLng = const LatLng(11.2588, 75.7804);
  String _pickedAddress = 'Move the map to pick a location';
  bool _isGeocoding = false;
  bool _isLoadingGPS = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.initialLocation != null) {
      _pickedLatLng = widget.initialLocation!;
    }
    // Fetch address for initial center
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reverseGeocode(_pickedLatLng);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocode(LatLng latlng) async {
    setState(() => _isGeocoding = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        latlng.latitude,
        latlng.longitude,
      ).timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final parts = <String>[];
        if ((p.name ?? '').isNotEmpty &&
            p.name != p.street &&
            p.name != p.thoroughfare) {
          parts.add(p.name!);
        }
        if ((p.street ?? '').isNotEmpty) parts.add(p.street!);
        if ((p.subLocality ?? '').isNotEmpty) parts.add(p.subLocality!);
        if ((p.locality ?? '').isNotEmpty) parts.add(p.locality!);
        if ((p.administrativeArea ?? '').isNotEmpty) {
          parts.add(p.administrativeArea!);
        }
        final address = parts.isNotEmpty
            ? parts.toSet().join(', ')
            : '${latlng.latitude.toStringAsFixed(5)}, ${latlng.longitude.toStringAsFixed(5)}';
        if (mounted) setState(() => _pickedAddress = address);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _pickedAddress =
              '${latlng.latitude.toStringAsFixed(5)}, ${latlng.longitude.toStringAsFixed(5)}';
        });
      }
    } finally {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  Future<void> _goToMyLocation() async {
    setState(() => _isLoadingGPS = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Enable GPS first', style: GoogleFonts.poppins()),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => Geolocator.openLocationSettings(),
              ),
            ),
          );
        }
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location permission denied',
                  style: GoogleFonts.poppins()),
            ),
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final newLatLng = LatLng(pos.latitude, pos.longitude);

      _mapController.move(newLatLng, 16.0);
      setState(() => _pickedLatLng = newLatLng);
      await _reverseGeocode(newLatLng);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Could not get location: $e',
                  style: GoogleFonts.poppins())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingGPS = false);
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _isGeocoding = true);
    try {
      List<Location> locations = await locationFromAddress(query).timeout(
        const Duration(seconds: 5),
      );
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final newLatLng = LatLng(loc.latitude, loc.longitude);
        _mapController.move(newLatLng, 16.0);
        setState(() => _pickedLatLng = newLatLng);
        await _reverseGeocode(newLatLng);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not find location', style: GoogleFonts.poppins()),
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error finding location', style: GoogleFonts.poppins()),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isGeocoding
                ? null
                : () {
                    Navigator.of(context).pop(_pickedAddress);
                  },
            child: Text(
              'Confirm',
              style: GoogleFonts.poppins(
                color: Mycolors.basecolor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── OpenStreetMap (no API key needed) ──────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pickedLatLng,
              initialZoom: 15.0,
              onTap: (tapPosition, point) {
                _mapController.move(point, 16.0);
                setState(() => _pickedLatLng = point);
                _reverseGeocode(point);
              },
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && position.center != null) {
                  setState(() => _pickedLatLng = position.center!);
                }
              },
              onMapEvent: (event) {
                if (event is MapEventMoveEnd ||
                    event is MapEventScrollWheelZoom) {
                  _reverseGeocode(_pickedLatLng);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.relygo.app',
              ),
            ],
          ),

          // ── Center Pin (always at center of map) ──────────────────────
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_pin, color: Colors.red, size: 48),
                SizedBox(height: 24), // offset for pin bottom point
              ],
            ),
          ),

          // ── Search Bar ─────────────────────────────────────────────────
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: _searchLocation,
                decoration: InputDecoration(
                  hintText: 'Search manually...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Mycolors.basecolor),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // ── GPS Button ─────────────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: 160,
            child: FloatingActionButton(
              mini: true,
              heroTag: 'gps_btn',
              backgroundColor: Colors.white,
              onPressed: _isLoadingGPS ? null : _goToMyLocation,
              child: _isLoadingGPS
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.my_location, color: Mycolors.basecolor),
            ),
          ),

          // ── Bottom Address Card ────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Location',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: Mycolors.basecolor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _isGeocoding
                            ? Row(
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Getting address...',
                                    style: GoogleFonts.poppins(
                                        color: Colors.grey, fontSize: 14),
                                  ),
                                ],
                              )
                            : Text(
                                _pickedAddress,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isGeocoding
                          ? null
                          : () {
                              Navigator.of(context).pop(_pickedAddress);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Mycolors.basecolor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Use This Location',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
