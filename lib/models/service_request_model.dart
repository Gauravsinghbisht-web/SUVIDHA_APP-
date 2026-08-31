
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRequestModel {
  final String id;
  final String userId;
  final String workerId;
  final String serviceId;
  final String serviceType;
  final String status;
  final DateTime createdAt;

  ServiceRequestModel({
    required this.id,
    required this.userId,
    required this.workerId,
    required this.serviceId,
    required this.serviceType,
    required this.status,
    required this.createdAt,
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
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
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
    };
  }
}