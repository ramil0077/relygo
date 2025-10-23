import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relygo/services/auth_service.dart';

class DriverRideHistoryScreen extends StatefulWidget {
  const DriverRideHistoryScreen({super.key});

  @override
  State<DriverRideHistoryScreen> createState() =>
      _DriverRideHistoryScreenState();
}

class _DriverRideHistoryScreenState extends State<DriverRideHistoryScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Ride History',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
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
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _getDriverRidesStream(),
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
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No rides found',
                      style: GoogleFonts.poppins(color: Mycolors.gray),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final pickup =
                        (data['pickup'] ?? data['pickupLocation'] ?? 'Pickup')
                            .toString();
                    final destination =
                        (data['destination'] ??
                                data['dropoffLocation'] ??
                                'Destination')
                            .toString();
                    final fare = data['fare'];
                    final price = fare is num
                        ? '₹${fare.toStringAsFixed(0)}'
                        : '';
                    final status = (data['status'] ?? '').toString();
                    final statusText = _statusString(status);
                    final statusColor = _statusColor(statusText);
                    final createdAt = data['createdAt'] as Timestamp?;
                    final time = createdAt != null
                        ? _formatDate(createdAt)
                        : '';
                    final method = (data['paymentMethod'] ?? '').toString();
                    final trailing = status == 'paid'
                        ? (method.isNotEmpty ? 'Paid • $method' : 'Paid')
                        : statusText;

                    return _buildRideTile(
                      '$pickup → $destination',
                      time,
                      trailing,
                      price,
                      statusColor,
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
    final bool isSelected = _selectedFilter == value;
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

  Widget _buildRideTile(
    String title,
    String time,
    String subtitle,
    String amount,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.directions_car, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Mycolors.gray,
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Mycolors.gray,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getDriverRidesStream() {
    final driverId = AuthService.currentUserId;
    if (driverId == null) return const Stream.empty();

    DateTime startDate;
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'All':
      default:
        startDate = DateTime(2020);
    }

    return FirebaseFirestore.instance
        .collection('ride_requests')
        .where('driverId', isEqualTo: driverId)
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  String _statusString(String raw) {
    final v = raw.toLowerCase();
    if (v == 'paid') return 'Paid';
    if (v == 'accepted') return 'Accepted';
    if (v == 'pending') return 'Pending';
    if (v == 'rejected') return 'Rejected';
    if (v == 'completed') return 'Completed';
    if (v == 'cancelled') return 'Cancelled';
    return v.isEmpty ? 'Pending' : raw;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
      case 'Completed':
        return Mycolors.green;
      case 'Accepted':
        return Mycolors.basecolor;
      case 'Pending':
        return Mycolors.orange;
      case 'Rejected':
      case 'Cancelled':
        return Mycolors.red;
      default:
        return Mycolors.gray;
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
