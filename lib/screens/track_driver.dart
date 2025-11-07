import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
