
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/service_request_provider.dart';
import 'package:flutter_application_1/screens/worker/worker_request_details_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/service_request_provider.dart';

class WorkerRequestsScreen extends StatefulWidget {
  const WorkerRequestsScreen({
    super.key,
  });

  @override
  State<WorkerRequestsScreen> createState() =>
      _WorkerRequestsScreenState();
}

class _WorkerRequestsScreenState
    extends State<WorkerRequestsScreen> {
  @override
  void initState() {
    super.initState();

    // Load pending requests after the screen is created.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
    });
  }

  // =====================================================
  // LOAD REQUESTS
  // =====================================================
  Future<void> _loadRequests() async {
    await context
        .read<ServiceRequestProvider>()
        .getPendingRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Requests'),
        centerTitle: true,
      ),

      body: Consumer<ServiceRequestProvider>(
        builder: (context, provider, child) {

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
                      child: const Text('Try Again'),
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
                        fontWeight: FontWeight.w500,
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
              padding: const EdgeInsets.all(16),
              itemCount: provider.requests.length,
              itemBuilder: (context, index) {
                final request =
                    provider.requests[index];
                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 15,
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        
                        // ===================================
                        // SERVICE TYPE
                        // ===================================
                        Row(
                          children: [
                            const CircleAvatar(
                              child: Icon(
                                Icons.home_repair_service,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                request.serviceType,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),

                            // STATUS
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),

                              decoration:
                                  BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(
                                  20,
                                ),

                                color: Colors.orange
                                    .withValues(
                                  alpha: 0.15,
                                ),
                              ),

                              child: Text(
                                request.status
                                    .toUpperCase(),

                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // ===================================
                        // SERVICE ID
                        // ===================================
                        Row(
                          children: [
                            const Icon(
                              Icons.build_outlined,
                              size: 20,
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Text(
                                'Service ID: '
                                '${request.serviceId}',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // ===================================
                        // REQUEST TIME
                        // ===================================

                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 20,
                            ),

                            const SizedBox(width: 8),

                            Text(
                              'Requested: '
                              '${_formatDate(
                                request.createdAt,
                              )}',
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ===================================
                        // VIEW DETAILS BUTTON
                        // ===================================
                     
                SizedBox(
                 width: double.infinity,
                child: ElevatedButton(
                onPressed: () async {
                final result = await Navigator.push(
                 context,
                 MaterialPageRoute(
                 builder: (_) =>
                 WorkerRequestDetailsScreen(
                 request: request,
                 ),
                 ),
                  );

      // Refresh requests after returning
      // from details screen.
      if (result == true) {
        _loadRequests();
      }
    },
    child: const Text(
      'View Details',
    ),
  ),
),


                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
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

    final year = date.year.toString();

    final hour =
        date.hour.toString().padLeft(2, '0');

    final minute =
        date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}

