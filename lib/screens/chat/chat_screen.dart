
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import '../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatScreen({
    super.key,
    required this.chat,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();

  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  bool _isSending = false;

  // =====================================================
  // CURRENT USER
  // =====================================================
  String get currentUserId {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  // =====================================================
  // SEND MESSAGE
  // =====================================================
  Future<void> _sendMessage() async {
    final message =
        _messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    if (currentUserId.isEmpty) {
      _showMessage(
        'You are not logged in.',
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await _chatService.sendMessage(
        chatId: widget.chat.id,
        senderId: currentUserId,
        message: message,
      );

      _messageController.clear();

      // Give Firestore time to update the stream
      await Future.delayed(
        const Duration(milliseconds: 100),
      );

      _scrollToBottom();
    } catch (e) {
      debugPrint(
        'Send message error: $e',
      );

      if (mounted) {
        _showMessage(
          'Unable to send message.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  // =====================================================
  // SCROLL TO BOTTOM
  // =====================================================
  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(
        milliseconds: 300,
      ),
      curve: Curves.easeOut,
    );
  }

  // =====================================================
  // MESSAGE
  // =====================================================
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // =====================================================
  // FORMAT TIME
  // =====================================================
  String _formatTime(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
            ? date.hour - 12
            : date.hour;
    final minute =
        date.minute.toString().padLeft(2, '0');
    final period =
        date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // =====================================================
  // MESSAGE BUBBLE
  // =====================================================
  Widget _messageBubble(
    MessageModel message,
  ) {
    final bool isMe =
        message.senderId == currentUserId;

    return Align(
      alignment: isMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
                  0.75,
        ),
        margin: const EdgeInsets.only(
          bottom: 10,
          left: 10,
          right: 10,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context)
                  .colorScheme
                  .primary
              : Colors.grey.shade200,
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message.message,
                style: TextStyle(
                  fontSize: 16,
                  color: isMe
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 5),

            Text(
              _formatTime(
                message.createdAt,
              ),
              style: TextStyle(
                fontSize: 10,
                color: isMe
                    ? Colors.white70
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // BUILD
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat',
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // =============================================
          // MESSAGES
          // =============================================
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getMessages(
                widget.chat.id,
              ),
              builder: (
                context,
                snapshot,
              ) {
                // =======================================
                // ERROR
                // =======================================
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Unable to load messages.\n'
                      '${snapshot.error}',
                      textAlign:
                          TextAlign.center,
                    ),
                  );
                }

                // =======================================
                // LOADING
                // =======================================
                if (snapshot.connectionState ==
                        ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final messages =
                    snapshot.data ?? [];

                // =======================================
                // NO MESSAGES
                // =======================================
                if (messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 15),
                        Text(
                          'No messages yet.',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Start the conversation.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // =======================================
                // MESSAGE LIST
                // =======================================
                WidgetsBinding.instance
                    .addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller:
                      _scrollController,
                  padding:
                      const EdgeInsets.only(
                    top: 20,
                    bottom: 20,
                  ),
                  itemCount:
                      messages.length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    return _messageBubble(
                      messages[index],
                    );
                  },
                );
              },
            ),
          ),

          // =============================================
          // MESSAGE INPUT
          // =============================================
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5,
                    color:
                        Colors.black.withValues(
                      alpha: 0.08,
                    ),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // ===================================
                  // TEXT FIELD
                  // ===================================

                  Expanded(
                    child: TextField(
                      controller:
                          _messageController,
                      textInputAction:
                          TextInputAction.send,
                      onSubmitted: (_) {
                        if (!_isSending) {
                          _sendMessage();
                        }
                      },
                      decoration:
                          InputDecoration(
                        hintText:
                            'Type a message...',
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            25,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ===================================
                  // SEND BUTTON
                  // ===================================
                  IconButton(
                    onPressed: _isSending
                        ? null
                        : _sendMessage,
                    icon: _isSending
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.send,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // DISPOSE
  // =====================================================
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}