
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import 'package:flutter_application_1/screens/booking/booking_screen.dart';

class WorkerProfileScreen extends StatelessWidget {
  final ServiceModel service;

  const WorkerProfileScreen({
    super.key,
    required this.service,
  });

  // ==========================================
  // GET WORKER PROFILE
  // ==========================================

  Future<DocumentSnapshot<Map<String, dynamic>>>
      _getWorkerProfile() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(service.workerId)
        .get();
  }

  // ==========================================
  // OPEN BOOKING SCREEN
  // ==========================================

  void _openBookingScreen(
    BuildContext context,
    Map<String, dynamic> workerData,
  ) {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    // User not logged in

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please login first.',
          ),
          backgroundColor:
              Theme.of(context).colorScheme.error,
        ),
      );

      return;
    }

    // Prevent booking yourself

    if (currentUser.uid == service.workerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You cannot book yourself.',
          ),
          backgroundColor: Colors.orange,
        ),
      );

      return;
    }

    // Check worker availability

    final bool isAvailable =
        workerData['isAvailable'] ?? true;

    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'This worker is currently unavailable.',
          ),
          backgroundColor:
              Theme.of(context).colorScheme.error,
        ),
      );

      return;
    }

    // Open Booking Screen

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingScreen(
          workerId: service.workerId,
          serviceId: service.id,
          serviceType: service.serviceType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Worker Profile',
        ),
      ),

      body: FutureBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        future: _getWorkerProfile(),
        builder: (context, snapshot) {

          // ==========================================
          // LOADING
          // ==========================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ==========================================
          // ERROR
          // ==========================================

          if (snapshot.hasError) {
            return _buildErrorState(
              context,
              snapshot.error.toString(),
            );
          }

          // ==========================================
          // PROFILE NOT FOUND
          // ==========================================

          if (!snapshot.hasData ||
              !snapshot.data!.exists) {
            return _buildNotFoundState(context);
          }

          // ==========================================
          // WORKER DATA
          // ==========================================

          final Map<String, dynamic> workerData =
              snapshot.data!.data() ?? {};

          final String workerName =
              workerData['name'] ?? 'Worker';

          final String phone =
              workerData['phone'] ??
                  'Phone number not available';

          final String email =
              workerData['email'] ??
                  'Email not available';

          final bool isAvailable =
              workerData['isAvailable'] ?? true;

          return SingleChildScrollView(
            physics:
                const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                // ======================================
                // PROFILE HEADER
                // ======================================

                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 112,
                        width: 112,
                        decoration: BoxDecoration(
                          color: primary.withValues(
                            alpha: 0.10,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primary.withValues(
                              alpha: 0.18,
                            ),
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 62,
                          color: primary,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        workerName,
                        textAlign: TextAlign.center,
                        style:
                            theme.textTheme.headlineMedium,
                      ),

                      const SizedBox(height: 6),

                      Text(
                        service.serviceType,
                        style:
                            theme.textTheme.bodyLarge,
                      ),

                      const SizedBox(height: 12),

                      // Availability badge

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? Colors.green.withValues(
                                  alpha: 0.10,
                                )
                              : theme.colorScheme.error
                                  .withValues(
                                  alpha: 0.10,
                                ),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Icon(
                              isAvailable
                                  ? Icons.circle
                                  : Icons.circle_outlined,
                              size: 9,
                              color: isAvailable
                                  ? Colors.green
                                  : theme.colorScheme.error,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              isAvailable
                                  ? 'Available now'
                                  : 'Currently unavailable',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.w600,
                                color: isAvailable
                                    ? Colors.green.shade700
                                    : theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ======================================
                // WORKER INFORMATION
                // ======================================

                Text(
                  'Worker Information',
                  style: theme.textTheme.titleLarge,
                ),

                const SizedBox(height: 14),

                _infoCard(
                  context,
                  icon: Icons.person_outline,
                  title: 'Name',
                  value: workerName,
                ),

                _infoCard(
                  context,
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  value: phone,
                ),

                _infoCard(
                  context,
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: email,
                ),

                const SizedBox(height: 24),

                // ======================================
                // SERVICE INFORMATION
                // ======================================

                Text(
                  'Service Information',
                  style: theme.textTheme.titleLarge,
                ),

                const SizedBox(height: 14),

                _infoCard(
                  context,
                  icon: Icons.handyman_outlined,
                  title: 'Service',
                  value: service.serviceType,
                ),

                _infoCard(
                  context,
                  icon: Icons.work_outline,
                  title: 'Experience',
                  value: service.experience,
                ),

                _infoCard(
                  context,
                  icon: Icons.currency_rupee,
                  title: 'Starting Price',
                  value: '₹${service.price}',
                ),

                _infoCard(
                  context,
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  value: service.location,
                ),

                const SizedBox(height: 24),

                // ======================================
                // ABOUT SERVICE
                // ======================================

                Text(
                  'About Service',
                  style: theme.textTheme.titleLarge,
                ),

                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      service.description,
                      style:
                          theme.textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ======================================
                // BOOK SERVICE
                // ======================================

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isAvailable
                        ? () {
                            _openBookingScreen(
                              context,
                              workerData,
                            );
                          }
                        : null,
                    icon: const Icon(
                      Icons.calendar_month_outlined,
                    ),
                    label: Text(
                      isAvailable
                          ? 'Book Service'
                          : 'Worker Unavailable',
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ======================================
                // WORKER ID
                // ======================================

                Center(
                  child: Text(
                    'Worker ID: ${service.workerId}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // INFO CARD
  // ==========================================

  Widget _infoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 5,
        ),
        leading: Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary
                .withValues(alpha: 0.10),
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium
              ?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding:
              const EdgeInsets.only(top: 4),
          child: Text(
            value,
            maxLines: 2,
            overflow:
                TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // ERROR STATE
  // ==========================================

  Widget _buildErrorState(
    BuildContext context,
    String error,
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
              'Unable to load worker profile',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),

            const SizedBox(height: 10),

            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // NOT FOUND STATE
  // ==========================================

  Widget _buildNotFoundState(
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
                Icons.person_off_outlined,
                size: 45,
                color: primary,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Worker profile not found',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),

            const SizedBox(height: 8),

            Text(
              'This worker profile is no longer available.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
