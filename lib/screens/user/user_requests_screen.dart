
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service_request_model.dart';
import '../../providers/service_request_provider.dart';

class UserRequestsScreen extends StatefulWidget {
  const UserRequestsScreen({
    super.key,
  });

  @override
  State<UserRequestsScreen> createState() =>
      _UserRequestsScreenState();
}

class _UserRequestsScreenState
    extends State<UserRequestsScreen> {
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

    if (currentUser == null) {
      return;
    }
    await context
        .read<ServiceRequestProvider>()
        .getUserRequests(currentUser.uid);
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
      ),

      body: Consumer<ServiceRequestProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          // =============================================
          // LOADING
          // =============================================
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // =============================================
          // ERROR
          // =============================================
          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment : MainAxisAlignment.center,
                children: [ const Icon(
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
            );
          }

          // =============================================
          // NO REQUESTS
          // =============================================
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
                    child: Text('No service requests yet.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // =============================================
          // REQUEST LIST
          // =============================================

          return RefreshIndicator(
            onRefresh: _loadRequests,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
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
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ===========================================
            // SERVICE NAME
            // ===========================================

            Row(
              children: [
                CircleAvatar(
                  child: const Icon(
                    Icons.home_repair_service,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Text(
                    request.serviceType,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ===========================================
            // STATUS
            // ===========================================

            Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: statusColor
                        .withOpacity(0.12),

                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Text(
                    request.status
                        .toUpperCase(),

                    style: TextStyle(
                      color: statusColor,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ===========================================
            // REQUESTED DATE
            // ===========================================

            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: Colors.grey.shade600,
                ),

                const SizedBox(width: 8),

                Text(
                  _formatDate(
                    request.createdAt,
                  ),

                  style: TextStyle(
                    color:
                        Colors.grey.shade700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ===========================================
            // WORKER
            // ===========================================

            if (request.status == 'accepted' &&
                request.workerId.isNotEmpty)
              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(10),

                  color: Colors.green
                      .withOpacity(0.08),
                ),

                child: Row(
                  children: [
                    const Icon(
                      Icons.person,
                      color: Colors.green,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'Worker assigned\n'
                        '${request.workerId}',

                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ===========================================
            // PENDING MESSAGE
            // ===========================================

            if (request.status == 'pending')
              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(10),

                  color: Colors.orange
                      .withOpacity(0.08),
                ),

                child: const Row(
                  children: [
                    Icon(
                      Icons.hourglass_empty,
                      color: Colors.orange,
                    ),

                    SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'Waiting for a worker to accept your request.',
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