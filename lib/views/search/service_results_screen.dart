
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home/worker_profile/worker_profile_screen.dart';
import 'package:provider/provider.dart';
import '../../models/service_model.dart';
import '../../providers/service_provider.dart';

class ServiceResultsScreen extends StatefulWidget {
  final String serviceType;

  const ServiceResultsScreen({
    super.key,
    required this.serviceType,
  });

  @override
  State<ServiceResultsScreen> createState() =>
      _ServiceResultsScreenState();
}

class _ServiceResultsScreenState
    extends State<ServiceResultsScreen> {

  // ==========================================
  // LOAD SERVICES
  // ==========================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().searchServices(
            widget.serviceType,
          );
    });
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.serviceType} Workers',
        ),
      ),

      body: Consumer<ServiceProvider>(
        builder: (
          context,
          provider,
          child,
        ) {

          // ========================================
          // LOADING
          // ========================================

          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ========================================
          // ERROR
          // ========================================

          if (provider.errorMessage != null) {
            return _buildErrorState(
              context,
              provider.errorMessage!,
            );
          }

          // ========================================
          // NO RESULTS
          // ========================================

          if (provider.services.isEmpty) {
            return _buildEmptyState(context);
          }

          // ========================================
          // RESULTS
          // ========================================

          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // Results header

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  8,
                ),
                child: Row(
                  children: [

                    Expanded(
                      child: Text(
                        'Available Workers',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: theme
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.10),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${provider.services.length} found',
                        style: TextStyle(
                          color: theme
                              .colorScheme
                              .primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Worker list

              Expanded(
                child: ListView.builder(
                  physics:
                      const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    30,
                  ),
                  itemCount:
                      provider.services.length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final ServiceModel service =
                        provider.services[index];

                    return _serviceCard(
                      context,
                      service,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // SERVICE CARD
  // ==========================================

  Widget _serviceCard(
    BuildContext context,
    ServiceModel service,
  ) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // ==================================
            // WORKER HEADER
            // ==================================

            Row(
              children: [

                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    color: primary.withValues(
                      alpha: 0.10,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: primary,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        service.serviceType,
                        style: theme
                            .textTheme
                            .titleMedium,
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Worker ID: ${service.workerId}',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: theme
                            .textTheme
                            .bodyMedium,
                      ),
                    ],
                  ),
                ),

                // Available indicator

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green
                        .withValues(alpha: 0.10),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 7,
                        color: Colors.green,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Available',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ==================================
            // WORKER DETAILS
            // ==================================

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme
                    .scaffoldBackgroundColor,
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Column(
                children: [

                  _detailRow(
                    context,
                    icon:
                        Icons.location_on_outlined,
                    title: 'Location',
                    value: service.location,
                  ),

                  const SizedBox(height: 12),

                  _detailRow(
                    context,
                    icon: Icons.work_outline,
                    title: 'Experience',
                    value: service.experience,
                  ),

                  const SizedBox(height: 12),

                  _detailRow(
                    context,
                    icon:
                        Icons.currency_rupee,
                    title: 'Starting price',
                    value:
                        '₹${service.price}',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==================================
            // DESCRIPTION
            // ==================================

            Text(
              service.description,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),

            const SizedBox(height: 18),

            // ==================================
            // VIEW PROFILE BUTTON
            // ==================================

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WorkerProfileScreen(
                        service: service,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.person_outline,
                ),
                label: const Text(
                  'View Worker Profile',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // DETAIL ROW
  // ==========================================

  Widget _detailRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [

        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),

        const SizedBox(width: 10),

        Text(
          '$title:',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),

        const SizedBox(width: 6),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // EMPTY STATE
  // ==========================================

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: primary.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 45,
                color: primary,
              ),
            ),

            const SizedBox(height: 22),

            Text(
              'No ${widget.serviceType} workers found',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),

            const SizedBox(height: 10),

            Text(
              'Try searching for another service.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ERROR STATE
  // ==========================================

  Widget _buildErrorState(
    BuildContext context,
    String message,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            Icon(
              Icons.error_outline,
              size: 65,
              color: theme.colorScheme.error,
            ),

            const SizedBox(height: 18),

            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge,
            ),

            const SizedBox(height: 10),

            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
