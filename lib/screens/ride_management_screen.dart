import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relygo/services/auth_service.dart';

class RideManagementScreen extends StatefulWidget {
  const RideManagementScreen({super.key});

  @override
  State<RideManagementScreen> createState() => _RideManagementScreenState();
}

class _RideManagementScreenState extends State<RideManagementScreen> {
  String _selectedFilter = "All";
  Stream<QuerySnapshot<Map<String, dynamic>>> _requestsStream() {
    final driverId = AuthService.currentUserId;
    return FirebaseFirestore.instance
        .collection('ride_requests')
        .where('driverId', isEqualTo: driverId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Ride Management",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
            ),

            // Rides List (realtime requests for this driver)
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _requestsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Failed to load requests'));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No ride requests yet',
                        style: GoogleFonts.poppins(color: Mycolors.gray),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final d = docs[index].data();
                      final destination = (d['destination'] ?? '').toString();
                      final passengerName = (d['userName'] ?? '').toString();
                      final price = (d['price'] != null)
                          ? '₹${d['price']}'
                          : '';
                      final status = (d['status'] ?? 'pending').toString();
                      final statusColor = status == 'pending'
                          ? Mycolors.orange
                          : (status == 'accepted'
                                ? Mycolors.green
                                : Mycolors.red);
                      final createdAt = d['createdAt'] is Timestamp
                          ? (d['createdAt'] as Timestamp).toDate()
                          : null;
                      final time = createdAt != null
                          ? '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}'
                          : '';
                      return _buildRideCard(
                        destination.isEmpty ? 'Ride Request' : destination,
                        passengerName.isEmpty ? 'User' : passengerName,
                        '',
                        price,
                        status,
                        statusColor,
                        time,
                        Icons.directions_car,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
    String passengerName,
    String distance,
    String price,
    String status,
    Color statusColor,
    String time,
    IconData statusIcon,
  ) {
    return Container(
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
          // Header with status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 20),
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

          // Passenger info
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Mycolors.basecolor.withOpacity(0.1),
                child: Text(
                  passengerName[0],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Mycolors.basecolor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                passengerName,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
              ),
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
          if (status == "In Progress") ...[
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showRideCompleteDialog();
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(
                      "Complete Ride",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Mycolors.green,
                      foregroundColor: Colors.white,
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
                      _showCancelRideDialog();
                    },
                    icon: const Icon(Icons.cancel, size: 18),
                    label: Text(
                      "Cancel",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Mycolors.red,
                      side: BorderSide(color: Mycolors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (status == "Scheduled") ...[
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showStartRideDialog();
                    },
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: Text(
                      "Start Ride",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Mycolors.basecolor,
                      foregroundColor: Colors.white,
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
                      _showContactPassengerDialog();
                    },
                    icon: const Icon(Icons.phone, size: 18),
                    label: Text(
                      "Contact",
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
              ],
            ),
          ] else if (status == "Completed") ...[
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showRideDetailsDialog();
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
                      _showRatePassengerDialog();
                    },
                    icon: const Icon(Icons.star, size: 18),
                    label: Text(
                      "Rate",
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
          ],
        ],
      ),
    );
  }

  void _showRideCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Complete Ride",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to mark this ride as completed?",
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
                    content: Text('Ride completed successfully!'),
                    backgroundColor: Mycolors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.green,
                foregroundColor: Colors.white,
              ),
              child: Text("Complete", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showCancelRideDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Cancel Ride",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to cancel this ride?",
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("No", style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ride cancelled'),
                    backgroundColor: Mycolors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.red,
                foregroundColor: Colors.white,
              ),
              child: Text("Yes", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showStartRideDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Start Ride",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you ready to start this ride?",
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
                    content: Text('Ride started!'),
                    backgroundColor: Mycolors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.basecolor,
                foregroundColor: Colors.white,
              ),
              child: Text("Start", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showContactPassengerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Contact Passenger",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Choose contact method:", style: GoogleFonts.poppins()),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Calling passenger...'),
                            backgroundColor: Mycolors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: Text("Call", style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Mycolors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opening chat...'),
                            backgroundColor: Mycolors.basecolor,
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat),
                      label: Text("Chat", style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Mycolors.basecolor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
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

  void _showRideDetailsDialog() {
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
              Text(
                "Destination: Airport to Downtown",
                style: GoogleFonts.poppins(),
              ),
              Text("Passenger: Sarah Johnson", style: GoogleFonts.poppins()),
              Text("Distance: 2.5 km", style: GoogleFonts.poppins()),
              Text("Duration: 15 minutes", style: GoogleFonts.poppins()),
              Text("Fare: ₹180", style: GoogleFonts.poppins()),
              Text("Rating: 5.0 ⭐", style: GoogleFonts.poppins()),
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

  void _showRatePassengerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Rate Passenger",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "How was your experience with this passenger?",
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(Icons.star, color: Colors.orange, size: 30);
                }),
              ),
            ],
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
                    content: Text('Rating submitted!'),
                    backgroundColor: Mycolors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.basecolor,
                foregroundColor: Colors.white,
              ),
              child: Text("Submit", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }
}
