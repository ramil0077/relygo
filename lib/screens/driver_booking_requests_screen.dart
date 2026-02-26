import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/services/driver_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:relygo/utils/responsive_helper.dart';

class DriverBookingRequestsScreen extends StatefulWidget {
  const DriverBookingRequestsScreen({super.key});

  @override
  State<DriverBookingRequestsScreen> createState() =>
      _DriverBookingRequestsScreenState();
}

class _DriverBookingRequestsScreenState
    extends State<DriverBookingRequestsScreen>
    with ResponsiveHelper {
  final _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Booking Requests', style: titleStyle(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: DriverService.getPendingBookingsStream(_currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading requests',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No Pending Requests',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'New booking requests will appear here',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: context.responsivePadding,
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _buildBookingCard(booking);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final createdAt = booking['createdAt'];
    final timeStr = createdAt != null
        ? DateFormat('MMM dd, yyyy hh:mm a').format(createdAt.toDate())
        : 'Just now';

    final bookingType = booking['bookingType'] ?? 'driver_only';
    final isWithVehicle = bookingType == 'driver_with_vehicle';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Mycolors.basecolor.withOpacity(0.3)),
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Mycolors.basecolor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Mycolors.basecolor,
                  child: Text(
                    (booking['userName'] ?? 'U')[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['userName'] ?? 'Unknown User',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        booking['userPhone'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isWithVehicle
                        ? Mycolors.orange.withOpacity(0.2)
                        : Mycolors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isWithVehicle ? 'WITH VEHICLE' : 'DRIVER ONLY',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isWithVehicle ? Mycolors.orange : Mycolors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationRow(
                  Icons.location_on,
                  'Pickup',
                  booking['pickupLocation'] ?? 'N/A',
                  Mycolors.green,
                ),
                const SizedBox(height: 12),
                _buildLocationRow(
                  Icons.location_on_outlined,
                  'Dropoff',
                  booking['dropoffLocation'] ?? 'N/A',
                  Mycolors.red,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      timeStr,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (booking['additionalDetails'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Mycolors.lightGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Additional Details:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking['additionalDetails'].toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectBooking(booking['id']),
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(
                      'Reject',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Mycolors.red,
                      side: BorderSide(color: Mycolors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptBooking(booking['id']),
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(
                      'Accept',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Mycolors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(
    IconData icon,
    String label,
    String location,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                location,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _acceptBooking(String bookingId) async {
    final fareController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Enter Fare Amount',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please enter the fare amount for this ride:',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: fareController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Fare Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Mycolors.basecolor, width: 2),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Mycolors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Confirm', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirmed == true && fareController.text.isNotEmpty) {
      try {
        final fare = double.parse(fareController.text);

        // Get driver name from current user profile
        String driverName = 'Driver';
        final driverUid = _currentUserId;
        if (driverUid.isNotEmpty) {
          final driverDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(driverUid)
              .get();
          if (driverDoc.exists) {
            driverName =
                (driverDoc.data()?['name'] ??
                        driverDoc.data()?['fullName'] ??
                        'Driver')
                    .toString();
          }
        }

        final result = await DriverService.acceptBooking(
          bookingId,
          fare,
          driverName,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['success'] == true
                    ? 'Booking accepted successfully!'
                    : result['error'],
              ),
              backgroundColor: result['success'] == true
                  ? Mycolors.green
                  : Mycolors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid fare amount'),
              backgroundColor: Mycolors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _rejectBooking(String bookingId) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reject Booking',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to reject this booking?',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Reason (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Mycolors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Reject', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await DriverService.rejectBooking(
        bookingId,
        reasonController.text.trim().isEmpty
            ? null
            : reasonController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['success'] == true ? 'Booking rejected' : result['error'],
            ),
            backgroundColor: result['success'] == true
                ? Mycolors.orange
                : Mycolors.red,
          ),
        );
      }
    }
  }
}
