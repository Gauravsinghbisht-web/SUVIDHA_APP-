
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/chat_model.dart';
import '../../services/chat_service.dart';
import '../chat/chat_screen.dart';

class UserChatScreen extends StatelessWidget {
  UserChatScreen({
    super.key,
  });

  final ChatService _chatService = ChatService();

  // =====================================================
  // GET WORKER NAME
  // =====================================================

  Future<String> _getWorkerName(String workerId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(workerId)
        .get();

    if (doc.exists) {
      final data = doc.data();

      return data?['name'] ?? 'Worker';
    }

    return 'Worker';
  }

  // =====================================================
  // CONFIRM DELETE
  // =====================================================

  Future<void> _confirmDelete(
    BuildContext context,
    ChatModel chat,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Chat?',
          ),
          content: const Text(
            'Are you sure you want to delete this chat? '
            'All messages in this conversation will be deleted.',
          ),
          actions: [
            // CANCEL
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),

            // DELETE
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    // User cancelled
    if (confirmed != true) {
      return;
    }

    try {
      // Delete chat + all messages
      await _chatService.deleteChat(
        chat.id,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Chat deleted successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete chat: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    // =====================================================
    // USER NOT LOGGED IN
    // =====================================================

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'User is not logged in.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,

      // ===================================================
      // APP BAR
      // ===================================================

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Chats',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ===================================================
      // CHAT LIST
      // ===================================================

      body: StreamBuilder<List<ChatModel>>(
        stream: _chatService.getUserChats(
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
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Unable to load chats',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // ===============================================
          // CHAT LIST
          // ===============================================

          final chats = snapshot.data ?? [];

          // ===============================================
          // NO CHATS
          // ===============================================

          if (chats.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        size: 50,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'No chats yet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Chats with workers will appear here\n'
                      'after a service request is accepted.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ===============================================
          // DISPLAY CHATS
          // ===============================================

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              25,
            ),
            itemCount: chats.length,
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 12,
              );
            },
            itemBuilder: (context, index) {
              final chat = chats[index];

              return _buildChatCard(
                context,
                chat,
              );
            },
          );
        },
      ),
    );
  }

  // =====================================================
  // CHAT CARD
  // =====================================================

  Widget _buildChatCard(
    BuildContext context,
    ChatModel chat,
  ) {
    final primaryColor =
        Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                chat: chat,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.06,
                ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // =========================================
              // WORKER AVATAR
              // =========================================

              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(
                    alpha: 0.12,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: primaryColor,
                ),
              ),

              const SizedBox(width: 15),

              // =========================================
              // WORKER INFORMATION
              // =========================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // WORKER NAME

                    FutureBuilder<String>(
                      future: _getWorkerName(
                        chat.workerId,
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
                          snapshot.data ?? 'Worker',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 6),

                    // SERVICE REQUEST

                    Row(
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 16,
                          color:
                              Colors.grey.shade600,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Service Request: '
                            '${chat.serviceRequestId}',
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // CHAT LABEL

                    Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 15,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Open conversation',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w500,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              // =========================================
              // DELETE BUTTON
              // =========================================

              IconButton(
                tooltip: 'Delete chat',
                onPressed: () {
                  _confirmDelete(
                    context,
                    chat,
                  );
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),

              // =========================================
              // ARROW
              // =========================================

              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(
                    alpha: 0.10,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
