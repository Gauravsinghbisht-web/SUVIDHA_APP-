import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // =====================================================
  // CREATE CHAT
  // =====================================================

  Future<String> createChat({
    required String userId,
    required String workerId,
    required String serviceRequestId,
  }) async {
    final existingChat = await _firestore
        .collection('chats')
        .where(
          'serviceRequestId',
          isEqualTo: serviceRequestId,
        )
        .limit(1)
        .get();

    if (existingChat.docs.isNotEmpty) {
      return existingChat.docs.first.id;
    }

    final chatRef =
        _firestore.collection('chats').doc();

    final chat = ChatModel(
      id: chatRef.id,
      userId: userId,
      workerId: workerId,
      serviceRequestId: serviceRequestId,
      createdAt: DateTime.now(),
    );

    await chatRef.set(
      chat.toMap(),
    );

    return chatRef.id;
  }

  // =====================================================
  // GET CHAT BY SERVICE REQUEST
  // =====================================================

  Future<ChatModel?> getChatByRequest(
    String serviceRequestId,
  ) async {
    final result = await _firestore
        .collection('chats')
        .where(
          'serviceRequestId',
          isEqualTo: serviceRequestId,
        )
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      return null;
    }

    final doc = result.docs.first;

    return ChatModel.fromMap(
      doc.id,
      doc.data(),
    );
  }

  // =====================================================
  // SEND MESSAGE
  // =====================================================

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String message,
  }) async {
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    final newMessage = MessageModel(
      id: messageRef.id,
      senderId: senderId,
      message: message.trim(),
      createdAt: DateTime.now(),
      delivered: false,
      seen: false,
    );

    await messageRef.set(
      newMessage.toMap(),
    );
  }

  // =====================================================
  // GET MESSAGES - REAL TIME
  // =====================================================

  Stream<List<MessageModel>> getMessages(
    String chatId,
  ) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy(
          'createdAt',
          descending: false,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs.map((doc) {
              return MessageModel.fromMap(
                doc.id,
                doc.data(),
              );
            }).toList();
          },
        );
  }

  // =====================================================
  // MARK MESSAGE AS DELIVERED
  // =====================================================

  Future<void> markMessageAsDelivered({
    required String chatId,
    required String messageId,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'delivered': true,
    });
  }

  // =====================================================
  // MARK MESSAGE AS SEEN
  // =====================================================

  Future<void> markMessageAsSeen({
    required String chatId,
    required String messageId,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'delivered': true,
      'seen': true,
    });
  }

  // =====================================================
  // DELETE CHAT
  // =====================================================

  Future<void> deleteChat(
    String chatId,
  ) async {
    final messagesSnapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();

    final WriteBatch batch =
        _firestore.batch();

    for (final doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    final chatRef = _firestore
        .collection('chats')
        .doc(chatId);

    batch.delete(chatRef);

    await batch.commit();
  }

  // =====================================================
  // GET USER CHATS
  // =====================================================

  Stream<List<ChatModel>> getUserChats(
    String userId,
  ) {
    return _firestore
        .collection('chats')
        .where(
          'userId',
          isEqualTo: userId,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs.map((doc) {
              return ChatModel.fromMap(
                doc.id,
                doc.data(),
              );
            }).toList();
          },
        );
  }

  // =====================================================
  // GET WORKER CHATS
  // =====================================================

  Stream<List<ChatModel>> getWorkerChats(
    String workerId,
  ) {
    return _firestore
        .collection('chats')
        .where(
          'workerId',
          isEqualTo: workerId,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs.map((doc) {
              return ChatModel.fromMap(
                doc.id,
                doc.data(),
              );
            }).toList();
          },
        );
  }
}