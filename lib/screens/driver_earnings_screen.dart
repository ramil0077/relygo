import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/services/driver_service.dart';
import 'package:relygo/services/auth_service.dart';
import 'package:relygo/utils/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  @override
  Widget build(BuildContext context) {
    final driverId = AuthService.currentUserId;

    if (driverId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view earnings')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Earnings & History',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),

            // Earnings Summary
            _buildEarningsSummary(driverId),
            SizedBox(height: ResponsiveSpacing.getLargeSpacing(context)),

            // Ride History
            Text(
              'Ride History',
              style: ResponsiveTextStyles.getTitleStyle(context),
            ),
            SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),

            _buildRideHistory(driverId),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsSummary(String driverId) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DriverService.getDriverEarnings(driverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Error loading earnings: ${snapshot.error}',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }

        final earnings = snapshot.data ?? {};
        final totalEarnings = earnings['totalEarnings'] ?? 0.0;
        final totalRides = earnings['totalRides'] ?? 0;
        final todayEarnings = earnings['todayEarnings'] ?? 0.0;
        final todayRides = earnings['todayRides'] ?? 0;

        return Container(
          padding: ResponsiveUtils.getResponsivePadding(context),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Mycolors.basecolor, Mycolors.basecolor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Earnings Summary',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),

              // Today's Earnings
              Row(
                children: [
                  Expanded(
                    child: _buildEarningsCard(
                      'Today',
                      '₹${todayEarnings.toStringAsFixed(0)}',
                      '$todayRides rides',
                      Icons.today,
                    ),
                  ),
                  SizedBox(width: ResponsiveSpacing.getSmallSpacing(context)),
                  Expanded(
                    child: _buildEarningsCard(
                      'Total',
                      '₹${totalEarnings.toStringAsFixed(0)}',
                      '$totalRides rides',
                      Icons.attach_money,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEarningsCard(
    String title,
    String amount,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideHistory(String driverId) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DriverService.getDriverBookingsStream(driverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Error loading ride history: ${snapshot.error}',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }

        final bookings = snapshot.data ?? [];

        if (bookings.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No ride history yet',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your completed rides will appear here',
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
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return _buildRideHistoryCard(booking);
          },
        );
      },
    );
  }

  Widget _buildRideHistoryCard(Map<String, dynamic> booking) {
    final status = booking['status'] ?? 'unknown';
    final fare = booking['fare'] ?? 0.0;
    final pickupLocation = booking['pickupLocation'] ?? 'Unknown';
    final dropoffLocation = booking['dropoffLocation'] ?? 'Unknown';
    final userName = booking['userName'] ?? 'Unknown User';
    final createdAt = booking['createdAt'];
    final completedAt = booking['completedAt'];

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = Mycolors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case 'ongoing':
        statusColor = Mycolors.basecolor;
        statusIcon = Icons.local_taxi;
        statusText = 'In Progress';
        break;
      case 'cancelled':
        statusColor = Mycolors.red;
        statusIcon = Icons.cancel;
        statusText = 'Cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'Unknown';
    }

    String formattedDate = 'Recently';
    try {
      if (completedAt != null) {
        final Timestamp timestamp = completedAt;
        final DateTime dateTime = timestamp.toDate();
        formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } else if (createdAt != null) {
        final Timestamp timestamp = createdAt;
        final DateTime dateTime = timestamp.toDate();
        formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      formattedDate = 'Recently';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Header with status and date
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                formattedDate,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Route information
          Row(
            children: [
              Icon(Icons.location_on, color: Mycolors.red, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pickupLocation,
                  style: GoogleFonts.poppins(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, color: Mycolors.green, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dropoffLocation,
                  style: GoogleFonts.poppins(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // User and fare information
          Row(
            children: [
              Icon(Icons.person, color: Colors.grey[600], size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Passenger: $userName',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
              if (fare > 0)
                Text(
                  '₹${fare.toStringAsFixed(0)}',
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
    );
  }
}
