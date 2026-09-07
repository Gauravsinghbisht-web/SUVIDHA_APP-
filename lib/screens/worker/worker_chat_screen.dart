
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

  @override
  Widget build(BuildContext context) {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

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

      body: StreamBuilder<List<ChatModel>>(
        stream: _chatService.getWorkerChats(
          currentUser.uid,
        ),

        builder: (context, snapshot) {
          // =============================================
          // LOADING
          // =============================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // =============================================
          // ERROR
          // =============================================

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading chats:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          // =============================================
          // NO CHATS
          // =============================================

          final chats =
              snapshot.data ?? [];

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

          // =============================================
          // CHAT LIST
          // =============================================

          return ListView.separated(
            padding: const EdgeInsets.all(15),

            itemCount: chats.length,

            separatorBuilder:
                (context, index) =>
                    const SizedBox(height: 10),

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

                  leading: const CircleAvatar(
                    radius: 28,
                    child: Icon(
                      Icons.person,
                      size: 30,
                    ),
                  ),

                  title: const Text(
                    'User',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    'Service Request: ${chat.serviceRequestId}',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),

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
