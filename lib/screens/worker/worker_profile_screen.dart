
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/user/user/worker_profile_screen.dart';
import 'package:flutter_application_1/screens/profile/edit_worker_profile_screen.dart' hide EditWorkerProfileScreen;

class WorkerProfileScreen extends StatefulWidget {
  final String? workerId;

  const WorkerProfileScreen({
    super.key,
    this.workerId,
  });

  @override
  State<WorkerProfileScreen> createState() =>
      _WorkerProfileScreenState();
}

class _WorkerProfileScreenState
    extends State<WorkerProfileScreen> {
  // =====================================================
  // FIREBASE
  // =====================================================

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // =====================================================
  // VARIABLES
  // =====================================================

  bool _isLoading = true;
  bool _isAvailable = true;
  bool _isUpdatingAvailability = false;

  String _name = '';
  String _email = '';
  String _phone = '';

  String? _profileWorkerId;

  // =====================================================
  // CHECK WHETHER THIS IS MY PROFILE
  // =====================================================

  bool get _isMyProfile {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return false;
    }

    return _profileWorkerId == currentUser.uid;
  }

  // =====================================================
  // INIT
  // =====================================================

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
      final User? currentUser =
          _auth.currentUser;

      final String? workerId =
          widget.workerId ?? currentUser?.uid;

      if (workerId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _profileWorkerId = workerId;

      final DocumentSnapshot document =
          await _firestore
              .collection('users')
              .doc(workerId)
              .get();

      if (!document.exists) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> data =
          document.data()
              as Map<String, dynamic>;

      if (!mounted) return;

      setState(() {
        _name = data['name'] ?? '';

        _email =
            data['email'] ??
            currentUser?.email ??
            '';

        _phone =
            data['phone'] ??
            '';

        _isAvailable =
            data['isAvailable'] ?? true;

        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Load Worker Profile Error: $e',
      );

      if (!mounted) return;

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
    final User? currentUser =
        _auth.currentUser;

    if (currentUser == null) {
      return;
    }

    if (!_isMyProfile) {
      return;
    }

    setState(() {
      _isUpdatingAvailability = true;
    });

    try {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .set(
        {
          'isAvailable': value,
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      setState(() {
        _isAvailable = value;
        _isUpdatingAvailability = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'You are now available.'
                : 'You are now unavailable.',
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'Update Availability Error: $e',
      );

      if (!mounted) return;

      setState(() {
        _isUpdatingAvailability = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to update availability.',
          ),
        ),
      );
    }
  }

  // =====================================================
  // OPEN EDIT PROFILE SCREEN
  // =====================================================

  Future<void> _openEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const EditWorkerProfileScreen(),
      ),
    );

    // Reload profile after returning
    // from Edit Profile screen.
    _loadWorkerProfile();
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> _logout() async {
    try {
      await _auth.signOut();

      if (!mounted) return;

      Navigator.popUntil(
        context,
        (route) => route.isFirst,
      );
    } catch (e) {
      debugPrint(
        'Worker Logout Error: $e',
      );
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isMyProfile
              ? 'My Profile'
              : 'Worker Profile',
        ),
        centerTitle: true,
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.all(20),

              child: Column(
                children: [

                  // =====================================
                  // PROFILE IMAGE
                  // =====================================

                  const CircleAvatar(
                    radius: 55,
                    child: Icon(
                      Icons.person,
                      size: 60,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =====================================
                  // WORKER NAME
                  // =====================================

                  Text(
                    _name.isEmpty
                        ? 'Worker'
                        : _name,
                    style:
                        const TextStyle(
                      fontSize: 25,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =====================================
                  // AVAILABILITY
                  // =====================================

                  _availabilityCard(),

                  const SizedBox(height: 20),

                  // =====================================
                  // EMAIL
                  // =====================================

                  _profileItem(
                    icon:
                        Icons.email_outlined,
                    title: 'Email',
                    value:
                        _email.isEmpty
                            ? 'Not available'
                            : _email,
                  ),

                  const SizedBox(height: 15),

                  // =====================================
                  // PHONE
                  // =====================================

                  _profileItem(
                    icon:
                        Icons.phone_outlined,
                    title: 'Phone',
                    value:
                        _phone.isEmpty
                            ? 'Not available'
                            : _phone,
                  ),

                  // =====================================
                  // OWN PROFILE BUTTONS
                  // =====================================

                  if (_isMyProfile) ...[

                    const SizedBox(height: 30),

                    // ===================================
                    // EDIT PROFILE
                    // ===================================

                    SizedBox(
                      width:
                          double.infinity,
                      height: 52,

                      child:
                          ElevatedButton.icon(
                        onPressed:
                            _openEditProfile,

                        icon: const Icon(
                          Icons.edit,
                        ),

                        label:
                            const Text(
                          'Edit Profile',
                          style:
                              TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ===================================
                    // LOGOUT
                    // ===================================

                    SizedBox(
                      width:
                          double.infinity,
                      height: 52,

                      child:
                          OutlinedButton.icon(
                        onPressed: _logout,

                        icon: const Icon(
                          Icons.logout,
                        ),

                        label:
                            const Text(
                          'Logout',
                          style:
                              TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  // =====================================================
  // AVAILABILITY CARD
  // =====================================================

  Widget _availabilityCard() {
    return Card(
      elevation: 2,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(15),
      ),

      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        child: Row(
          children: [

            CircleAvatar(
              child: Icon(
                _isAvailable
                    ? Icons.check_circle
                    : Icons.cancel,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    'Worker Availability',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    _isAvailable
                        ? 'Available'
                        : 'Unavailable',

                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    _isAvailable
                        ? 'Users can request your service.'
                        : 'Users cannot request your service.',

                    style:
                        const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            if (_isMyProfile)
              _isUpdatingAvailability

                  ? const SizedBox(
                      width: 24,
                      height: 24,

                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )

                  : Switch(
                      value:
                          _isAvailable,
                      onChanged:
                          _updateAvailability,
                    ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // PROFILE ITEM
  // =====================================================

  Widget _profileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 2,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(15),
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Row(
          children: [

            CircleAvatar(
              child: Icon(icon),
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
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w500,
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