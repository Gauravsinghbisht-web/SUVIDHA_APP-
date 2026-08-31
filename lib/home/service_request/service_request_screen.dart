// TODO Implement this library.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../models/service_request_model.dart';
import '../../services/service_request_service.dart';

class ServiceRequestScreen extends StatefulWidget {
  final ServiceModel service;

  const ServiceRequestScreen({
    super.key,
    required this.service,
  });

  @override
  State<ServiceRequestScreen> createState() =>
      _ServiceRequestScreenState();
}

class _ServiceRequestScreenState
    extends State<ServiceRequestScreen> {
  // =====================================================
  // CONTROLLERS
  // =====================================================

  final descriptionController =
      TextEditingController();

  final locationController =
      TextEditingController();

  // =====================================================
  // SERVICE
  // =====================================================

  final ServiceRequestService _requestService =
      ServiceRequestService();

  // =====================================================
  // VARIABLES
  // =====================================================

  bool isLoading = false;

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }

  // =====================================================
  // SEND REQUEST
  // =====================================================

  Future<void> sendServiceRequest() async {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    // -----------------------------------------------------
    // CHECK LOGIN
    // -----------------------------------------------------

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please login before sending a request.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final description =
        descriptionController.text.trim();

    final location =
        locationController.text.trim();

    // -----------------------------------------------------
    // VALIDATION
    // -----------------------------------------------------

    if (description.isEmpty ||
        location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your problem and location.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // ===================================================
      // CREATE REQUEST
      // ===================================================

      final ServiceRequestModel request =
          ServiceRequestModel(
        id: '',
        userId: currentUser.uid,
        workerId: widget.service.workerId,
        serviceId: widget.service.id,
        serviceType: widget.service.serviceType,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      // ===================================================
      // SAVE TO FIRESTORE
      // ===================================================

      await _requestService.createRequest(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Service request sent successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      debugPrint(
        'Send Service Request Error: $e',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to send service request.\n$e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request Service',
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // =================================================
            // WORKER / SERVICE
            // =================================================

            Card(
              elevation: 2,

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: Padding(
                padding:
                    const EdgeInsets.all(18),

                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,

                      child: const Icon(
                        Icons.person,
                        size: 32,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Text(
                            widget.service
                                .serviceType,

                            style:
                                const TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Worker ID: '
                            '${widget.service.workerId}',

                            maxLines: 1,

                            overflow:
                                TextOverflow.ellipsis,

                            style: TextStyle(
                              color: Colors
                                  .grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =================================================
            // PROBLEM
            // =================================================

            const Text(
              'What do you need?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller:
                  descriptionController,

              maxLines: 4,

              decoration:
                  InputDecoration(
                hintText:
                    'Describe your problem...',
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // LOCATION
            // =================================================

            const Text(
              'Your Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller:
                  locationController,

              maxLines: 2,

              decoration:
                  InputDecoration(
                hintText:
                    'Enter your address/location',

                prefixIcon:
                    const Icon(
                  Icons.location_on_outlined,
                ),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),

            // =================================================
            // SEND REQUEST BUTTON
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : sendServiceRequest,

                icon: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,

                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.send,
                      ),

                label: Text(
                  isLoading
                      ? 'Sending...'
                      : 'Send Service Request',

                  style:
                      const TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

