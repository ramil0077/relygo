<<<<<<< HEAD
import 'dart:async';
import 'dart:math' as math;
=======
import 'package:cloud_firestore/cloud_firestore.dart';
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/chat_detail_screen.dart';
<<<<<<< HEAD
import 'package:relygo/services/location_service.dart';
import 'package:relygo/utils/platform_utils.dart';
import 'package:relygo/utils/responsive.dart';
=======
import 'package:relygo/services/chat_service.dart';
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
import 'package:url_launcher/url_launcher.dart';

class DriverTrackingScreen extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> initialBookingData;

  const DriverTrackingScreen({
    super.key,
    required this.bookingId,
    required this.initialBookingData,
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
    // This works for all active rides: accepted, ongoing, paid, or completed (if paid)
    _driverLocationSubscription = FirebaseFirestore.instance
        .collection('drivers')
        .doc(driverId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final data = snapshot.data()!;
        final lat = data['latitude'];
        final lng = data['longitude'];
        final isActive = data['isActive'] ?? true; // Default to true if not set
        
        // Only update if location is available and tracking is active
        if (lat != null && lng != null && isActive) {
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
        } else if (lat != null && lng != null) {
          // Location exists but isActive is false - still show it
          setState(() {
            _driverPosition = LatLng(lat, lng);
            _isLoadingDriverLocation = false;
          });
          if (_userPosition != null) {
            _distance = LocationService.calculateDistance(
              _userPosition!.latitude,
              _userPosition!.longitude,
              lat,
              lng,
            );
            _eta = LocationService.calculateETA(_distance);
          }
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
<<<<<<< HEAD
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Track Your Driver',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 20, tablet: 22, desktop: 24),
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
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Status Card
            _buildBookingStatusCard(),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20, tablet: 24, desktop: 28)),

            // Driver Information Card
            _buildDriverInfoCard(),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20, tablet: 24, desktop: 28)),

            // Contact Actions
            _buildContactActions(),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20, tablet: 24, desktop: 28)),

            // Ride Details
            _buildRideDetailsCard(),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20, tablet: 24, desktop: 28)),

          // Live Tracking with Map
          _buildLiveTrackingCard(),
          ],
        ),
      ),
