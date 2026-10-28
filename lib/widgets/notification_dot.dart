
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UnreadChatDot extends StatelessWidget {
  final String userId;

  const UnreadChatDot({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: firestore.collection('chats').snapshots(),
      builder: (context, chatsSnapshot) {
        if (!chatsSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        final chatIds = chatsSnapshot.data!.docs
            .where((doc) {
              final data = doc.data();
              return data['userId'] == userId ||
                  data['workerId'] == userId;
            })
            .map((doc) => doc.id)
            .toSet();

        if (chatIds.isEmpty) {
          return const SizedBox.shrink();
        }

        return StreamBuilder<
            QuerySnapshot<Map<String, dynamic>>>(
          stream: firestore
              .collectionGroup('messages')
              .where('seen', isEqualTo: false)
              .snapshots(),
          builder: (context, messagesSnapshot) {
            if (!messagesSnapshot.hasData) {
              return const SizedBox.shrink();
            }

            final hasUnread =
                messagesSnapshot.data!.docs.any((doc) {
              final data = doc.data();
              final chatId =
                  doc.reference.parent.parent?.id;

              return chatId != null &&
                  chatIds.contains(chatId) &&
                  data['senderId'] != userId;
            });

            if (!hasUnread) {
              return const SizedBox.shrink();
            }

            return Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class PendingRequestDot extends StatelessWidget {
  final String workerId;

  const PendingRequestDot({
    super.key,
    required this.workerId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('service_requests')
          .where('workerId', isEqualTo: workerId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Positioned(
          right: 0,
          top: 0,
          child: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
