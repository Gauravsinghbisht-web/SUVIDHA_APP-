
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/chat_model.dart';
import '../../services/chat_service.dart';
import '../chat/chat_screen.dart';

class WorkerChatScreen extends StatelessWidget {
  WorkerChatScreen({
    super.key,
  });

  final ChatService _chatService =
      ChatService();

  // =====================================================
  // GET USER NAME
  // =====================================================

  Future<String> _getUserName(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (doc.exists) {
      final data = doc.data();

      return data?['name'] ?? 'User';
    }

    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    // =====================================================
    // WORKER NOT LOGGED IN
    // =====================================================

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Worker is not logged in.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chats',
        ),
        centerTitle: true,
      ),

      // ===================================================
      // GET WORKER CHATS - REAL TIME
      // ===================================================

      body: StreamBuilder<List<ChatModel>>(
        stream: _chatService.getWorkerChats(
          currentUser.uid,
        ),

        builder: (context, snapshot) {
          // ===============================================
          // LOADING
          // ===============================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ===============================================
          // ERROR
          // ===============================================

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading chats:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          // ===============================================
          // CHAT LIST
          // ===============================================

          final chats =
              snapshot.data ?? [];

          // ===============================================
          // NO CHATS
          // ===============================================

          if (chats.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 70,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'No chats yet.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Accepted service requests will appear here.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // ===============================================
          // DISPLAY CHATS
          // ===============================================

          return ListView.separated(
            padding: const EdgeInsets.all(15),

            itemCount: chats.length,

            separatorBuilder:
                (context, index) =>
                    const SizedBox(
              height: 10,
            ),

            itemBuilder:
                (context, index) {
              final chat = chats[index];

              return Card(
                elevation: 2,

                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),

                  // =====================================
                  // USER ICON
                  // =====================================

                  leading: const CircleAvatar(
                    radius: 28,
                    child: Icon(
                      Icons.person,
                      size: 30,
                    ),
                  ),

                  // =====================================
                  // USER NAME
                  // =====================================

                  title: FutureBuilder<String>(
                    future: _getUserName(
                      chat.userId,
                    ),

                    builder:
                        (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        );
                      }

                      return Text(
                        snapshot.data ?? 'User',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      );
                    },
                  ),

                  // =====================================
                  // SERVICE REQUEST
                  // =====================================

                  subtitle: Text(
                    'Service Request: ${chat.serviceRequestId}',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                  ),

                  // =====================================
                  // ARROW
                  // =====================================

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),

                  // =====================================
                  // OPEN CHAT
                  // =====================================

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChatScreen(
                          chat: chat,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
