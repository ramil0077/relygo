import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relygo/services/auth_service.dart';
import 'package:relygo/services/ride_completion_service.dart';

class DriverNotificationsScreen extends StatefulWidget {
  const DriverNotificationsScreen({super.key});

  @override
  State<DriverNotificationsScreen> createState() =>
      _DriverNotificationsScreenState();
}

class _DriverNotificationsScreenState extends State<DriverNotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final String? driverId = AuthService.currentUserId;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: driverId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('ride_requests')
                  .where('driverId', isEqualTo: driverId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load notifications',
                      style: GoogleFonts.poppins(color: Mycolors.red),
                    ),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No notifications',
                      style: GoogleFonts.poppins(color: Mycolors.gray),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final pickup = (data['pickup'] ?? '').toString();
                    final destination = (data['destination'] ?? '').toString();
                    final status = (data['status'] ?? '').toString();
                    final fare = data['fare'];
                    final paymentMethod = (data['paymentMethod'] ?? '')
                        .toString();
                    final Timestamp? paidAtTs = data['paidAt'] as Timestamp?;
                    final String paidAt = paidAtTs != null
                        ? _formatDate(paidAtTs)
                        : '';

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '$pickup → $destination',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _buildStatusChip(status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (status == 'accepted' && (paymentMethod.isEmpty))
                            Text(
                              fare != null
                                  ? 'Fare: ₹$fare • Awaiting payment'
                                  : 'Awaiting payment',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Mycolors.gray,
                              ),
                            ),
                          if (status == 'paid')
                            Text(
                              fare != null
                                  ? 'Payment successful • ₹$fare • $paidAt'
                                  : 'Payment successful • $paidAt',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Mycolors.green,
                              ),
                            ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              if (status == 'pending') ...[
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _reject(doc.id),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Mycolors.red),
                                      foregroundColor: Mycolors.red,
                                    ),
                                    child: Text(
                                      'Reject',
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _acceptWithFare(doc.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Mycolors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text(
                                      'Accept',
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ),
                                ),
                              ],
                              if (status == 'accepted' && paymentMethod.isEmpty)
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Waiting for user payment…',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Mycolors.gray,
                                      ),
                                    ),
                                  ),
                                ),
                              if (status == 'paid')
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Paid',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Mycolors.green,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Mycolors.orange;
        break;
      case 'accepted':
        color = Mycolors.basecolor;
        break;
      case 'paid':
        color = Mycolors.green;
        break;
      case 'rejected':
        color = Mycolors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.isEmpty ? 'unknown' : status,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _acceptWithFare(String requestId) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text('Enter Estimated Fare', style: GoogleFonts.poppins()),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Fare (₹)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final num? fare = num.tryParse(controller.text.trim());
                if (fare == null) return;
                Navigator.of(context).pop();

                // Set drop time (e.g., 30 minutes from now)
                final dropTime = DateTime.now().add(
                  const Duration(minutes: 30),
                );

                await FirebaseFirestore.instance
                    .collection('ride_requests')
                    .doc(requestId)
                    .update({
                      'status': 'accepted',
                      'fare': fare,
                      'dropTime': Timestamp.fromDate(dropTime),
                      'updatedAt': FieldValue.serverTimestamp(),
                    });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.basecolor,
                foregroundColor: Colors.white,
              ),
              child: Text('Confirm', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _reject(String requestId) async {
    await FirebaseFirestore.instance
        .collection('ride_requests')
        .doc(requestId)
        .update({
          'status': 'rejected',
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  String _formatDate(Timestamp ts) {
    final dt = ts.toDate();
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
