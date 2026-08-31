
import '../service_request/service_request_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service_model.dart';
import '../../providers/service_request_provider.dart';

class WorkerProfileScreen extends StatelessWidget {
  final ServiceModel service;

  const WorkerProfileScreen({
    super.key,
    required this.service,
  });

  // =====================================================
  // GET WORKER PROFILE
  // =====================================================
  Future<DocumentSnapshot<Map<String, dynamic>>> _getWorkerProfile() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(service.workerId)
        .get();
  }

  // =====================================================
  // SEND SERVICE REQUEST
  // =====================================================
  Future<void> _sendServiceRequest(
    BuildContext context,
  ) async {
    // Get currently logged-in user
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    // Check login
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please login first.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // Prevent sending request to yourself
    if (currentUser.uid == service.workerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You cannot send a request to yourself.',
          ),
          backgroundColor: Colors.orange,
        ),
      );

      return;
    }

    // Get Provider
    final ServiceRequestProvider provider =
        context.read<ServiceRequestProvider>();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Create request
    final bool success =
        await provider.createRequest(
      userId: currentUser.uid,
      workerId: service.workerId,
      serviceId: service.id,
      serviceType: service.serviceType,
    );

    // Close loading dialog
    if (!context.mounted) return;

    Navigator.pop(context);

    // Show result
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Service request sent successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Unable to send service request.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // =================================================
      // APP BAR
      // =================================================
      appBar: AppBar(
        title: const Text(
          'Worker Profile',
        ),
        centerTitle: true,
      ),

      // =================================================
      // BODY
      // =================================================
      body: FutureBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        future: _getWorkerProfile(),

        builder: (context, snapshot) {
          // =============================================
          // LOADING
          // =============================================
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // =============================================
          // ERROR
          // =============================================
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Unable to load worker profile.\n\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // =============================================
          // PROFILE NOT FOUND
          // =============================================
          if (!snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Worker profile not found.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }

          // =============================================
          // WORKER DATA
          // =============================================
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // =======================================
                // PROFILE HEADER
                // =======================================
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    child: const Icon(
                      Icons.person,
                      size: 65,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    workerName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    service.serviceType,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // =======================================
                // WORKER INFORMATION
                // =======================================

                const Text(
                  'Worker Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                _infoCard(
                  icon: Icons.person_outline,
                  title: 'Name',
                  value: workerName,
                ),

                const SizedBox(height: 12),

                _infoCard(
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  value: phone,
                ),

                const SizedBox(height: 12),

                _infoCard(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: email,
                ),

                const SizedBox(height: 30),

                // =======================================
                // SERVICE INFORMATION
                // =======================================

                const Text(
                  'Service Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                _infoCard(
                  icon: Icons.handyman,
                  title: 'Service',
                  value: service.serviceType,
                ),

                const SizedBox(height: 12),

                _infoCard(
                  icon: Icons.work_outline,
                  title: 'Experience',
                  value: service.experience,
                ),

                const SizedBox(height: 12),

                _infoCard(
                  icon: Icons.currency_rupee,
                  title: 'Price',
                  value: '₹${service.price}',
                ),

                const SizedBox(height: 12),

                _infoCard(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  value: service.location,
                ),

                const SizedBox(height: 30),

                // =======================================
                // ABOUT SERVICE
                // =======================================

                const Text(
                  'About Service',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  service.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 30),

                // =======================================
                // SEND SERVICE REQUEST
                // =======================================

                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceRequestScreen(service: service,
                          ),
                          ),
                          );
                      _sendServiceRequest(context);
                    },

                    icon: const Icon(
                      Icons.send,
                    ),

                    label: const Text(
                      'Send Service Request',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // =======================================
                // WORKER ID
                // =======================================

                Center(
                  child: Text(
                    'Worker ID: ${service.workerId}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
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

  // =====================================================
  // INFO CARD
  // =====================================================

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      child: ListTile(
        leading: Icon(
          icon,
          size: 28,
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

