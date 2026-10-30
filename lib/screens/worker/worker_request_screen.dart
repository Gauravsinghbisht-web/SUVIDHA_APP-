

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
  final VoidCallback onBackToHome;

  const WorkerRequestsScreen({
    super.key,
    required this.onBackToHome,
  });

  @override
  State<WorkerRequestsScreen> createState() =>
      _WorkerRequestsScreenState();
}

class _WorkerRequestsScreenState
    extends State<WorkerRequestsScreen> {
  final ChatService _chatService = ChatService();

  String? _openingChatRequestId;
  String? _requestingStartRequestId;
  String? _requestingCompletionRequestId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadRequests();
      }
    });
  }

  // =====================================================
  // LOAD WORKER REQUESTS
  // =====================================================

  Future<void> _loadRequests() async {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null || !mounted) return;

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
        final String? name = data?['name']?.toString();

        if (name != null && name.trim().isNotEmpty) {
          return name;
        }
      }

      return 'User';
    } catch (e) {
      debugPrint('Error getting user name: $e');
      return 'User';
    }
  }

  // =====================================================
  // WORKER REQUESTS TO START JOB
  // =====================================================

  Future<void> _requestStart(
    ServiceRequestModel request,
  ) async {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _showMessage('Worker is not logged in.');
      return;
    }

    if (request.workerId != currentUser.uid) {
      _showMessage(
        'You are not assigned to this service request.',
      );
      return;
    }

    if (request.status != 'accepted') {
      _showMessage(
        'Only accepted requests can be started.',
      );
      return;
    }

    if (request.startRequestStatus != 'none') {
      _showMessage(
        'A start request has already been submitted.',
      );
      return;
    }

    if (_requestingStartRequestId != null) return;

    setState(() {
      _requestingStartRequestId = request.id;
    });

    try {
      final bool success = await context
          .read<ServiceRequestProvider>()
          .requestStart(
            requestId: request.id,
            workerId: currentUser.uid,
          );

      if (!mounted) return;

      if (success) {
        _showMessage(
          'Start request sent. Waiting for user confirmation.',
        );
        await _loadRequests();
      } else {
        _showMessage(
          'Unable to request job start. Please try again.',
        );
      }
    } catch (e) {
      debugPrint('Request Start Error: $e');

      if (mounted) {
        _showMessage(
          'Unable to request job start. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _requestingStartRequestId = null;
        });
      }
    }
  }

  // =====================================================
  // WORKER REQUESTS JOB COMPLETION
  // =====================================================

  Future<void> _completeJob(
    ServiceRequestModel request,
  ) async {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _showMessage('Worker is not logged in.');
      return;
    }

    if (request.workerId != currentUser.uid) {
      _showMessage(
        'You are not assigned to this service request.',
      );
      return;
    }

    if (request.status != 'started') {
      _showMessage(
        'Only started jobs can be completed.',
      );
      return;
    }

    if (_requestingCompletionRequestId != null) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Complete Job?'),
          content: const Text(
            'Have you finished the service? '
            'The user will be asked to confirm completion '
            'before rating you.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Yes, Finished'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _requestingCompletionRequestId = request.id;
    });

    try {
      final bool success = await context
          .read<ServiceRequestProvider>()
          .requestCompletion(
            requestId: request.id,
            workerId: currentUser.uid,
          );

      if (!mounted) return;

      if (success) {
        _showMessage(
          'Completion request sent to the user.',
        );
        await _loadRequests();
      } else {
        _showMessage(
          'Unable to request completion. Please try again.',
        );
      }
    } catch (e) {
      debugPrint('Request Completion Error: $e');

      if (mounted) {
        _showMessage(
          'Unable to request completion. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _requestingCompletionRequestId = null;
        });
      }
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
      _showMessage('Worker is not logged in.');
      return;
    }

    if (request.status != 'accepted' &&
        request.status != 'started' &&
        request.status != 'completion_requested') {
      return;
    }

    if (request.userId.isEmpty) {
      _showMessage(
        'User information is not available.',
      );
      return;
    }

    if (_openingChatRequestId != null) return;

    setState(() {
      _openingChatRequestId = request.id;
    });

    try {
      await _chatService.createChat(
        userId: request.userId,
        workerId: currentUser.uid,
        serviceRequestId: request.id,
      );

      final ChatModel? chat =
          await _chatService.getChatByRequest(request.id);

      if (!mounted) return;

      if (chat == null) {
        _showMessage('Unable to open chat.');
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(chat: chat),
        ),
      );
    } catch (e) {
      debugPrint('Open Chat Error: $e');

      if (mounted) {
        _showMessage('Unable to open chat.');
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
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  // =====================================================
  // FORMAT DATE
  // =====================================================

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  // =====================================================
  // STATUS COLOR
  // =====================================================

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return const Color.fromARGB(255, 69, 193, 74);
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'completion_requested':
        return Colors.deepPurple;
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
        builder: (_) => WorkerRequestDetailsScreen(
          request: request,
        ),
      ),
    );

    if (mounted) {
      await _loadRequests();
    }
  }

  // =====================================================
  // VIEW DETAILS BUTTON
  // =====================================================

  Widget _viewDetailsButton(
    ServiceRequestModel request,
  ) {
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: () => _openRequestDetails(request),
        icon: const Icon(
          Icons.visibility_outlined,
          size: 17,
        ),
        label: const Text(
          'View Details',
          style: TextStyle(fontSize: 13),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // REQUEST START BUTTON
  // =====================================================

  Widget _requestStartButton(
    ServiceRequestModel request,
  ) {
    final bool isRequesting =
        _requestingStartRequestId == request.id;

    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton.icon(
        onPressed: isRequesting
            ? null
            : () => _requestStart(request),
        icon: isRequesting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.play_arrow),
        label: Text(
          isRequesting
              ? 'Sending Request...'
              : 'Request Start',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  // =====================================================
  // COMPLETE JOB BUTTON
  // =====================================================

  Widget _completeJobButton(
    ServiceRequestModel request,
  ) {
    final bool isCompleting =
        _requestingCompletionRequestId == request.id;

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton.icon(
        onPressed: isCompleting
            ? null
            : () => _completeJob(request),
        icon: isCompleting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle_outline),
        label: Text(
          isCompleting
              ? 'Sending Completion...'
              : 'Complete Job',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  // =====================================================
  // WORKER RATING SUMMARY
  // =====================================================

  Widget _ratingSummaryCard(
    List<ServiceRequestModel> requests,
  ) {
    final ratedRequests = requests.where((request) {
      return request.status == 'completed' &&
          request.rating != null &&
          request.rating! >= 1 &&
          request.rating! <= 5;
    }).toList();

    final int totalRatings = ratedRequests.length;

    final double averageRating = totalRatings == 0
        ? 0.0
        : ratedRequests.fold<int>(
              0,
              (total, request) => total + request.rating!,
            ) /
            totalRatings;

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.star_rate_rounded,
                  color: Colors.amber,
                  size: 30,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'My Ratings & Reviews',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (totalRatings == 0) ...[
              const Text(
                'You have not received any customer ratings yet.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < averageRating.round()
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: Colors.amber,
                              size: 23,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalRatings customer '
                          '${totalRatings == 1 ? 'rating' : 'ratings'}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =====================================================
  // CUSTOMER FEEDBACK ON A COMPLETED JOB
  // =====================================================

  Widget _customerFeedback(
    ServiceRequestModel request,
  ) {
    if (request.rating == null ||
        request.rating! < 1 ||
        request.rating! > 5) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.rate_review_outlined,
              color: Colors.grey,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'The customer has not rated this job yet.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    final int rating = request.rating!;
    final String review = request.review?.trim() ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.rate_review_outlined,
                color: Colors.amber,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Customer Feedback',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ...List.generate(
                5,
                (index) => Icon(
                  index < rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$rating/5',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.isNotEmpty
                ? review
                : 'The customer did not write a review.',
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (request.reviewedAt != null) ...[
            const SizedBox(height: 10),
            Text(
              'Reviewed on ${_formatDate(request.reviewedAt!)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ],
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
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Back to Home',
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackToHome,
        ),
        title: const Text('Service Requests'),
      ),
      body: Consumer<ServiceRequestProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

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
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadRequests,
            child: ListView.builder(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: provider.requests.length + 2,
              itemBuilder: (context, index) {
                // Ratings summary at the top.
                if (index == 0) {
                  return _ratingSummaryCard(
                    provider.requests,
                  );
                }

                // Empty requests message.
                if (provider.requests.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 35),
                    child: Column(
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 70,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No service requests available.',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pull down to refresh.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Last item is reserved for the empty state.
                if (index > provider.requests.length) {
                  return const SizedBox.shrink();
                }

                final ServiceRequestModel request =
                    provider.requests[index - 1];

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

    final bool hasRequestedStart =
        request.startRequestStatus == 'requested';

    final bool hasConfirmedStart =
        request.startRequestStatus == 'confirmed';

    final bool isOpeningChat =
        _openingChatRequestId == request.id;

    final bool canChat =
        request.status == 'accepted' ||
        request.status == 'started' ||
        request.status == 'completion_requested';

    return FutureBuilder<String>(
      future: _getUserName(request.userId),
      builder: (context, userSnapshot) {
        final String userName =
            userSnapshot.data ?? 'Loading...';

        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // USER NAME AND STATUS
                Row(
                  children: [
                    const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(20),
                        color:
                            statusColor.withOpacity(0.12),
                      ),
                      child: Text(
                        request.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // SERVICE TYPE
                Row(
                  children: [
                    const Icon(
                      Icons.home_repair_service,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Service: ${request.serviceType}',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // REQUEST TIME
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
                        '${_formatDate(request.createdAt)}',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ACCEPTED REQUEST ACTIONS
                if (isAccepted) ...[
                  Row(
                    children: [
                      _viewDetailsButton(request),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: ElevatedButton.icon(
                            onPressed: isOpeningChat
                                ? null
                                : () => _openChat(request),
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
                                    Icons.chat_bubble_outline,
                                    size: 17,
                                  ),
                            label: const Text(
                              'Chat with User',
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                            style:
                                ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize
                                      .shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // REQUEST START
                  if (!hasRequestedStart &&
                      !hasConfirmedStart)
                    _requestStartButton(request),

                  // WAITING FOR USER CONFIRMATION
                  if (hasRequestedStart)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange
                            .withOpacity(0.08),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.hourglass_top,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Start request sent. Waiting for the user to confirm.',
                            ),
                          ),
                        ],
                      ),
                    ),

                  // USER CONFIRMED START
                  if (hasConfirmedStart)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            Colors.green.withOpacity(0.08),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'The user confirmed the job start.',
                            ),
                          ),
                        ],
                      ),
                    ),
                ],

                // STARTED JOB
                if (request.status == 'started') ...[
                  _viewDetailsButton(request),
                  const SizedBox(height: 12),
                  _completeJobButton(request),
                ],

                // WAITING FOR USER TO CONFIRM COMPLETION
                if (request.status ==
                    'completion_requested')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          Colors.orange.withOpacity(0.08),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.hourglass_top,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Completion request sent. Waiting for the user to confirm.',
                          ),
                        ),
                      ],
                    ),
                  ),

                // PENDING REQUEST
                if (request.status == 'pending')
                  _viewDetailsButton(request),

                // REJECTED REQUEST
                if (request.status == 'rejected')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(10),
                      color:
                          statusColor.withOpacity(0.08),
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

                // COMPLETED JOB AND CUSTOMER RATING
                if (request.status == 'completed') ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(10),
                      color:
                          Colors.green.withOpacity(0.08),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'The job has been completed.',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // NEW: SHOW CUSTOMER STARS AND REVIEW
                  _customerFeedback(request),
                ],

                // CHAT FOR ACTIVE JOBS
                if (canChat &&
                    request.status != 'accepted') ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isOpeningChat
                          ? null
                          : () => _openChat(request),
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                      ),
                      label: const Text('Chat with User'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
