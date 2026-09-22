
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRequestModel {
  final String id;
  final String userId;
  final String workerId;
  final String serviceId;
  final String serviceType;
  final String status;
  final DateTime createdAt;

  // Booking fields
  final DateTime? bookingDate;
  final String? bookingTime;
  final String? address;
  final String? problemDescription;

  ServiceRequestModel({
    required this.id,
    required this.userId,
    required this.workerId,
    required this.serviceId,
    required this.serviceType,
    required this.status,
    required this.createdAt,
    this.bookingDate,
    this.bookingTime,
    this.address,
    this.problemDescription,
  });

  // =====================================================
  // FROM FIRESTORE
  // =====================================================

  factory ServiceRequestModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return ServiceRequestModel(
      id: id,
      userId: map['userId'] ?? '',
      workerId: map['workerId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceType: map['serviceType'] ?? '',
      status: map['status'] ?? 'pending',

      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),

      bookingDate: map['bookingDate'] is Timestamp
          ? (map['bookingDate'] as Timestamp).toDate()
          : null,

      bookingTime: map['bookingTime'] as String?,
      address: map['address'] as String?,
      problemDescription: map['problemDescription'] as String?,
    );
  }

  // =====================================================
  // TO FIRESTORE
  // =====================================================

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'workerId': workerId,
      'serviceId': serviceId,
      'serviceType': serviceType,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),

      // Booking fields
      'bookingDate': bookingDate != null
          ? Timestamp.fromDate(bookingDate!)
          : null,

      'bookingTime': bookingTime,
      'address': address,
      'problemDescription': problemDescription,
    };
  }

  // =====================================================
  // COPY WITH
  // =====================================================

  ServiceRequestModel copyWith({
    String? id,
    String? userId,
    String? workerId,
    String? serviceId,
    String? serviceType,
    String? status,
    DateTime? createdAt,
    DateTime? bookingDate,
    String? bookingTime,
    String? address,
    String? problemDescription,
  }) {
    return ServiceRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workerId: workerId ?? this.workerId,
      serviceId: serviceId ?? this.serviceId,
      serviceType: serviceType ?? this.serviceType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,

      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
      address: address ?? this.address,
      problemDescription:
          problemDescription ?? this.problemDescription,
    );
  }
}
