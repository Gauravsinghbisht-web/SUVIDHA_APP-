

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkerAvailabilityCard extends StatefulWidget {
  const WorkerAvailabilityCard({
    super.key,
  });

  @override
  State<WorkerAvailabilityCard> createState() =>
      _WorkerAvailabilityCardState();
}

class _WorkerAvailabilityCardState
    extends State<WorkerAvailabilityCard> {

  // =====================================================
  // FIRESTORE
  // =====================================================

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // =====================================================
  // AVAILABILITY
  // =====================================================

  bool _isAvailable = false;
  bool _isLoading = true;

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {
    super.initState();

    _loadAvailability();
  }

  // =====================================================
  // LOAD AVAILABILITY
  // =====================================================

  Future<void> _loadAvailability() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      final DocumentSnapshot doc =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .get();

      if (doc.exists) {
        final data =
            doc.data() as Map<String, dynamic>;

        setState(() {
          _isAvailable =
              data['isAvailable'] ?? false;

          _isLoading = false;
        });
      } else {
        setState(() {
          _isAvailable = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(
        'Error loading availability: $e',
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  // =====================================================
  // UPDATE AVAILABILITY
  // =====================================================

  Future<void> _updateAvailability(
    bool value,
  ) async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    // Update UI immediately
    setState(() {
      _isAvailable = value;
    });

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({
        'isAvailable': value,
      });

      debugPrint(
        'Worker availability updated: $value',
      );
    } catch (e) {
      debugPrint(
        'Error updating availability: $e',
      );

      // Revert if Firestore update fails
      if (mounted) {
        setState(() {
          _isAvailable = !value;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Could not update availability.',
            ),
          ),
        );
      }
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Row(
          children: [

            // =========================================
            // ICON
            // =========================================
            Icon(
              _isAvailable
                  ? Icons.check_circle
                  : Icons.cancel,
              size: 35,
              color: _isAvailable
                  ? Colors.green
                  : Colors.grey,
            ),

            const SizedBox(width: 15),

            // =========================================
            // TEXT
            // =========================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Availability',

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    _isAvailable
                        ? 'You are available for work'
                        : 'You are unavailable for work',
                  ),
                ],
              ),
            ),

            // =========================================
            // SWITCH
            // =========================================

            _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Switch(
                    value: _isAvailable,

                    onChanged:
                        _updateAvailability,
                  ),
          ],
        ),
      ),
    );
  }
}
