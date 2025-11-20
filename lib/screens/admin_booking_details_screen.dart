import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminBookingDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> booking;
  final String bookingId;

  const AdminBookingDetailsScreen({
    super.key,
    required this.booking,
    required this.bookingId,
  });

  @override
  State<AdminBookingDetailsScreen> createState() => _AdminBookingDetailsScreenState();
}

class _AdminBookingDetailsScreenState extends State<AdminBookingDetailsScreen> {
  Map<String, dynamic>? _userDetails;
  Map<String, dynamic>? _driverDetails;
  bool _isLoadingUser = false;
  bool _isLoadingDriver = false;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchDriverDetails();
  }

  Future<void> _fetchUserDetails() async {
    final userId = _getField(widget.booking, ['userId', 'user_id', 'passengerId'], '');
    if (userId.isEmpty) return;

    setState(() {
      _isLoadingUser = true;
    });

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists && mounted) {
        setState(() {
          _userDetails = userDoc.data();
          _isLoadingUser = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      print('Error fetching user details: $e');
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  Future<void> _fetchDriverDetails() async {
    final driverId = widget.booking['driverId'];
    if (driverId == null || driverId.toString().isEmpty) return;

    setState(() {
      _isLoadingDriver = true;
    });

    try {
      final driverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(driverId.toString())
          .get();

      if (driverDoc.exists && mounted) {
        setState(() {
          _driverDetails = driverDoc.data();
          _isLoadingDriver = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoadingDriver = false;
        });
      }
    } catch (e) {
      print('Error fetching driver details: $e');
      if (mounted) {
        setState(() {
          _isLoadingDriver = false;
        });
      }
    }
  }

  String _getField(Map<String, dynamic> data, List<String> keys, String defaultValue) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return defaultValue;
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Not available';
    try {
      if (timestamp is Timestamp) {
        return DateFormat('MMM dd, yyyy • HH:mm').format(timestamp.toDate());
      }
      return timestamp.toString();
    } catch (e) {
      return 'Not available';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return Mycolors.green;
      case 'accepted':
      case 'ongoing':
        return Mycolors.basecolor;
      case 'cancelled':
        return Mycolors.red;
      case 'pending':
        return Mycolors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = (widget.booking['status'] ?? 'unknown').toString();
    final statusColor = _getStatusColor(status);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Booking Details',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: statusColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking ID',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          widget.bookingId.length > 20 
                              ? '${widget.bookingId.substring(0, 20)}...' 
                              : widget.bookingId,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Route Information
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Route Information',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Mycolors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Mycolors.red,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pickup Location',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _getField(widget.booking, ['pickupLocation', 'pickup', 'from'], 'Not specified'),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Mycolors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Mycolors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dropoff Location',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _getField(widget.booking, ['dropoffLocation', 'destination', 'to', 'dropoff'], 'Not specified'),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // User Information
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Information',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingUser)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    _buildInfoRow(
                      'User Name',
                      _userDetails?['name'] ?? 
                      _userDetails?['fullName'] ?? 
                      _getField(widget.booking, ['userName', 'name'], 'Not available'),
                    ),
                    _buildInfoRow(
                      'User Email',
                      _userDetails?['email'] ?? 
                      _getField(widget.booking, ['userEmail', 'email'], 'Not available'),
                    ),
                    _buildInfoRow(
                      'User Phone',
                      _userDetails?['phone'] ?? 
                      _userDetails?['phoneNumber'] ?? 
                      _getField(widget.booking, ['userPhone', 'phone', 'phoneNumber'], 'Not available'),
                    ),
                    _buildInfoRow(
                      'User ID',
                      _getField(widget.booking, ['userId', 'user_id', 'passengerId'], 'Not available'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Driver Information
            if (widget.booking['driverId'] != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Driver Information',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoadingDriver)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else ...[
                      _buildInfoRow(
                        'Driver Name',
                        _driverDetails?['name'] ?? 
                        _driverDetails?['fullName'] ?? 
                        widget.booking['driverName']?.toString() ?? 
                        'Not available',
                      ),
                      _buildInfoRow(
                        'Driver Email',
                        _driverDetails?['email'] ?? 
                        widget.booking['driverEmail']?.toString() ?? 
                        'Not available',
                      ),
                      _buildInfoRow(
                        'Driver Phone',
                        _driverDetails?['phone'] ?? 
                        _driverDetails?['phoneNumber'] ?? 
                        widget.booking['driverPhone']?.toString() ?? 
                        'Not available',
                      ),
                      if (_driverDetails?['vehicleType'] != null)
                        _buildInfoRow(
                          'Vehicle Type',
                          _driverDetails!['vehicleType'].toString(),
                        ),
                      if (_driverDetails?['vehicleNumber'] != null)
                        _buildInfoRow(
                          'Vehicle Number',
                          _driverDetails!['vehicleNumber'].toString(),
                        ),
                      _buildInfoRow(
                        'Driver ID',
                        widget.booking['driverId'].toString(),
                      ),
                    ],
                  ],
                ),
              ),
            if (widget.booking['driverId'] != null) const SizedBox(height: 24),

            // Payment Information
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
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
                        Icons.payment,
                        color: Mycolors.basecolor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Payment Information',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Fare Amount',
                    '₹${_getField(widget.booking, ['fare', 'price', 'amount', 'cost'], '0')}',
                  ),
                  _buildInfoRow(
                    'Payment Method',
                    _getField(widget.booking, ['paymentMethod', 'payment_method'], 'Not specified'),
                  ),
                  _buildInfoRow(
                    'Payment Status',
                    widget.booking['isPaid'] == true || widget.booking['paymentStatus'] == 'paid'
                        ? 'Paid'
                        : 'Pending',
                    valueColor: widget.booking['isPaid'] == true || widget.booking['paymentStatus'] == 'paid'
                        ? Mycolors.green
                        : Mycolors.orange,
                  ),
                  if (widget.booking['paidAt'] != null)
                    _buildInfoRow(
                      'Paid At',
                      _formatDate(widget.booking['paidAt']),
                    ),
                  if (widget.booking['paymentId'] != null)
                    _buildInfoRow(
                      'Payment ID',
                      widget.booking['paymentId'].toString(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Booking Timeline
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Timeline',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.booking['createdAt'] != null)
                    _buildTimelineItem(
                      'Created',
                      _formatDate(widget.booking['createdAt']),
                      Icons.add_circle,
                      Mycolors.basecolor,
                    ),
                  if (widget.booking['acceptedAt'] != null)
                    _buildTimelineItem(
                      'Accepted',
                      _formatDate(widget.booking['acceptedAt']),
                      Icons.check_circle,
                      Mycolors.green,
                    ),
                  if (widget.booking['paidAt'] != null)
                    _buildTimelineItem(
                      'Paid',
                      _formatDate(widget.booking['paidAt']),
                      Icons.payment,
                      Mycolors.green,
                    ),
                  if (widget.booking['completedAt'] != null)
                    _buildTimelineItem(
                      'Completed',
                      _formatDate(widget.booking['completedAt']),
                      Icons.done_all,
                      Mycolors.green,
                    ),
                  if (widget.booking['updatedAt'] != null)
                    _buildTimelineItem(
                      'Last Updated',
                      _formatDate(widget.booking['updatedAt']),
                      Icons.update,
                      Colors.grey,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTimelineItem(String label, String date, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
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
}

