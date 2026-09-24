
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/service_request_provider.dart';
import 'package:flutter_application_1/screens/worker/worker_request_details_screen.dart';
import 'package:flutter_application_1/models/service_request_model.dart';
import 'package:flutter_application_1/models/chat_model.dart';
import 'package:flutter_application_1/services/chat_service.dart';
import 'package:flutter_application_1/screens/chat/chat_screen.dart';
import 'package:provider/provider.dart';

class WorkerRequestsScreen extends StatefulWidget {
  const WorkerRequestsScreen({super.key});

  @override
  State<WorkerRequestsScreen> createState() =>
      _WorkerRequestsScreenState();
}

class _WorkerRequestsScreenState
    extends State<WorkerRequestsScreen> {

  // =====================================================
  // CHAT SERVICE
  // =====================================================

  final ChatService _chatService = ChatService();

  // =====================================================
  // CHAT LOADING
  // =====================================================

  String? _openingChatRequestId;

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
    });
  }

  // =====================================================
  // LOAD WORKER REQUESTS
  // =====================================================

  Future<void> _loadRequests() async {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    await context
        .read<ServiceRequestProvider>()
        .getWorkerRequests(currentUser.uid);
  }

  // =====================================================
  // GET USER NAME
  // =====================================================

  Future<String> _getUserName(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();

        final String? name =
            data?['name']?.toString();

        if (name != null && name.trim().isNotEmpty) {
          return name;
        }
      }

      return 'User';
    } catch (e) {
      debugPrint(
        'Error getting user name: $e',
      );

      return 'User';
    }
  }

  // =====================================================
  // OPEN CHAT
  // =====================================================

  Future<void> _openChat(
    ServiceRequestModel request,
  ) async {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _showMessage(
        'Worker is not logged in.',
      );
      return;
    }

    // Only accepted requests can open chat
    if (request.status != 'accepted') {
      return;
    }

    if (request.userId.isEmpty) {
      _showMessage(
        'User information is not available.',
      );
      return;
    }

    setState(() {
      _openingChatRequestId = request.id;
    });

    try {
      // -------------------------------------------------
      // CREATE CHAT IF IT DOES NOT EXIST
      // -------------------------------------------------

      await _chatService.createChat(
        userId: request.userId,
        workerId: currentUser.uid,
        serviceRequestId: request.id,
      );

      // -------------------------------------------------
      // GET COMPLETE CHAT
      // -------------------------------------------------

      final ChatModel? chat =
          await _chatService.getChatByRequest(
        request.id,
      );

      if (!mounted) {
        return;
      }

      if (chat == null) {
        _showMessage(
          'Unable to open chat.',
        );
        return;
      }

      // -------------------------------------------------
      // OPEN CHAT SCREEN
      // -------------------------------------------------

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chat: chat,
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'Open Chat Error: $e',
      );

      if (mounted) {
        _showMessage(
          'Unable to open chat.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _openingChatRequestId = null;
        });
      }
    }
  }

  // =====================================================
  // SHOW MESSAGE
  // =====================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // =====================================================
  // FORMAT DATE
  // =====================================================

  String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    final year =
        date.year.toString();

    final hour =
        date.hour.toString().padLeft(2, '0');

    final minute =
        date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  // =====================================================
  // STATUS COLOR
  // =====================================================

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;

      case 'rejected':
        return Colors.red;

      case 'completed':
        return Colors.blue;

      case 'started':
        return Colors.orange;

      case 'pending':
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  // =====================================================
  // OPEN REQUEST DETAILS
  // =====================================================

  Future<void> _openRequestDetails(
    ServiceRequestModel request,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            WorkerRequestDetailsScreen(
          request: request,
        ),
      ),
    );

    // Refresh when coming back
    await _loadRequests();
  }

  // =====================================================
  // SMALL VIEW DETAILS BUTTON
  // =====================================================

  Widget _viewDetailsButton(
    ServiceRequestModel request,
  ) {
    return SizedBox(
      height: 36,

      child: ElevatedButton.icon(
        onPressed: () {
          _openRequestDetails(request);
        },

        icon: const Icon(
          Icons.visibility_outlined,
          size: 17,
        ),

        label: const Text(
          'View Details',
          style: TextStyle(
            fontSize: 13,
          ),
        ),

        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),

          minimumSize: Size.zero,

          tapTargetSize:
              MaterialTapTargetSize.shrinkWrap,

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(8),
          ),
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
          'Service Requests',
        ),
        centerTitle: true,
      ),

      body: Consumer<ServiceRequestProvider>(
        builder: (
          context,
          provider,
          child,
        ) {

          // =================================================
          // LOADING
          // =================================================

          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // =================================================
          // ERROR
          // =================================================

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    const Icon(
                      Icons.error_outline,
                      size: 60,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 15),

                    ElevatedButton(
                      onPressed: _loadRequests,
                      child: const Text(
                        'Try Again',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // =================================================
          // NO REQUESTS
          // =================================================

          if (provider.requests.isEmpty) {
            return RefreshIndicator(
              onRefresh: _loadRequests,

              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                children: const [

                  SizedBox(height: 150),

                  Icon(
                    Icons.assignment_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 20),

                  Center(
                    child: Text(
                      'No service requests available.',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  Center(
                    child: Text(
                      'Pull down to refresh.',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // =================================================
          // REQUEST LIST
          // =================================================

          return RefreshIndicator(
            onRefresh: _loadRequests,

            child: ListView.builder(
              padding:
                  const EdgeInsets.all(16),

              itemCount:
                  provider.requests.length,

              itemBuilder: (
                context,
                index,
              ) {
                final ServiceRequestModel request =
                    provider.requests[index];

                return _requestCard(request);
              },
            ),
          );
        },
      ),
    );
  }

  // =====================================================
  // REQUEST CARD
  // =====================================================

  Widget _requestCard(
    ServiceRequestModel request,
  ) {
    final Color statusColor =
        _statusColor(request.status);

    final bool isAccepted =
        request.status == 'accepted';

    final bool isOpeningChat =
        _openingChatRequestId == request.id;

    return FutureBuilder<String>(
      future: _getUserName(request.userId),

      builder: (
        context,
        userSnapshot,
      ) {
        final String userName =
            userSnapshot.data ?? 'Loading...';

        return Card(
          margin: const EdgeInsets.only(
            bottom: 15,
          ),

          elevation: 2,

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(15),
          ),

          child: Padding(
            padding:
                const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // =========================================
                // USER NAME + STATUS
                // =========================================

                Row(
                  children: [

                    const CircleAvatar(
                      child: Icon(
                        Icons.person,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        userName,

                        style:
                            const TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),

                      decoration:
                          BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(20),

                        color: statusColor
                            .withOpacity(0.12),
                      ),

                      child: Text(
                        request.status
                            .toUpperCase(),

                        style: TextStyle(
                          color:
                              statusColor,

                          fontSize: 12,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // =========================================
                // SERVICE TYPE
                // =========================================

                Row(
                  children: [

                    const Icon(
                      Icons.home_repair_service,
                      size: 20,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        'Service: '
                        '${request.serviceType}',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // =========================================
                // REQUEST TIME
                // =========================================

                Row(
                  children: [

                    const Icon(
                      Icons.access_time,
                      size: 20,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        'Requested: '
                        '${_formatDate(
                          request.createdAt,
                        )}',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // =========================================
                // ACCEPTED
                // =========================================

                if (isAccepted) ...[

                  // ---------------------------------------
                  // SMALL VIEW DETAILS
                  // ---------------------------------------

                  Row(
                    children: [

                      _viewDetailsButton(
                        request,
                      ),

                      const SizedBox(width: 10),

                      // -----------------------------------
                      // CHAT WITH USER
                      // -----------------------------------

                      Expanded(
                        child: SizedBox(
                          height: 36,

                          child:
                              ElevatedButton.icon(
                            onPressed:
                                isOpeningChat
                                    ? null
                                    : () {
                                        _openChat(
                                          request,
                                        );
                                      },

                            icon: isOpeningChat
                                ? const SizedBox(
                                    width: 17,
                                    height: 17,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons
                                        .chat_bubble_outline,
                                    size: 17,
                                  ),

                            label: const Text(
                              'Chat with User',
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),

                            style:
                                ElevatedButton
                                    .styleFrom(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 10,
                              ),

                              minimumSize:
                                  Size.zero,

                              tapTargetSize:
                                  MaterialTapTargetSize
                                      .shrinkWrap,

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // =========================================
                // PENDING
                // =========================================

                if (!isAccepted &&
                    request.status == 'pending')
                  _viewDetailsButton(
                    request,
                  ),

                // =========================================
                // REJECTED / COMPLETED / STARTED
                // =========================================

                if (!isAccepted &&
                    request.status != 'pending')
                  Container(
                    width: double.infinity,

                    padding:
                        const EdgeInsets.all(12),

                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(10),

                      color: statusColor
                          .withOpacity(0.08),
                    ),

                    child: Row(
                      children: [

                        Icon(
                          Icons.info_outline,
                          color: statusColor,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            'Request status: '
                            '${request.status.toUpperCase()}',
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
