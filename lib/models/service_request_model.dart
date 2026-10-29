


import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRequestModel {
  final String id;
  final String userId;
  final String workerId;
  final String serviceId;
  final String serviceType;
  final String status;
  final DateTime createdAt;
  final DateTime? bookingDate;
  final String? bookingTime;
  final String? address;
  final String? problemDescription;

  // Job start information
  final String startRequestStatus;
  final DateTime? startRequestedAt;
  final DateTime? workStartedAt;

  // Rating and review information
  final int? rating;
  final String? review;
  final DateTime? reviewedAt;

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
    this.startRequestStatus = 'none',
    this.startRequestedAt,
    this.workStartedAt,
    this.rating,
    this.review,
    this.reviewedAt,
  });

  factory ServiceRequestModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    DateTime? readDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }

      if (value is DateTime) {
        return value;
      }

      return null;
    }

    return ServiceRequestModel(
      id: id,
      userId: map['userId'] ?? '',
      workerId: map['workerId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceType: map['serviceType'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: readDate(map['createdAt']) ?? DateTime.now(),
      bookingDate: readDate(map['bookingDate']),
      bookingTime: map['bookingTime'] as String?,
      address: map['address'] as String?,
      problemDescription: map['problemDescription'] as String?,

      // Job start information
      startRequestStatus: map['startRequestStatus'] ?? 'none',
      startRequestedAt: readDate(map['startRequestedAt']),
      workStartedAt: readDate(map['workStartedAt']),

      // Rating and review information
      rating: (map['rating'] as num?)?.toInt(),
      review: map['review'] as String?,
      reviewedAt: readDate(map['reviewedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'workerId': workerId,
      'serviceId': serviceId,
      'serviceType': serviceType,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'bookingDate': bookingDate != null
          ? Timestamp.fromDate(bookingDate!)
          : null,
      'bookingTime': bookingTime,
      'address': address,
      'problemDescription': problemDescription,

      // Job start information
      'startRequestStatus': startRequestStatus,
      'startRequestedAt': startRequestedAt != null
          ? Timestamp.fromDate(startRequestedAt!)
          : null,
      'workStartedAt': workStartedAt != null
          ? Timestamp.fromDate(workStartedAt!)
          : null,

      // Rating and review information
      'rating': rating,
      'review': review,
      'reviewedAt': reviewedAt != null
          ? Timestamp.fromDate(reviewedAt!)
          : null,
    };
  }

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
    String? startRequestStatus,
    DateTime? startRequestedAt,
    DateTime? workStartedAt,
    int? rating,
    String? review,
    DateTime? reviewedAt,
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
      problemDescription: problemDescription ?? this.problemDescription,

      // Job start information
      startRequestStatus: startRequestStatus ?? this.startRequestStatus,
      startRequestedAt: startRequestedAt ?? this.startRequestedAt,
      workStartedAt: workStartedAt ?? this.workStartedAt,

      // Rating and review information
      rating: rating ?? this.rating,
      review: review ?? this.review,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}
