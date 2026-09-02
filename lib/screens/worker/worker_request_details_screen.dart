
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/service_request_provider.dart';
import 'package:provider/provider.dart';
import '../../models/service_request_model.dart';
import '../../providers/service_request_provider.dart';

class WorkerRequestDetailsScreen extends StatefulWidget {
  final ServiceRequestModel request;

  const WorkerRequestDetailsScreen({
    super.key,
    required this.request,
  });

  @override
  State<WorkerRequestDetailsScreen> createState() =>
      _WorkerRequestDetailsScreenState();
}

class _WorkerRequestDetailsScreenState
    extends State<WorkerRequestDetailsScreen> {

  bool _isProcessing = false;

  // =====================================================
  // ACCEPT REQUEST
  // =====================================================

  Future<void> _acceptRequest() async {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _showMessage(
        'Worker is not logged in.',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final bool success =
        await context
            .read<ServiceRequestProvider>()
            .acceptRequest(
              requestId: widget.request.id,
              workerId: currentUser.uid,
            );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      _showMessage(
        'Request accepted successfully.',
      );

      // Go back to Requests screen.
      Navigator.pop(context, true);
    } else {
      _showMessage(
        'Unable to accept request.',
      );
    }
  }

  // =====================================================
  // REJECT REQUEST
  // =====================================================

  Future<void> _rejectRequest() async {
    setState(() {
      _isProcessing = true;
    });

    final bool success =
        await context
            .read<ServiceRequestProvider>()
            .rejectRequest(
              widget.request.id,
            );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      _showMessage(
        'Request rejected.',
      );

      Navigator.pop(context, true);
    } else {
      _showMessage(
        'Unable to reject request.',
      );
    }
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
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final request = widget.request;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request Details',
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // =============================================
            // SERVICE ICON
            // =============================================

            Center(
              child: CircleAvatar(
                radius: 45,

                child: const Icon(
                  Icons.home_repair_service,
                  size: 45,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =============================================
            // SERVICE TYPE
            // =============================================

            Center(
              child: Text(
                request.serviceType,

                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =============================================
            // STATUS
            // =============================================

            _detailCard(
              title: 'Request Status',
              value: request.status
                  .toUpperCase(),
              icon: Icons.info_outline,
            ),

            const SizedBox(height: 15),

            // =============================================
            // SERVICE ID
            // =============================================

            _detailCard(
              title: 'Service ID',
              value: request.serviceId,
              icon: Icons.build_outlined,
            ),

            const SizedBox(height: 15),

            // =============================================
            // CUSTOMER ID
            // =============================================

            _detailCard(
              title: 'Customer ID',
              value: request.userId,
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 15),

            // =============================================
            // REQUESTED DATE
            // =============================================

            _detailCard(
              title: 'Requested On',
              value: _formatDate(
                request.createdAt,
              ),
              icon: Icons.access_time,
            ),

            const SizedBox(height: 30),

            // =============================================
            // ACTION BUTTONS
            // =============================================

            if (request.status == 'pending')
              Row(
                children: [

                  // =======================================
                  // REJECT
                  // =======================================

                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isProcessing
                              ? null
                              : _rejectRequest,

                      style:
                          OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),

                      child: const Text(
                        'Reject',
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  // =======================================
                  // ACCEPT
                  // =======================================

                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _isProcessing
                              ? null
                              : _acceptRequest,

                      style:
                          ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),

                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Accept',
                            ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // DETAIL CARD
  // =====================================================

  Widget _detailCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 1,

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [

            Icon(
              icon,
              size: 28,
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    title,

                    style: TextStyle(
                      fontSize: 13,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    value,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

