
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

  // =====================================================
  // FIREBASE
  // =====================================================

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // =====================================================
  // CONTROLLERS
  // =====================================================

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  // =====================================================
  // VARIABLES
  // =====================================================

  bool _isLoading = true;
  bool _isSaving = false;

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {
    super.initState();

    _loadProfile();
  }

  // =====================================================
  // LOAD PROFILE
  // =====================================================

  Future<void> _loadProfile() async {
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

        _nameController.text =
            data['name'] ?? '';

        _phoneController.text =
            data['phone'] ?? '';

        _emailController.text =
            data['email'] ??
            currentUser.email ??
            '';
      } else {
        _emailController.text =
            currentUser.email ?? '';
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Load Edit Profile Error: $e',
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  // =====================================================
  // SAVE PROFILE
  // =====================================================

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your name',
          ),
        ),
      );

      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your phone number',
          ),
        ),
      );

      return;
    }

    try {
      final User? currentUser =
          _auth.currentUser;

      if (currentUser == null) {
        return;
      }

      setState(() {
        _isSaving = true;
      });

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile updated successfully',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint(
        'Save Profile Error: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to update profile',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
        ),
        centerTitle: true,
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // =====================================
                  // NAME
                  // =====================================

                  const Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _nameController,
                    textInputAction:
                        TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Enter your name',
                      prefixIcon: Icon(
                        Icons.person_outline,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =====================================
                  // PHONE
                  // =====================================

                  const Text(
                    'Phone Number',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType:
                        TextInputType.phone,
                    textInputAction:
                        TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText:
                          'Enter your phone number',
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =====================================
                  // EMAIL
                  // =====================================

                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.email_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // =====================================
                  // SAVE BUTTON
                  // =====================================

                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton(
                      onPressed:
                          _isSaving
                              ? null
                              : _saveProfile,

                      child: _isSaving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
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
}