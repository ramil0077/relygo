import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/review_submission_screen.dart';
import 'package:relygo/services/user_service.dart';
import 'package:relygo/services/auth_service.dart';
import 'package:relygo/utils/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  String _selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text("Ride History"),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: ResponsiveUtils.getResponsiveHorizontalPadding(context),
            child: Row(
              children: [
                _buildFilterChip("All", "All"),
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 8,
                  ),
                ),
                _buildFilterChip("Today", "Today"),
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 8,
                  ),
                ),
                _buildFilterChip("This Week", "Week"),
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 8,
                  ),
                ),
                _buildFilterChip("This Month", "Month"),
              ],
            ),
          ),

          // Rides List - Firestore
          Expanded(
<<<<<<< HEAD
            child: FutureBuilder<Map<String, dynamic>?>(
              future: AuthService.getUserData(AuthService.currentUserId ?? ''),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
=======
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: UserService.getUserBookingHistoryStream(
                AuthService.currentUserId ?? '',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
                  return const Center(child: CircularProgressIndicator());
                }
                if (userSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load user data',
                      style: GoogleFonts.poppins(color: Mycolors.red),
                    ),
                  );
                }
<<<<<<< HEAD

                final userData = userSnapshot.data;
                final isDriver =
                    (userData != null &&
                    (userData['userType'] ?? '').toString().toLowerCase() ==
                        'driver');

                // Choose stream: drivers see ride_requests assigned to them,
                // users see their ride_requests history.
                final Stream<List<Map<String, dynamic>>> ridesStream = isDriver
                    ? FirebaseFirestore.instance
                          .collection('ride_requests')
                          .where(
                            'driverId',
                            isEqualTo: AuthService.currentUserId ?? '',
                          )
                          .snapshots()
                          .map(
                            (snapshot) => snapshot.docs.map((doc) {
                              final raw = doc.data();
                              Map<String, dynamic> data;
                              if (raw is Map<String, dynamic>) {
                                data = raw;
                              } else if (raw is Map) {
                                data = Map<String, dynamic>.from(raw);
                              } else {
                                data = {};
                              }
                              // Normalize field names used by UI
                              if (data['pickupLocation'] == null &&
                                  data['pickup'] != null) {
                                data['pickupLocation'] = data['pickup'];
                              }
                              if (data['dropoffLocation'] == null &&
                                  data['destination'] != null) {
                                data['dropoffLocation'] = data['destination'];
                              }
                              data['id'] = doc.id;
                              return data;
                            }).toList(),
                          )
                    : UserService.getUserBookingHistoryStream(
                        AuthService.currentUserId ?? '',
                      );

                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: ridesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Failed to load rides',
                          style: GoogleFonts.poppins(color: Mycolors.red),
                        ),
                      );
                    }
                    final rides = snapshot.data ?? [];
                    if (rides.isEmpty) {
                      return Center(
                        child: Text(
                          'No rides found',
                          style: GoogleFonts.poppins(color: Mycolors.gray),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: ResponsiveUtils.getResponsivePadding(context),
                      itemCount: rides.length,
                      itemBuilder: (context, index) {
                        final booking = rides[index];
                        final destination =
                            booking['dropoffLocation'] ?? 'Destination';
                        final driverName = booking['driverName'] ?? 'Driver';
                        final distance = booking['distance'] ?? 'N/A';
                        final price = booking['fare'] != null
                            ? '₹${booking['fare']}'
                            : '₹0';
                        final status = _statusString(booking['status']);
                        final statusColor = _statusColor(status);
                        final time = _formatDate(booking['createdAt']);
                        final rating = (booking['rating'] is num)
                            ? (booking['rating'] as num).toString()
                            : '0.0';
                        final icon = status == 'Cancelled'
                            ? Icons.cancel
                            : Icons.directions_car;
                        final bookingId = booking['id'] ?? '';
                        final driverId = booking['driverId'] ?? '';
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              mobile: 12,
                            ),
                          ),
                          child: _buildRideCard(
                            destination,
                            driverName,
                            distance,
                            price,
                            status,
                            statusColor,
                            time,
                            rating,
                            icon,
                            bookingId,
                            driverId,
                          ),
                        );
                      },
