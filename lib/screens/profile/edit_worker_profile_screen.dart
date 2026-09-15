
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditWorkerProfileScreen extends StatefulWidget {
  const EditWorkerProfileScreen({
    super.key,
  });

  @override
  State<EditWorkerProfileScreen> createState() =>
      _EditWorkerProfileScreenState();
}

class _EditWorkerProfileScreenState
    extends State<EditWorkerProfileScreen> {

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

    _loadWorkerProfile();
  }

  // =====================================================
  // LOAD WORKER PROFILE
  // =====================================================

  Future<void> _loadWorkerProfile() async {
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

      if (!mounted) return;

      setState(() {
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
  // SAVE PROFILE
  // =====================================================

  Future<void> _saveProfile() async {

    final String name =
        _nameController.text.trim();

    final String phone =
        _phoneController.text.trim();

    final String email =
        _emailController.text.trim();

    // ---------------------------------------------------
    // VALIDATION
    // ---------------------------------------------------

    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Please enter your name.'),
        ),
      );

      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text(
            'Please enter your phone number.',
          ),
        ),
      );

      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text(
            'Please enter your email.',
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

      // -------------------------------------------------
      // UPDATE FIREBASE AUTH EMAIL
      // -------------------------------------------------

      if (email != currentUser.email) {

        await currentUser
            .verifyBeforeUpdateEmail(email);
      }

      // -------------------------------------------------
      // UPDATE FIRESTORE
      // -------------------------------------------------

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'name': name,
        'phone': phone,
        'email': email,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Profile updated successfully.',
          ),
        ),
      );

      // Go back to Worker Profile
      Navigator.pop(context);

    } catch (e) {

      debugPrint(
        'Save Worker Profile Error: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update profile: $e',
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
              child:
                  CircularProgressIndicator(),
            )

          : SingleChildScrollView(

              padding:
                  const EdgeInsets.all(20),

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
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller:
                        _nameController,

                    textInputAction:
                        TextInputAction.next,

                    decoration:
                        const InputDecoration(
                      hintText:
                          'Enter your name',

                      prefixIcon:
                          Icon(
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
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller:
                        _phoneController,

                    keyboardType:
                        TextInputType.phone,

                    textInputAction:
                        TextInputAction.next,

                    decoration:
                        const InputDecoration(
                      hintText:
                          'Enter your phone number',

                      prefixIcon:
                          Icon(
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
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller:
                        _emailController,

                    keyboardType:
                        TextInputType.emailAddress,

                    decoration:
                        const InputDecoration(
                      hintText:
                          'Enter your email',

                      prefixIcon:
                          Icon(
                        Icons.email_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // =====================================
                  // SAVE BUTTON
                  // =====================================

                  SizedBox(
                    width:
                        double.infinity,

                    height: 52,

                    child:
                        ElevatedButton(
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
                              style:
                                  TextStyle(
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