
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/service_model.dart';
import 'package:flutter_application_1/providers/service_request_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/models/service_model.dart';
import 'package:flutter_application_1/providers/service_request_provider.dart';

class WorkerProfileScreen extends StatefulWidget {
  final ServiceModel service;

  const WorkerProfileScreen({
    super.key,
    required this.service,
  });

  @override
  State<WorkerProfileScreen> createState() =>
      _WorkerProfileScreenState();
}

class _WorkerProfileScreenState
    extends State<WorkerProfileScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  bool _isLoading = true;
  bool _isSendingRequest = false;

  Map<String, dynamic>? _workerData;

  @override
  void initState() {
    super.initState();
    _loadWorkerProfile();
  }

  // =====================================================
  // LOAD WORKER PROFILE
  // =====================================================

  Future<void> _loadWorkerProfile() async {
    try {
      final DocumentSnapshot snapshot =
          await _firestore
              .collection('users')
              .doc(widget.service.workerId)
              .get();

      if (snapshot.exists) {
        setState(() {
          _workerData =
              snapshot.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _workerData = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(
        'Load Worker Profile Error: $e',
      );

      setState(() {
        _workerData = null;
        _isLoading = false;
      });
    }
  }

  // =====================================================
  // SEND SERVICE REQUEST
  // =====================================================

  Future<void> _sendServiceRequest() async {
    final User? currentUser =
        _auth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please login first.',
          ),
        ),
      );

      return;
    }

    if (_workerData == null) {
      return;
    }

    final bool isAvailable =
        _workerData!['isAvailable'] ?? true;

    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This worker is currently unavailable.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSendingRequest = true;
    });

    try {
      final bool success =
          await context
              .read<ServiceRequestProvider>()
              .createRequest(
                userId: currentUser.uid,
                workerId: widget.service.workerId,
                serviceId: widget.service.id,
                serviceType:
                    widget.service.serviceType,
              );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Service request sent successfully.',
            ),
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to send service request.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        'Send Service Request Error: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingRequest = false;
        });
      }
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
          'Worker Profile',
        ),
      ),
      body: _buildBody(),
    );
  }

  // =====================================================
  // BODY
  // =====================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_workerData == null) {
      return const Center(
        child: Text(
          'Worker profile not found.',
        ),
      );
    }

    final String name =
        _workerData!['name'] ?? 'Worker';

    final String email =
        _workerData!['email'] ?? 'Not available';

    final String phone =
        _workerData!['phone'] ?? 'Not available';

    final bool isAvailable =
        _workerData!['isAvailable'] ?? true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // =================================================
          // PROFILE HEADER
          // =================================================

          Center(
            child: CircleAvatar(
              radius: 50,
              child: Text(
                name.isNotEmpty
                    ? name[0].toUpperCase()
                    : 'W',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              widget.service.serviceType,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // =================================================
          // AVAILABILITY
          // =================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(12),
              color: isAvailable
                  ? Colors.green.shade50
                  : Colors.red.shade50,
            ),
            child: Row(
              children: [
                Icon(
                  isAvailable
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: isAvailable
                      ? Colors.green
                      : Colors.red,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isAvailable
                        ? 'Available'
                        : 'Currently Unavailable',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isAvailable
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // =================================================
          // WORKER INFORMATION
          // =================================================

          const Text(
            'Worker Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _infoTile(
            icon: Icons.email,
            title: 'Email',
            value: email,
          ),

          _infoTile(
            icon: Icons.phone,
            title: 'Phone',
            value: phone,
          ),

          _infoTile(
            icon: Icons.work,
            title: 'Service',
            value: widget.service.serviceType,
          ),

          _infoTile(
            icon: Icons.location_on,
            title: 'Location',
            value: widget.service.location,
          ),

          _infoTile(
            icon: Icons.work_history,
            title: 'Experience',
            value:
                '${widget.service.experience} years',
          ),

          _infoTile(
            icon: Icons.currency_rupee,
            title: 'Price',
            value:
                '₹${widget.service.price}',
          ),

          const SizedBox(height: 16),

          // =================================================
          // DESCRIPTION
          // =================================================

          const Text(
            'About Service',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.service.description,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 30),

          // =================================================
          // SEND REQUEST BUTTON
          // =================================================

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed:
                  isAvailable && !_isSendingRequest
                      ? _sendServiceRequest
                      : null,
              icon: _isSendingRequest
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send,
                    ),
              label: Text(
                _isSendingRequest
                    ? 'Sending...'
                    : isAvailable
                        ? 'Send Service Request'
                        : 'Worker Unavailable',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // INFO TILE
  // =====================================================

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color:
                        Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
