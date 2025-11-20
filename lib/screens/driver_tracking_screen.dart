import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/chat_detail_screen.dart';
import 'package:relygo/services/location_service.dart';
import 'package:relygo/utils/platform_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverTrackingScreen extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;

  const DriverTrackingScreen({
    super.key,
    required this.bookingId,
    required this.bookingData,
  });

  @override
  State<DriverTrackingScreen> createState() => _DriverTrackingScreenState();
}

class _DriverTrackingScreenState extends State<DriverTrackingScreen> {
  GoogleMapController? _mapController;
  LatLng? _driverPosition;
  LatLng? _userPosition;
  double _distance = 0.0;
  int _eta = 0;
  StreamSubscription<DocumentSnapshot>? _driverLocationSubscription;
  LocationData? _currentUserLocation;
  bool _isLoadingDriverLocation = true;
  // Default location (can be a default city center or pickup location)
  LatLng _defaultLocation = const LatLng(11.2588, 75.7804); // Kozhikode, Kerala

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  @override
  void dispose() {
    _driverLocationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeTracking() async {
    final driverId = widget.bookingData['driverId'];
    if (driverId == null) {
      setState(() {
        _isLoadingDriverLocation = false;
      });
      return;
    }

    // Get user's current location (non-blocking - don't wait for it to show map)
    _getUserLocation();

    // Listen to driver location updates
    _driverLocationSubscription = FirebaseFirestore.instance
        .collection('drivers')
        .doc(driverId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final data = snapshot.data()!;
        final lat = data['latitude'];
        final lng = data['longitude'];
        if (lat != null && lng != null) {
          setState(() {
            _driverPosition = LatLng(lat, lng);
            _isLoadingDriverLocation = false;
          });

          // Calculate distance and ETA if user location is available
          if (_userPosition != null) {
            _distance = LocationService.calculateDistance(
              _userPosition!.latitude,
              _userPosition!.longitude,
              lat,
              lng,
            );
            _eta = LocationService.calculateETA(_distance);
          }

          // Update map camera
          _updateMapCamera();
        } else {
          setState(() {
            _isLoadingDriverLocation = false;
          });
        }
      } else if (mounted) {
        setState(() {
          _isLoadingDriverLocation = false;
        });
      }
    });
  }

  Future<void> _getUserLocation() async {
    try {
      _currentUserLocation = await LocationService.getCurrentLocation();
      if (_currentUserLocation?.latitude != null &&
          _currentUserLocation?.longitude != null && mounted) {
        setState(() {
          _userPosition = LatLng(
            _currentUserLocation!.latitude!,
            _currentUserLocation!.longitude!,
          );
        });
        // Update map camera if driver position is already available
        if (_driverPosition != null) {
          _updateMapCamera();
        }
      }
    } catch (e) {
      print('Error getting user location: $e');
    }
  }

  void _updateMapCamera() {
    if (_mapController == null) return;
    
    if (_driverPosition != null && _userPosition != null) {
      // Fit both markers in view
      try {
        final bounds = LatLngBounds(
          southwest: LatLng(
            math.min(_driverPosition!.latitude, _userPosition!.latitude),
            math.min(_driverPosition!.longitude, _userPosition!.longitude),
          ),
          northeast: LatLng(
            math.max(_driverPosition!.latitude, _userPosition!.latitude),
            math.max(_driverPosition!.longitude, _userPosition!.longitude),
          ),
        );
        _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
      } catch (e) {
        // Fallback to driver position if bounds calculation fails
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_driverPosition!, 15),
        );
      }
    } else if (_driverPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_driverPosition!, 15),
      );
    } else if (_userPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_userPosition!, 15),
      );
    }
  }

  Future<void> _openInExternalMaps() async {
    if (_driverPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Driver location not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Open in Google Maps
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${_driverPosition!.latitude},${_driverPosition!.longitude}';
    final uri = Uri.parse(googleMapsUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot open maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Track Your Driver',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Status Card
            _buildBookingStatusCard(),
            const SizedBox(height: 20),

            // Driver Information Card
            _buildDriverInfoCard(),
            const SizedBox(height: 20),

            // Contact Actions
            _buildContactActions(),
            const SizedBox(height: 20),

            // Ride Details
            _buildRideDetailsCard(),
            const SizedBox(height: 20),

          // Live Tracking with Map
          _buildLiveTrackingCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingStatusCard() {
    final status = widget.bookingData['status'] ?? 'unknown';
    final isPaid = widget.bookingData['isPaid'] ?? false;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Mycolors.orange;
        statusIcon = Icons.schedule;
        statusText = 'Waiting for Driver';
        break;
      case 'accepted':
        statusColor = Mycolors.green;
        statusIcon = Icons.check_circle;
        statusText = isPaid ? 'Driver En Route' : 'Payment Required';
        break;
      case 'ongoing':
        statusColor = Mycolors.basecolor;
        statusIcon = Icons.local_taxi;
        statusText = 'Ride in Progress';
        break;
      case 'completed':
        statusColor = Mycolors.green;
        statusIcon = Icons.check_circle_outline;
        statusText = 'Ride Completed';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'Unknown Status';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Booking ID: ${widget.bookingId.substring(0, 8)}...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfoCard() {
    final driverDetails =
        widget.bookingData['driverDetails'] as Map<String, dynamic>?;

    if (driverDetails == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.person, color: Colors.grey[600], size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Driver details will be available once booking is accepted',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final driverName = driverDetails['name'] ?? 'Unknown Driver';
    final driverPhone = driverDetails['phone'] ?? '';
    final vehicleType = driverDetails['vehicleType'] ?? '';
    final vehicleNumber = driverDetails['vehicleNumber'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Mycolors.basecolor.withOpacity(0.1),
                child: Text(
                  driverName.isNotEmpty ? driverName[0] : 'D',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Mycolors.basecolor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (vehicleType.isNotEmpty || vehicleNumber.isNotEmpty)
                      Text(
                        vehicleNumber.isNotEmpty
                            ? '$vehicleType • $vehicleNumber'
                            : vehicleType,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (driverPhone.isNotEmpty)
            Row(
              children: [
                Icon(Icons.phone, color: Mycolors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  driverPhone,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildContactActions() {
    final driverDetails =
        widget.bookingData['driverDetails'] as Map<String, dynamic>?;
    final driverId = widget.bookingData['driverId'];
    final driverName = driverDetails?['name'] ?? 'Driver';
    final driverPhone = driverDetails?['phone'] ?? '';

    if (driverDetails == null || driverId == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Driver',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _makePhoneCall(driverPhone),
                icon: const Icon(Icons.phone, color: Colors.white),
                label: const Text('Call'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Mycolors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _openChat(driverId, driverName),
                icon: const Icon(Icons.chat, color: Colors.white),
                label: const Text('Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Mycolors.basecolor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRideDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ride Details',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Pickup Location
          Row(
            children: [
              Icon(Icons.location_on, color: Mycolors.red, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      widget.bookingData['pickupLocation'] ?? 'Unknown',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Dropoff Location
          Row(
            children: [
              Icon(Icons.location_on, color: Mycolors.green, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dropoff',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      widget.bookingData['dropoffLocation'] ?? 'Unknown',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Fare
          if (widget.bookingData['fare'] != null)
            Row(
              children: [
                Icon(Icons.attach_money, color: Mycolors.orange, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Fare: ₹${widget.bookingData['fare']}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Mycolors.orange,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLiveTrackingCard() {
    final status = widget.bookingData['status'] ?? 'unknown';
    final isActive = status.toLowerCase() == 'accepted' ||
        status.toLowerCase() == 'ongoing';

    if (!isActive) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.location_searching, color: Colors.grey[600], size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Live tracking will be available when driver accepts the ride',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show map view if on mobile, otherwise show message
    if (PlatformUtils.isWeb) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_searching,
                  color: Mycolors.basecolor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Live Tracking',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Map view is available on mobile devices. Use the button below to open driver location in Google Maps.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_driverPosition != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _openInExternalMaps,
                icon: const Icon(Icons.map, color: Colors.white),
                label: const Text('Open in Google Maps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Mycolors.basecolor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_searching,
                color: Mycolors.basecolor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Live Tracking',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_driverPosition != null)
                IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: _openInExternalMaps,
                  tooltip: 'Open in Maps',
                  color: Mycolors.basecolor,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Real map view
          Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _driverPosition ?? 
                              _userPosition ?? 
                              _defaultLocation,
                      zoom: _driverPosition != null || _userPosition != null ? 15 : 12,
                    ),
                    markers: _buildMarkers(),
                    polylines: _buildPolylines(),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      // Update camera after map is created
                      if (_driverPosition != null || _userPosition != null) {
                        _updateMapCamera();
                      }
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  ),
                  // Show loading indicator overlay only when waiting for driver location
                  if (_isLoadingDriverLocation && _driverPosition == null)
                    Container(
                      color: Colors.white.withOpacity(0.8),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Waiting for driver location...',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Distance and ETA info
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Mycolors.basecolor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.straighten, color: Mycolors.basecolor, size: 20),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distance',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            _driverPosition != null && _userPosition != null
                                ? LocationService.formatDistance(_distance)
                                : _isLoadingDriverLocation
                                    ? 'Calculating...'
                                    : 'Not available',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Mycolors.basecolor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Mycolors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Mycolors.orange, size: 20),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ETA',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            _driverPosition != null && _userPosition != null
                                ? (_eta > 0 ? '$_eta min' : 'Calculating...')
                                : _isLoadingDriverLocation
                                    ? 'Calculating...'
                                    : 'Not available',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Mycolors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // Driver marker
    if (_driverPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: _driverPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
          infoWindow: const InfoWindow(
            title: 'Driver',
            snippet: 'Your driver is here',
          ),
        ),
      );
    }

    // User marker (pickup location)
    if (_userPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: _userPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Pickup point',
          ),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    if (_driverPosition == null || _userPosition == null) {
      return {};
    }

    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [_userPosition!, _driverPosition!],
        color: Mycolors.basecolor,
        width: 3,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    };
  }

  void _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot make phone call'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _openChat(String driverId, String driverName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatDetailScreen(peerName: driverName, peerId: driverId),
      ),
    );
  }
}
