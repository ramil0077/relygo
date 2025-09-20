import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';

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

          // Rides List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildRideCard(
                  "Airport to Downtown",
                  "John Smith",
                  "2.5 km",
                  "₹180",
                  "Completed",
                  Mycolors.green,
                  "2 hours ago",
                  "4.8",
                  Icons.directions_car,
                ),
                _buildRideCard(
                  "Mall to Station",
                  "Sarah Johnson",
                  "1.8 km",
                  "₹120",
                  "Completed",
                  Mycolors.green,
                  "Yesterday",
                  "4.9",
                  Icons.directions_car,
                ),
                _buildRideCard(
                  "Hospital Pickup",
                  "Mike Wilson",
                  "3.2 km",
                  "₹200",
                  "Completed",
                  Mycolors.green,
                  "2 days ago",
                  "4.7",
                  Icons.directions_car,
                ),
                _buildRideCard(
                  "Office to Home",
                  "Emma Davis",
                  "4.1 km",
                  "₹250",
                  "Cancelled",
                  Mycolors.red,
                  "3 days ago",
                  "0.0",
                  Icons.cancel,
                ),
                _buildRideCard(
                  "Station to Airport",
                  "David Lee",
                  "5.2 km",
                  "₹300",
                  "Completed",
                  Mycolors.green,
                  "1 week ago",
                  "4.6",
                  Icons.directions_car,
                ),
                _buildRideCard(
                  "Downtown to Mall",
                  "Lisa Brown",
                  "2.8 km",
                  "₹160",
                  "Completed",
                  Mycolors.green,
                  "1 week ago",
                  "4.8",
                  Icons.directions_car,
                ),
                _buildRideCard(
                  "Grocery Store",
                  "Chris Anderson",
                  "1.5 km",
                  "₹90",
                  "Completed",
                  Mycolors.green,
                  "2 weeks ago",
                  "4.5",
                  Icons.shopping_cart,
                ),
                _buildRideCard(
                  "University",
                  "Anna Taylor",
                  "6.3 km",
                  "₹350",
                  "Completed",
                  Mycolors.green,
                  "2 weeks ago",
                  "4.9",
                  Icons.school,
                ),
              ],
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
          if (status == "Completed") ...[
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
                      _showRateDriverDialog(driverName);
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
          ],
        ],
      ),
    );
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

  void _showRateDriverDialog(String driverName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Rate Driver",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "How was your experience with $driverName?",
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(Icons.star, color: Colors.orange, size: 30);
                }),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: "Comments (Optional)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
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
                    content: const Text('Rating submitted!'),
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
}