=======
                final allRides = snapshot.data ?? [];
                final rides = _getFilteredRides(allRides);

                if (rides.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey[200]),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == "All"
                              ? 'No rides found'
                              : 'No rides found for this period',
                          style: GoogleFonts.poppins(color: Mycolors.gray),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    final booking = rides[index];
                    final destination =
                        booking['destination'] ??
                        booking['dropoffLocation'] ??
                        'Destination';
                    final driverName = booking['driverName'] ?? 'Driver';
                    final distance = booking['distance'] ?? 'N/A';
                    final fare = booking['fare'];
                    final price = fare != null ? '₹$fare' : '₹0';
                    final status = _statusString(booking['status'] ?? '');
                    final statusColor = _statusColor(status);
                    final time = _formatDate(booking['createdAt']);
                    final rating = (booking['rating'] is num)
                        ? (booking['rating'] as num).toStringAsFixed(1)
                        : '0.0';
                    final icon = status == 'Cancelled'
                        ? Icons.cancel
                        : Icons.directions_car;
                    final bookingId = booking['id'] ?? '';
                    final driverId = booking['driverId'] ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: _buildRideCard(
                        destination,
                        driverName,
                        distance,
                        price,
                        status,
                        statusColor,
                        time,
                        rating,
                        icon,
                        bookingId,
                        driverId,
                      ),
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12),
          vertical: ResponsiveUtils.getResponsiveSpacing(context, mobile: 8),
        ),
        decoration: BoxDecoration(
          color: isSelected ? Mycolors.basecolor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Mycolors.basecolor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              mobile: 14,
            ),
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildRideCard(
    String destination,
    String driverName,
    String distance,
    String price,
    String status,
    Color statusColor,
    String time,
    String rating,
    IconData icon,
    String rideId,
    String driverId,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status and time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: statusColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    status,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              Text(
                time,
                style: GoogleFonts.poppins(fontSize: 12, color: Mycolors.gray),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Destination
          Text(
            destination,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Driver info
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Mycolors.basecolor.withOpacity(0.1),
                child: Text(
                  driverName[0],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Mycolors.basecolor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                driverName,
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(width: 8),
              if (rating != "0.0") ...[
                Icon(Icons.star, color: Mycolors.orange, size: 16),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Mycolors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Distance and Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.straighten, color: Mycolors.gray, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    distance,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Mycolors.gray,
                    ),
                  ),
                ],
              ),
              Text(
                price,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Mycolors.basecolor,
                ),
              ),
            ],
          ),

          // Action buttons based on status
          if (status == "Completed" || status == "Paid") ...[
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showRideDetailsDialog(
                        destination,
                        driverName,
                        distance,
                        price,
                        time,
                        rating,
                      );
                    },
                    icon: const Icon(Icons.info, size: 18),
                    label: Text(
                      "View Details",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Mycolors.basecolor,
                      side: BorderSide(color: Mycolors.basecolor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewSubmissionScreen(
                            driverId: driverId,
                            driverName: driverName,
                            rideId: rideId,
                            destination: destination,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.star, size: 18),
                    label: Text(
                      "Rate Driver",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Mycolors.orange,
                      side: BorderSide(color: Mycolors.orange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (status == "Cancelled") ...[
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showRideDetailsDialog(
                        destination,
                        driverName,
                        distance,
                        price,
                        time,
                        rating,
                      );
                    },
                    icon: const Icon(Icons.info, size: 18),
                    label: Text(
                      "View Details",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Mycolors.basecolor,
                      side: BorderSide(color: Mycolors.basecolor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showBookAgainDialog(destination);
                    },
                    icon: const Icon(Icons.repeat, size: 18),
                    label: Text(
                      "Book Again",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Mycolors.green,
                      side: BorderSide(color: Mycolors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (status == "Pending" ||
              status == "Accepted" ||
              status == "Ongoing") ...[
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showRideDetailsDialog(
                        destination,
                        driverName,
                        distance,
                        price,
                        time,
                        rating,
                      );
                    },
                    icon: const Icon(Icons.info, size: 18),
                    label: Text(
                      "View Details",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Mycolors.basecolor,
                      side: BorderSide(color: Mycolors.basecolor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ride is $status'),
                          backgroundColor: Mycolors.basecolor,
                        ),
                      );
                    },
                    icon: const Icon(Icons.timeline, size: 18),
                    label: Text(
                      "Track Ride",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Mycolors.green,
                      side: BorderSide(color: Mycolors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _statusString(dynamic raw) {
    final v = (raw ?? '').toString().toLowerCase();
    if (v == 'completed') return 'Completed';
    if (v == 'cancelled') return 'Cancelled';
    if (v == 'pending') return 'Pending';
    if (v == 'accepted') return 'Accepted';
    if (v == 'ongoing') return 'Ongoing';
    if (v == 'paid') return 'Paid';
    return 'Pending';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return Mycolors.green;
      case 'Cancelled':
        return Mycolors.red;
      case 'Pending':
        return Mycolors.orange;
      case 'Accepted':
        return Mycolors.basecolor;
      case 'Ongoing':
        return Mycolors.basecolor;
      case 'Paid':
        return Mycolors.green;
      default:
        return Mycolors.gray;
    }
  }

  String _formatDate(dynamic createdAt) {
    try {
      if (createdAt is Timestamp) {
        final dt = createdAt.toDate();
        return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
      }
      return createdAt?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  void _showRideDetailsDialog(
    String destination,
    String driverName,
    String distance,
    String price,
    String time,
    String rating,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Ride Details",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Destination: $destination", style: GoogleFonts.poppins()),
              Text("Driver: $driverName", style: GoogleFonts.poppins()),
              Text("Distance: $distance", style: GoogleFonts.poppins()),
              Text("Duration: 15 minutes", style: GoogleFonts.poppins()),
              Text("Fare: $price", style: GoogleFonts.poppins()),
              Text("Time: $time", style: GoogleFonts.poppins()),
              if (rating != "0.0")
                Text("Rating: $rating ⭐", style: GoogleFonts.poppins()),
              const SizedBox(height: 10),
              Text("Payment Method: Credit Card", style: GoogleFonts.poppins()),
              Text("Ride ID: #RIDE123456", style: GoogleFonts.poppins()),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Close",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBookAgainDialog(String destination) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Book Again",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Would you like to book a ride to $destination again?",
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Redirecting to booking...'),
                    backgroundColor: Mycolors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.green,
                foregroundColor: Colors.white,
              ),
              child: Text("Book Now", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredRides(
    List<Map<String, dynamic>> allRides,
  ) {
    if (_selectedFilter == "All") return allRides;

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    return allRides.where((ride) {
      final createdAt = ride['createdAt'];
      if (createdAt is! Timestamp) return false;
      final date = createdAt.toDate();

      if (_selectedFilter == "Today") {
        return date.isAfter(startOfToday);
      } else if (_selectedFilter == "Week") {
        return date.isAfter(now.subtract(const Duration(days: 7)));
      } else if (_selectedFilter == "Month") {
        return date.isAfter(DateTime(now.year, now.month, 1));
      }
      return true;
    }).toList();
  }
}
