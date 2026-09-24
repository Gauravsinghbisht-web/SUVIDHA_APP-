

import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String userId;
  final String workerId;
  final String serviceRequestId;

  final double amount;
  final String currency;

  final String razorpayOrderId;
  final String? razorpayPaymentId;

  final String status;

  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.workerId,
    required this.serviceRequestId,
    required this.amount,
    required this.currency,
    required this.razorpayOrderId,
    this.razorpayPaymentId,
    required this.status,
    required this.createdAt,
  });

  // =====================================================
  // FIRESTORE → MODEL
  // =====================================================

  factory PaymentModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return PaymentModel(
      id: documentId,
      userId: map['userId'] ?? '',
      workerId: map['workerId'] ?? '',
      serviceRequestId: map['serviceRequestId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'INR',
      razorpayOrderId: map['razorpayOrderId'] ?? '',
      razorpayPaymentId: map['razorpayPaymentId'],
      status: map['status'] ?? 'created',
      createdAt:
          (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // =====================================================
  // MODEL → FIRESTORE
  // =====================================================

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'workerId': workerId,
      'serviceRequestId': serviceRequestId,
      'amount': amount,
      'currency': currency,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}