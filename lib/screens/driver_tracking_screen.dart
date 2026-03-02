import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/chat_detail_screen.dart';
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
  @override
  Widget build(BuildContext context) {
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

  Widget _buildDriverInfoCard(Map<String, dynamic> bookingData) {
    final driverDetails =
        bookingData['driverDetails'] as Map<String, dynamic>?;

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

  Widget _buildRideDetailsCard(Map<String, dynamic> bookingData) {
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
                      bookingData['pickupLocation'] ?? 'Unknown',
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
                      bookingData['dropoffLocation'] ?? 'Unknown',
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
          if (bookingData['fare'] != null)
              Row(
                children: [
                  Icon(Icons.attach_money, color: Mycolors.orange, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Fare: ₹${bookingData['fare']}',
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

  Widget _buildLiveTrackingCard(Map<String, dynamic> bookingData) {
    final status = bookingData['status']?.toString().toLowerCase() ?? 'unknown';
    final driverId = bookingData['driverId'];

    if (status != 'started' || driverId == null) {
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
                status == 'ongoing' 
                  ? 'Ride started! Tracking will appear soon.' 
                  : 'Live tracking will be available once the driver starts the ride.',
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
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tracking Stats
              if (lat != null && lng != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTrackingStat('Latitude', lat.toStringAsFixed(4)),
                    _buildTrackingStat('Longitude', lng.toStringAsFixed(4)),
                  ],
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
