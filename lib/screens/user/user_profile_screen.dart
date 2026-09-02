
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
  });

  @override
  State<UserProfileScreen> createState() =>
      _UserProfileScreenState();
}

class _UserProfileScreenState
    extends State<UserProfileScreen> {

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

  String _name = '';
  String _email = '';
  String _phone = '';

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {
    super.initState();

    _loadUserProfile();
  }

  // =====================================================
  // LOAD USER PROFILE
  // =====================================================

  Future<void> _loadUserProfile() async {
    try {
      final User? currentUser =
          _auth.currentUser;

      if (currentUser == null) {
        return;
      }

      final DocumentSnapshot document =
          await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .get();

      if (document.exists) {
        final Map<String, dynamic> data =
            document.data()
                as Map<String, dynamic>;

        setState(() {
          _name = data['name'] ?? '';
          _email =
              data['email'] ??
              currentUser.email ??
              '';
          _phone = data['phone'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _email =
              currentUser.email ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(
        'Load User Profile Error: $e',
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> _logout() async {
    try {
      await _auth.signOut();

      if (!mounted) return;

      // Login screen navigation
      // will be added according to
      // your current authentication flow.
      
      Navigator.popUntil(
        context,
        (route) => route.isFirst,
      );
    } catch (e) {
      debugPrint(
        'Logout Error: $e',
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
        title: const Text(
          'My Profile',
        ),

        centerTitle: true,
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
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
                  // NAME
                  // =====================================

                  Text(
                    _name.isEmpty
                        ? 'User'
                        : _name,

                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =====================================
                  // EMAIL
                  // =====================================

                  _profileItem(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: _email.isEmpty
                        ? 'Not available'
                        : _email,
                  ),

                  const SizedBox(height: 15),

                  // =====================================
                  // PHONE
                  // =====================================

                  _profileItem(
                    icon: Icons.phone_outlined,
                    title: 'Phone',
                    value: _phone.isEmpty
                        ? 'Not available'
                        : _phone,
                  ),

                  const SizedBox(height: 30),

                  // =====================================
                  // EDIT PROFILE
                  // =====================================

                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Edit Profile
                        // will be added next.
                      },

                      icon: const Icon(
                        Icons.edit,
                      ),

                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // =====================================
                  // LOGOUT
                  // =====================================

                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: OutlinedButton.icon(
                      onPressed: _logout,

                      icon: const Icon(
                        Icons.logout,
                      ),

                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
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

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(15),
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

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
                    style: const TextStyle(
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

