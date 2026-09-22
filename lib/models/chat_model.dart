
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String userId;
  final String workerId;
  final String serviceRequestId;
  final DateTime createdAt;

  ChatModel({
    required this.id,
    required this.userId,
    required this.workerId,
    required this.serviceRequestId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'workerId': workerId,
      'serviceRequestId': serviceRequestId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ChatModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return ChatModel(
      id: id,
      userId: map['userId'] ?? '',
      workerId: map['workerId'] ?? '',
      serviceRequestId: map['serviceRequestId'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}