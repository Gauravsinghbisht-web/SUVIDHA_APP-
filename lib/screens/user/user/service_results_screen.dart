
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/service_model.dart';
import '../../../providers/service_provider.dart';
import '../../../home/worker_profile/worker_profile_screen.dart';

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

  // =====================================================
  // LOAD SERVICES
  // =====================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ServiceProvider>()
          .searchServices(widget.serviceType);
    });
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ===================================================
      // APP BAR
      // ===================================================

      appBar: AppBar(
        title: Text(
          '${widget.serviceType} Workers',
        ),
        centerTitle: true,
      ),

      // ===================================================
      // BODY
      // ===================================================

      body: Consumer<ServiceProvider>(
        builder: (
          context,
          provider,
          child,
        ) {

          // ===============================================
          // LOADING
          // ===============================================

          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ===============================================
          // ERROR
          // ===============================================

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }

          // ===============================================
          // NO RESULTS
          // ===============================================

          if (provider.services.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [

                    const Icon(
                      Icons.search_off,
                      size: 70,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'No ${widget.serviceType} workers found.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Try searching for another service.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ===============================================
          // RESULTS
          // ===============================================

          return ListView.builder(
            padding: const EdgeInsets.all(20),

            itemCount: provider.services.length,

            itemBuilder: (
              context,
              index,
            ) {

              final ServiceModel service =
                  provider.services[index];

              return _serviceCard(service);
            },
          );
        },
      ),
    );
  }

  // =====================================================
  // SERVICE CARD
  // =====================================================

  Widget _serviceCard(
    ServiceModel service,
  ) {
    return Card(
      elevation: 2,

      margin: const EdgeInsets.only(
        bottom: 15,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // =============================================
            // WORKER ICON + SERVICE
            // =============================================

            Row(
              children: [

                CircleAvatar(
                  radius: 28,
                  child: const Icon(
                    Icons.person,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        service.serviceType,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Worker ID: ${service.workerId}',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // =============================================
            // LOCATION
            // =============================================

            Row(
              children: [

                const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    service.location,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // =============================================
            // EXPERIENCE
            // =============================================

            Row(
              children: [

                const Icon(
                  Icons.work_outline,
                  size: 20,
                ),

                const SizedBox(width: 8),

                Text(
                  service.experience,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // =============================================
            // PRICE
            // =============================================

            Row(
              children: [

                const Icon(
                  Icons.currency_rupee,
                  size: 20,
                ),

                const SizedBox(width: 8),

                Text(
                  '₹${service.price}',
                ),
              ],
            ),

            const SizedBox(height: 15),

            // =============================================
            // DESCRIPTION
            // =============================================

            Text(
              service.description,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,

              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 18),

            // =============================================
            // VIEW WORKER PROFILE
            // =============================================

            SizedBox(
              width: double.infinity,
              height: 48,

              child: ElevatedButton(
                onPressed: () {

                  // =======================================
                  // OPEN WORKER PROFILE
                  // =======================================

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

                child: const Text(
                  'View Worker Profile',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

