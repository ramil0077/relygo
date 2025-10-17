import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String driverId;
  final String? driverName;
  final String pickupLocation;
  final String dropoffLocation;
  final String bookingType; // 'driver_only' or 'driver_with_vehicle'
  final String status; // 'pending', 'accepted', 'rejected', 'ongoing', 'completed', 'cancelled'
  final double? fare;
  final bool isPaid;
  final String? paymentId;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? additionalDetails;

  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.driverId,
    this.driverName,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.bookingType,
    required this.status,
    this.fare,
    this.isPaid = false,
    this.paymentId,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.additionalDetails,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      driverId: map['driverId'] ?? '',
      driverName: map['driverName'],
      pickupLocation: map['pickupLocation'] ?? '',
      dropoffLocation: map['dropoffLocation'] ?? '',
      bookingType: map['bookingType'] ?? 'driver_only',
      status: map['status'] ?? 'pending',
      fare: map['fare']?.toDouble(),
      isPaid: map['isPaid'] ?? false,
      paymentId: map['paymentId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      acceptedAt: map['acceptedAt'] != null 
          ? (map['acceptedAt'] as Timestamp).toDate() 
          : null,
      completedAt: map['completedAt'] != null 
          ? (map['completedAt'] as Timestamp).toDate() 
          : null,
      additionalDetails: map['additionalDetails'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'driverId': driverId,
      'driverName': driverName,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'bookingType': bookingType,
      'status': status,
      'fare': fare,
      'isPaid': isPaid,
      'paymentId': paymentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'additionalDetails': additionalDetails,
    };
  }
}
