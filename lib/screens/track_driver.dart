import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/utils/platform_utils.dart';

class TrackDriverMap extends StatefulWidget {
  final String driverId; // Same ID used by driver document in Firestore
  const TrackDriverMap({required this.driverId});

  @override
  State<TrackDriverMap> createState() => _TrackDriverMapState();
}

class _TrackDriverMapState extends State<TrackDriverMap> {
  GoogleMapController? _controller;
  LatLng? _driverPosition;

  @override
  void initState() {
    super.initState();
    _listenToDriverLocation();
  }

  void _listenToDriverLocation() {
    FirebaseFirestore.instance
        .collection('drivers')
        .doc(widget.driverId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final lat = data['latitude'];
        final lng = data['longitude'];
        if (lat != null && lng != null) {
          setState(() {
            _driverPosition = LatLng(lat, lng);
          });
          // Automatically animate camera when map is ready
          if (_controller != null) {
            _controller!.animateCamera(
              CameraUpdate.newLatLng(_driverPosition!),
            );
          }
        }
      }
    });
  }

  // Center camera on driver location manually (FAB action)
  void _centerOnDriver() {
    if (_driverPosition != null && _controller != null) {
      _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(_driverPosition!, 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show message on web that location tracking is not available
    if (PlatformUtils.isWeb) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Track Your Driver',
            style: GoogleFonts.poppins(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off,
                  size: 80,
                  color: Mycolors.basecolor.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'Location Tracking Not Available on Web',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Real-time location tracking is only available on mobile devices. Please use the mobile app to track your driver.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Mycolors.basecolor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Go Back',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Track Your Driver')),

      // Floating button configuration
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnDriver,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.my_location, color: Colors.white),
        tooltip: "Center on driver",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: _driverPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _driverPosition!,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('driver'),
                      position: _driverPosition!,
                      infoWindow: const InfoWindow(title: 'Driver'),
                    ),
                  },
                  onMapCreated: (controller) => _controller = controller,
                ),
                // Optional: Add a small bottom bar for design
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: const Offset(0, -2),
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
