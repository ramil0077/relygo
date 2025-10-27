import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/chat_detail_screen.dart';
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

            // Live Tracking (Simulated)
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

    if (status.toLowerCase() != 'ongoing') {
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
                'Live tracking will be available when ride starts',
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

          // Simulated map view
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Map View',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Driver location will be shown here',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
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
                'Estimated arrival: 5-10 minutes',
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