=======
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).snapshots(),
      builder: (context, snapshot) {
        final bookingData = snapshot.hasData && snapshot.data!.exists 
            ? snapshot.data!.data() as Map<String, dynamic> 
            : widget.initialBookingData;

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
                _buildBookingStatusCard(bookingData),
                const SizedBox(height: 20),

                // Driver Information Card
                _buildDriverInfoCard(bookingData),
                const SizedBox(height: 20),

                // Contact Actions
                _buildContactActions(bookingData),
                const SizedBox(height: 20),

                // Ride Details
                _buildRideDetailsCard(bookingData),
                const SizedBox(height: 20),

                // Live Tracking (Simulated)
                _buildLiveTrackingCard(bookingData),
              ],
            ),
          ),
        );
      }
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
    );
  }

  Widget _buildBookingStatusCard(Map<String, dynamic> bookingData) {
    final status = bookingData['status'] ?? 'unknown';
    final isPaid = bookingData['isPaid'] ?? false;
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
        statusIcon = Icons.payment;
        statusText = 'Payment Confirmed';
        break;
      case 'started':
        statusColor = Mycolors.green;
        statusIcon = Icons.local_taxi;
        statusText = 'Ride in Progress';
        break;
      case 'completed':
        statusColor = isPaid ? Mycolors.basecolor : Mycolors.green;
        statusIcon = isPaid ? Icons.local_taxi : Icons.check_circle_outline;
        statusText = isPaid ? 'Ride Active - Track Driver' : 'Ride Completed';
        break;
      case 'paid':
        statusColor = Mycolors.basecolor;
        statusIcon = Icons.local_taxi;
        statusText = 'Ride Active - Track Driver';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'Unknown Status';
    }

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12, tablet: 14, desktop: 16),
        ),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 32, tablet: 36, desktop: 40),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16, tablet: 18, desktop: 20)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22),
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 4, tablet: 5, desktop: 6)),
                Text(
                  'Booking ID: ${widget.bookingId.substring(0, 8)}...',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
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

  Widget _buildDriverInfoCard(Map<String, dynamic> bookingData) {
    final driverDetails =
        bookingData['driverDetails'] as Map<String, dynamic>?;

    if (driverDetails == null) {
      return Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12, tablet: 14, desktop: 16),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person,
              color: Colors.grey[600],
              size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 32, tablet: 36, desktop: 40),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16, tablet: 18, desktop: 20)),
            Expanded(
              child: Text(
                'Driver details will be available once booking is accepted',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
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
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12, tablet: 14, desktop: 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: ResponsiveUtils.getResponsiveElevation(context, mobile: 8, tablet: 10, desktop: 12),
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
                radius: ResponsiveUtils.getResponsiveSpacing(context, mobile: 30, tablet: 35, desktop: 40),
                backgroundColor: Mycolors.basecolor.withOpacity(0.1),
                child: Text(
                  driverName.isNotEmpty ? driverName[0] : 'D',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 24, tablet: 28, desktop: 32),
                    fontWeight: FontWeight.bold,
                    color: Mycolors.basecolor,
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16, tablet: 18, desktop: 20)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 20, tablet: 22, desktop: 24),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (vehicleType.isNotEmpty || vehicleNumber.isNotEmpty)
                      Text(
                        vehicleNumber.isNotEmpty
                            ? '$vehicleType • $vehicleNumber'
                            : vehicleType,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16, tablet: 18, desktop: 20)),
          if (driverPhone.isNotEmpty)
            Row(
              children: [
                Icon(
                  Icons.phone,
                  color: Mycolors.green,
                  size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 20, tablet: 22, desktop: 24),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 8, tablet: 10, desktop: 12)),
                Text(
                  driverPhone,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildContactActions(Map<String, dynamic> bookingData) {
    final driverDetails =
        bookingData['driverDetails'] as Map<String, dynamic>?;
    final driverId = bookingData['driverId'];
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
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16)),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _makePhoneCall(driverPhone),
                icon: Icon(
                  Icons.phone,
                  color: Colors.white,
                  size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 20, tablet: 22, desktop: 24),
                ),
                label: Text('Call'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Mycolors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16),
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16)),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _openChat(driverId, driverName),
                icon: Icon(
                  Icons.chat,
                  color: Colors.white,
                  size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 20, tablet: 22, desktop: 24),
                ),
                label: Text('Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Mycolors.basecolor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRideDetailsCard(Map<String, dynamic> bookingData) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12, tablet: 14, desktop: 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: ResponsiveUtils.getResponsiveElevation(context, mobile: 8, tablet: 10, desktop: 12),
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
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16, tablet: 18, desktop: 20)),

          // Pickup Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Mycolors.red,
                size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 20, tablet: 22, desktop: 24),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 12, tablet: 13, desktop: 14),
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      bookingData['pickupLocation'] ?? 'Unknown',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16, tablet: 18, desktop: 20)),

          // Dropoff Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Mycolors.green,
                size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 20, tablet: 22, desktop: 24),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dropoff',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 12, tablet: 13, desktop: 14),
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      bookingData['dropoffLocation'] ?? 'Unknown',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16, tablet: 18, desktop: 20)),

          // Fare
<<<<<<< HEAD
          if (widget.bookingData['fare'] != null)
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: Mycolors.orange,
                  size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 20, tablet: 22, desktop: 24),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16)),
                Text(
                  'Fare: ₹${widget.bookingData['fare']}',
=======
          if (bookingData['fare'] != null)
              Row(
                children: [
                  Icon(Icons.attach_money, color: Mycolors.orange, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Fare: ₹${bookingData['fare']}',
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
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

<<<<<<< HEAD
  Widget _buildLiveTrackingCard() {
    final status = widget.bookingData['status'] ?? 'unknown';
    final isPaid = widget.bookingData['isPaid'] ?? false;
    final statusLower = status.toLowerCase();
    // Active if: accepted, ongoing, paid, OR (completed and paid)
    final isActive = statusLower == 'accepted' ||
        statusLower == 'ongoing' ||
        statusLower == 'paid' ||
        (statusLower == 'completed' && isPaid);

    if (!isActive) {
=======
  Widget _buildLiveTrackingCard(Map<String, dynamic> bookingData) {
    final status = bookingData['status']?.toString().toLowerCase() ?? 'unknown';
    final driverId = bookingData['driverId'];

    if (status != 'started' || driverId == null) {
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
      return Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12, tablet: 14, desktop: 16),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_searching,
              color: Colors.grey[600],
              size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 32, tablet: 36, desktop: 40),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16, tablet: 18, desktop: 20)),
            Expanded(
              child: Text(
<<<<<<< HEAD
                'Live tracking will be available when driver accepts the ride',
=======
                status == 'ongoing' 
                  ? 'Ride started! Tracking will appear soon.' 
                  : 'Live tracking will be available once the driver starts the ride.',
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      );
    }

<<<<<<< HEAD
    // Show map view if on mobile, otherwise show message
    if (PlatformUtils.isWeb) {
      return Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12, tablet: 14, desktop: 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: ResponsiveUtils.getResponsiveElevation(context, mobile: 8, tablet: 10, desktop: 12),
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
                  size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 24, tablet: 26, desktop: 28),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16)),
                Text(
                  'Live Tracking',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16, tablet: 18, desktop: 20)),
            Container(
              padding: ResponsiveUtils.getResponsivePadding(context),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 8, tablet: 10, desktop: 12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[700],
                    size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 20, tablet: 22, desktop: 24),
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16)),
                  Expanded(
                    child: Text(
                      'Map view is available on mobile devices. Use the button below to open driver location in Google Maps.',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_driverPosition != null) ...[
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16, tablet: 18, desktop: 20)),
              ElevatedButton.icon(
                onPressed: _openInExternalMaps,
                icon: Icon(
                  Icons.map,
                  color: Colors.white,
                  size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 20, tablet: 22, desktop: 24),
                ),
                label: Text('Open in Google Maps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Mycolors.basecolor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12, tablet: 14, desktop: 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: ResponsiveUtils.getResponsiveElevation(context, mobile: 8, tablet: 10, desktop: 12),
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
                size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 24, tablet: 26, desktop: 28),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16)),
              Text(
                'Live Tracking',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22),
                  fontWeight: FontWeight.bold,
                ),
