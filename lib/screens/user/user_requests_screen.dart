

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service_request_model.dart';
import '../../providers/service_request_provider.dart';
import '../../models/chat_model.dart';
import '../../services/chat_service.dart';
import '../../services/service_request_service.dart';
import '../chat/chat_screen.dart';

class UserRequestsScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const UserRequestsScreen({
    super.key,
    this.onBackToHome,
  });

  @override
  State<UserRequestsScreen> createState() =>
      _UserRequestsScreenState();
}

class _UserRequestsScreenState extends State<UserRequestsScreen> {
  final ChatService _chatService = ChatService();
  final ServiceRequestService _requestService =
      ServiceRequestService();

  String? _openingChatRequestId;
  String? _confirmingStartRequestId;
  String? _confirmingCompletionRequestId;
  String? _ratingRequestId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
    });
  }

  // =====================================================
  // LOAD USER REQUESTS
  // =====================================================

  Future<void> _loadRequests() async {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null || !mounted) return;

    await context
        .read<ServiceRequestProvider>()
        .getUserRequests(currentUser.uid);
  }

  // =====================================================
  // CONFIRM WORK START
  // =====================================================

  Future<void> _confirmStart(
    ServiceRequestModel request,
  ) async {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _showMessage('You are not logged in.');
      return;
    }

    if (request.userId != currentUser.uid) {
      _showMessage(
        'You cannot confirm this service request.',
      );
      return;
    }

    setState(() {
      _confirmingStartRequestId = request.id;
    });

    try {
      await _requestService.confirmStart(
        requestId: request.id,
        userId: currentUser.uid,
      );

      if (!mounted) return;

      _showMessage('Work start confirmed successfully!');
      await _loadRequests();
    } catch (e) {
      debugPrint('Confirm Start Error: $e');

      if (mounted) {
        _showMessage(
          'Unable to confirm start. Please refresh and try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _confirmingStartRequestId = null;
        });
      }
    }
  }

  // =====================================================
  // CONFIRM JOB COMPLETION
  // =====================================================

  Future<void> _confirmCompletion(
    ServiceRequestModel request,
  ) async {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _showMessage('You are not logged in.');
      return;
    }

    if (request.userId != currentUser.uid) {
      _showMessage(
        'You cannot confirm this service request.',
      );
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Job Completion'),
          content: const Text(
            'Has the worker finished the job successfully?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Not Yet'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Yes, Completed'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _confirmingCompletionRequestId = request.id;
    });

    try {
      await _requestService.confirmCompletion(
        requestId: request.id,
        userId: currentUser.uid,
      );

      if (!mounted) return;

      _showMessage('Job marked as completed!');
      await _loadRequests();
    } catch (e) {
      debugPrint('Confirm Completion Error: $e');

      if (mounted) {
        _showMessage(
          'Unable to confirm completion. Please refresh and try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _confirmingCompletionRequestId = null;
        });
      }
    }
  }

  // =====================================================
  // RATE WORKER
  // =====================================================

  Future<void> _rateWorker(
    ServiceRequestModel request,
  ) async {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _showMessage('Please log in first.');
      return;
    }

    if (request.userId != currentUser.uid) {
      _showMessage(
        'You cannot review this service request.',
      );
      return;
    }

    if (request.status != 'completed') {
      _showMessage('You can rate only completed jobs.');
      return;
    }

    if (request.rating != null) {
      _showMessage('You have already rated this job.');
      return;
    }

    if (_ratingRequestId != null) return;

    int selectedRating = 5;
    final TextEditingController reviewController =
        TextEditingController();

    bool submitted = false;

    try {
      final bool? result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Rate Your Worker'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'How was your service experience?',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // SELECT STARS
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final int starNumber = index + 1;

                          return IconButton(
                            tooltip: '$starNumber stars',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 38,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                selectedRating = starNumber;
                              });
                            },
                            icon: Icon(
                              starNumber <= selectedRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 32,
                            ),
                          );
                        }),
                      ),

                      Text(
                        '$selectedRating out of 5 stars',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // OPTIONAL REVIEW
                      TextField(
                        controller: reviewController,
                        maxLines: 3,
                        maxLength: 300,
                        decoration: const InputDecoration(
                          labelText: 'Write a review (optional)',
                          hintText:
                              'Tell us about your experience',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
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
                    child: const Text('Submit Rating'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (result != true || !mounted) return;

      setState(() {
        _ratingRequestId = request.id;
      });

      await _requestService.submitWorkerReview(
        requestId: request.id,
        userId: currentUser.uid,
        rating: selectedRating,
        review: reviewController.text,
      );

      submitted = true;

      if (!mounted) return;

      _showMessage('Thank you for rating your worker!');

      await _loadRequests();
    } catch (e) {
      debugPrint('Submit Rating Error: $e');

      if (mounted) {
        _showMessage(
          'Unable to submit rating: ${e.toString()}',
        );
      }
    } finally {
      reviewController.dispose();

      if (mounted) {
        setState(() {
          _ratingRequestId = null;
        });
      }
    }

    if (submitted && mounted) {
      debugPrint('Worker rating saved successfully.');
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
      _showMessage('You are not logged in.');
      return;
    }

    if (request.status != 'accepted') return;

    if (request.workerId.isEmpty) {
      _showMessage(
        'Worker information is not available.',
      );
      return;
    }

    setState(() {
      _openingChatRequestId = request.id;
    });

    try {
      await _chatService.createChat(
        userId: currentUser.uid,
        workerId: request.workerId,
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
          builder: (context) => ChatScreen(chat: chat),
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
    ScaffoldMessenger.of(context).showSnackBar(
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
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'started':
        return Colors.orange;
      case 'completion_requested':
        return Colors.deepOrange;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Back to Home',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onBackToHome != null) {
              widget.onBackToHome!();
            } else {
              Navigator.of(context).popUntil(
                (route) => route.isFirst,
              );
            }
          },
        ),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
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

          if (provider.requests.isEmpty) {
            return RefreshIndicator(
              onRefresh: _loadRequests,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 150),
                  Center(
                    child: Icon(
                      Icons.assignment_outlined,
                      size: 70,
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'No service requests yet.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Pull down to refresh.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadRequests,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.requests.length,
              itemBuilder: (context, index) {
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

  Widget _requestCard(ServiceRequestModel request) {
    final Color statusColor = _statusColor(request.status);

    final bool isAccepted = request.status == 'accepted';

    final bool isOpeningChat =
        _openingChatRequestId == request.id;

    final bool isConfirmingStart =
        _confirmingStartRequestId == request.id;

    final bool isConfirmingCompletion =
        _confirmingCompletionRequestId == request.id;

    final bool isSubmittingRating =
        _ratingRequestId == request.id;

    final bool hasPendingStartConfirmation =
        isAccepted &&
        request.startRequestStatus == 'requested';

    final bool hasConfirmedStart =
        request.startRequestStatus == 'confirmed' &&
        request.workStartedAt != null;

    final bool hasCompletionRequest =
        request.status == 'completion_requested';

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SERVICE NAME
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.home_repair_service),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    request.serviceType,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // STATUS
            Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      request.status
                          .replaceAll('_', ' ')
                          .toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // REQUESTED DATE
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Requested: ${_formatDate(request.createdAt)}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),

            // ACCEPTED WORKER
            if (isAccepted && request.workerId.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green.withValues(alpha: 0.08),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Worker assigned\n${request.workerId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // PENDING REQUEST
            if (request.status == 'pending') ...[
              const SizedBox(height: 12),
              _infoMessage(
                icon: Icons.hourglass_empty,
                color: Colors.orange,
                message:
                    'Waiting for a worker to accept your request.',
              ),
            ],

            // WORKER REQUESTED START
            if (hasPendingStartConfirmation) ...[
              const SizedBox(height: 15),
              _infoMessage(
                icon: Icons.play_circle_outline,
                color: Colors.orange,
                message:
                    'The worker has requested to start this job. '
                    'Please confirm when the work is ready to begin.',
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isConfirmingStart
                      ? null
                      : () => _confirmStart(request),
                  icon: isConfirmingStart
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
                    isConfirmingStart
                        ? 'Confirming...'
                        : 'Confirm Start',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],

            // WAITING FOR START REQUEST
            if (isAccepted &&
                request.startRequestStatus == 'none') ...[
              const SizedBox(height: 12),
              _infoMessage(
                icon: Icons.hourglass_empty,
                color: Colors.grey,
                message:
                    'Waiting for the worker to request a start.',
              ),
            ],

            // WORK STARTED
            if (hasConfirmedStart) ...[
              const SizedBox(height: 12),
              _infoMessage(
                icon: Icons.play_circle_fill,
                color: Colors.green,
                message:
                    'Work started at '
                    '${_formatDate(request.workStartedAt!)}',
              ),
            ],

            // WORKER REQUESTED COMPLETION
            if (hasCompletionRequest) ...[
              const SizedBox(height: 15),
              _infoMessage(
                icon: Icons.task_alt,
                color: Colors.deepOrange,
                message:
                    'The worker has requested job completion. '
                    'Please confirm only if the work is finished.',
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isConfirmingCompletion
                      ? null
                      : () => _confirmCompletion(request),
                  icon: isConfirmingCompletion
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
                    isConfirmingCompletion
                        ? 'Confirming...'
                        : 'Confirm Job Completion',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],

            // JOB COMPLETED
            if (request.status == 'completed') ...[
              const SizedBox(height: 12),
              _infoMessage(
                icon: Icons.check_circle,
                color: Colors.blue,
                message: 'You confirmed that this job is completed.',
              ),

              const SizedBox(height: 12),

              // RATING BUTTON OR SAVED REVIEW
              if (request.rating == null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isSubmittingRating
                        ? null
                        : () => _rateWorker(request),
                    icon: isSubmittingRating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.star),
                    label: Text(
                      isSubmittingRating
                          ? 'Submitting Rating...'
                          : 'Rate Worker',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Thank you for your review!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < (request.rating ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber.shade800,
                              size: 24,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            '${request.rating}/5',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if ((request.review ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Your review: ${request.review}',
                        ),
                      ],
                    ],
                  ),
                ),
            ],

            // CHAT BUTTON
            if (isAccepted) ...[
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: isOpeningChat
                        ? null
                        : () => _openChat(request),
                    icon: isOpeningChat
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.chat_bubble_outline,
                            size: 19,
                          ),
                    label: const Text('Chat'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =====================================================
  // INFO MESSAGE WIDGET
  // =====================================================

  Widget _infoMessage({
    required IconData icon,
    required Color color,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.08),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
