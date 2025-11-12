import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/review_submission_screen.dart';
import 'package:relygo/services/user_service.dart';
import 'package:relygo/services/auth_service.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Ride History",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _buildFilterChip("All", "All"),
                const SizedBox(width: 10),
                _buildFilterChip("Today", "Today"),
                const SizedBox(width: 10),
                _buildFilterChip("This Week", "Week"),
                const SizedBox(width: 10),
                _buildFilterChip("This Month", "Month"),
              ],
            ),
          ),

          // Rides List - Firestore
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: UserService.getUserBookingsStream(
                AuthService.currentUserId ?? '',
              ),
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
                  padding: const EdgeInsets.all(20),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            fontSize: 14,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
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
              color: Colors.black,
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
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
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
    if (v == 'cancelled' || v == 'canceled') return 'Cancelled';
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
      if (createdAt is String) return createdAt;
      return createdAt?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  DateTime? _parseTimestamp(dynamic value) {
    try {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> _applyDateFilter(List<Map<String, dynamic>> rides, String filter) {
    if (filter == 'All') return rides;
    final now = DateTime.now();
    return rides.where((r) {
      final created = _parseTimestamp(r['createdAt']);
      if (created == null) return false;
      if (filter == 'Today') {
        return created.year == now.year && created.month == now.month && created.day == now.day;
      }
      if (filter == 'Week') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return created.isAfter(startOfWeek);
      }
      if (filter == 'Month') {
        return created.year == now.year && created.month == now.month;
      }
      return true;
    }).toList();
  }

  void _showRideDetailsDialog(String destination, String driverName, String distance, String price, String time, String rating) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Ride Details', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Destination: $destination', style: GoogleFonts.poppins()),
            Text('Driver: $driverName', style: GoogleFonts.poppins()),
            Text('Distance: $distance', style: GoogleFonts.poppins()),
            Text('Fare: $price', style: GoogleFonts.poppins()),
            Text('Time: $time', style: GoogleFonts.poppins()),
            if (rating != '0.0') Text('Rating: $rating ⭐', style: GoogleFonts.poppins()),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Close', style: GoogleFonts.poppins(color: Colors.grey)))],
      ),
    );
  }

  void _showBookAgainDialog(String destination) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Book Again', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Would you like to book a ride to $destination again?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Redirecting to booking...'), backgroundColor: Mycolors.green));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Mycolors.green, foregroundColor: Colors.white),
            child: Text('Book Now', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final bool isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Mycolors.basecolor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Mycolors.basecolor : Colors.grey.shade300),
        ),
        child: Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.black)),
      ),
    );
  }

  Widget _buildActionButtons(String status, String destination, String driverName, String distance, String price, String time, String rating, String rideId, String driverId) {
    Widget viewDetailsButton = Expanded(
      child: OutlinedButton.icon(
        onPressed: () => _showRideDetailsDialog(destination, driverName, distance, price, time, rating),
        icon: const Icon(Icons.info, size: 18),
        label: Text('View Details', style: GoogleFonts.poppins(fontSize: 14)),
        style: OutlinedButton.styleFrom(foregroundColor: Mycolors.basecolor, side: BorderSide(color: Mycolors.basecolor)),
      ),
    );

    Widget spacer = const SizedBox(width: 10);

    if (status == 'Completed' || status == 'Paid') {
      return Row(children: [
        viewDetailsButton,
        spacer,
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewSubmissionScreen(driverId: driverId, driverName: driverName, rideId: rideId, destination: destination))),
            icon: const Icon(Icons.star, size: 18),
            label: Text('Rate Driver', style: GoogleFonts.poppins(fontSize: 14)),
            style: OutlinedButton.styleFrom(foregroundColor: Mycolors.orange, side: BorderSide(color: Mycolors.orange)),
          ),
        ),
      ]);
    } else if (status == 'Cancelled') {
      return Row(children: [
        viewDetailsButton,
        spacer,
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showBookAgainDialog(destination),
            icon: const Icon(Icons.repeat, size: 18),
            label: Text('Book Again', style: GoogleFonts.poppins(fontSize: 14)),
            style: OutlinedButton.styleFrom(foregroundColor: Mycolors.green, side: BorderSide(color: Mycolors.green)),
          ),
        ),
      ]);
    } else {
      return Row(children: [
        viewDetailsButton,
        spacer,
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ride is $status'), backgroundColor: Mycolors.basecolor)),
            icon: const Icon(Icons.timeline, size: 18),
            label: Text('Track Ride', style: GoogleFonts.poppins(fontSize: 14)),
            style: OutlinedButton.styleFrom(foregroundColor: Mycolors.green, side: BorderSide(color: Mycolors.green)),
          ),
        ),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = AuthService.currentUserId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Ride History', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _buildFilterChip('All', 'All'),
                const SizedBox(width: 10),
                _buildFilterChip('Today', 'Today'),
                const SizedBox(width: 10),
                _buildFilterChip('This Week', 'Week'),
                const SizedBox(width: 10),
                _buildFilterChip('This Month', 'Month'),
              ],
            ),
          ),
          Expanded(
            child: userId == null
                ? Center(child: Text('Please sign in to view ride history', style: GoogleFonts.poppins(color: Mycolors.gray)))
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: UserService.getUserBookingHistoryStream(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Failed to load rides', style: GoogleFonts.poppins(color: Mycolors.red)));
                      }

                      final rides = snapshot.data ?? [];
                      final filtered = _applyDateFilter(rides, _selectedFilter);

                      if (filtered.isEmpty) {
                        return Center(child: Text('No rides found', style: GoogleFonts.poppins(color: Mycolors.gray)));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final booking = filtered[index];
                          final destination = booking['dropoffLocation'] ?? booking['destination'] ?? 'Destination';

                          String driverName = 'Driver';
                          if (booking['driverName'] != null && booking['driverName'].toString().trim().isNotEmpty) {
                            driverName = booking['driverName'].toString();
                          } else if (booking['driverDetails'] is Map) {
                            final det = booking['driverDetails'] as Map;
                            driverName = (det['name'] ?? det['fullName'] ?? det['driverName'])?.toString() ?? 'Driver';
                          }

                          final distance = booking['distance']?.toString() ?? 'N/A';
                          final dynamic fareValue = booking['fare'] ?? booking['price'] ?? booking['amount'];
                          final price = (fareValue != null) ? '₹${fareValue.toString()}' : '₹0';
                          final status = _statusString(booking['status']);
                          final statusColor = _statusColor(status);
                          final time = _formatDate(booking['createdAt']);
                          final rating = (booking['rating'] is num) ? (booking['rating'] as num).toString() : (booking['rating']?.toString() ?? '0.0');
                          final icon = status == 'Cancelled' ? Icons.cancel : Icons.directions_car;
                          final bookingId = booking['id'] ?? '';
                          final driverId = booking['driverId'] ?? '';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [Icon(icon, color: statusColor, size: 20), const SizedBox(width: 8), Text(status, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: statusColor))]),
                                      Text(time, style: GoogleFonts.poppins(fontSize: 12, color: Mycolors.gray)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(destination, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      CircleAvatar(radius: 16, backgroundColor: Mycolors.basecolor.withOpacity(0.1), child: Text(driverName.isNotEmpty ? driverName[0] : '-', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Mycolors.basecolor))),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text(driverName, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black))),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [Icon(Icons.straighten, color: Mycolors.gray, size: 16), const SizedBox(width: 4), Text(distance, style: GoogleFonts.poppins(fontSize: 14, color: Mycolors.gray))]),
                                      Text(price, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Mycolors.basecolor)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildActionButtons(status, destination, driverName, distance, price, time, rating, bookingId, driverId),
                                ],
                              ),
                            ),
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
}