=======
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(driverId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: CircularProgressIndicator());
        }

        final driverData = snapshot.data!.data() as Map<String, dynamic>;
        final location = driverData['location'] as Map<String, dynamic>?;
        
        double? lat, lng;
        if (location != null) {
          lat = (location['latitude'] as num?)?.toDouble();
          lng = (location['longitude'] as num?)?.toDouble();
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
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
              ),
              const Spacer(),
              if (_driverPosition != null)
                IconButton(
                  icon: Icon(
                    Icons.open_in_new,
                    size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 24, tablet: 26, desktop: 28),
                  ),
                  onPressed: _openInExternalMaps,
                  tooltip: 'Open in Maps',
                  color: Mycolors.basecolor,
                ),
            ],
          ),
<<<<<<< HEAD
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16, tablet: 18, desktop: 20)),

          // Real map view
          Container(
            height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 300, tablet: 400, desktop: 500),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 8, tablet: 10, desktop: 12),
              ),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 8, tablet: 10, desktop: 12),
              ),
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
                            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16, tablet: 18, desktop: 20)),
                            Text(
                              'Waiting for driver location...',
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
=======
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_searching,
                    color: Mycolors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Live Tracking ON',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Mycolors.green,
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
                    ),
                ],
              ),
              const SizedBox(height: 16),

<<<<<<< HEAD
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16, tablet: 18, desktop: 20)),

          // Distance and ETA info
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(
                    ResponsiveUtils.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16),
                  ),
                  decoration: BoxDecoration(
                    color: Mycolors.basecolor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 8, tablet: 10, desktop: 12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.straighten,
                        color: Mycolors.basecolor,
                        size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 20, tablet: 22, desktop: 24),
                      ),
                      SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 8, tablet: 10, desktop: 12)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distance',
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 12, tablet: 13, desktop: 14),
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
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
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
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16)),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(
                    ResponsiveUtils.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16),
                  ),
                  decoration: BoxDecoration(
                    color: Mycolors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 8, tablet: 10, desktop: 12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Mycolors.orange,
                        size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 20, tablet: 22, desktop: 24),
                      ),
                      SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 8, tablet: 10, desktop: 12)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ETA',
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 12, tablet: 13, desktop: 14),
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
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
                              fontWeight: FontWeight.bold,
                              color: Mycolors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
=======
              // Tracking Stats
              if (lat != null && lng != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTrackingStat('Latitude', lat.toStringAsFixed(4)),
                    _buildTrackingStat('Longitude', lng.toStringAsFixed(4)),
                  ],
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
                ),
                const SizedBox(height: 16),
              ],

              // Map Placeholder with coordinates
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  image: lat != null ? const DecorationImage(
                    image: AssetImage('assets/logooo.png'), // Using logo as a placeholder icon
                    scale: 5,
                  ) : null,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 48, color: Mycolors.basecolor.withOpacity(0.5)),
                      const SizedBox(height: 8),
                      Text(
                        lat != null ? 'Driver is currently at ($lat, $lng)' : 'Waiting for GPS signal...',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Estimated arrival
              Row(
                children: [
                  Icon(Icons.access_time, color: Mycolors.orange, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Driver is on the way!',
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
    );
  }

  Widget _buildTrackingStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
        Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
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
    final String conversationId = ChatService.conversationIdWithPeer(driverId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          peerName: driverName,
          conversationId: conversationId,
          peerId: driverId,
        ),
      ),
    );
  }
}
