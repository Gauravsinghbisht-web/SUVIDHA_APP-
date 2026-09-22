
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String message;
  final DateTime createdAt;

  final bool delivered;
  final bool seen;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.message,
    required this.createdAt,
    required this.delivered,
    required this.seen,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'delivered': delivered,
      'seen': seen,
    };
  }

  factory MessageModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final createdAt = map['createdAt'];

    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      message: map['message'] ?? '',
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.now(),
      delivered: map['delivered'] ?? false,
      seen: map['seen'] ?? false,
    );
  }
}