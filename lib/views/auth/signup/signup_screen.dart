import 'package:flutter/material.dart';
import '../../../models/user_role.dart';
import '../../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  final UserRole role;

  const SignupScreen({
    super.key,
    required this.role,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // =========================
  // CONTROLLERS
  // =========================

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // =========================
  // AUTH SERVICE
  // =========================

  final AuthService authService = AuthService();

  bool isLoading = false;

  // =========================
  // DISPOSE
  // =========================

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // =========================
  // SIGN UP
  // =========================

  Future<void> createAccount() async {
    // Remove extra spaces
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    // =========================
    // VALIDATION
    // =========================

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
        ),
      );

      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
        ),
      );

      return;
    }

    // =========================
    // START LOADING
    // =========================

    setState(() {
      isLoading = true;
    });

    try {
      // =========================
      // CREATE FIREBASE ACCOUNT
      // =========================

      final user = await authService.signUp(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: widget.role.name,
      );

      if (!mounted) return;

      // =========================
      // SUCCESS
      // =========================

      if (user != null) {
        print('================================');
        print('ACCOUNT CREATED SUCCESSFULLY');
        print('Firebase UID: ${user.uid}');
        print('Email: ${user.email}');
        print('Role: ${widget.role.name}');
        print('================================');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Clear fields
        nameController.clear();
        emailController.clear();
        phoneController.clear();
        passwordController.clear();

        // TODO:
        // Later we will navigate to the Login screen
        // or directly to the correct dashboard.
      } else {
        // =========================
        // FAILED
        // =========================

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account creation failed. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      print('Create Account Error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong: $e',
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

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    final bool isUser = widget.role == UserRole.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isUser ? 'User Sign Up' : 'Worker Sign Up',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // =========================
            // TITLE
            // =========================

            Text(
              isUser
                  ? 'Create your User account'
                  : 'Create your Worker account',

              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // =========================
            // SUBTITLE
            // =========================

            Text(
              isUser
                  ? 'Find trusted workers for your needs.'
                  : 'Offer your services to customers.',

              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 35),

            // =========================
            // FULL NAME
            // =========================

            const Text(
              'Full Name',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: nameController,

              textInputAction: TextInputAction.next,

              decoration: InputDecoration(
                hintText: 'Enter your name',

                prefixIcon: const Icon(
                  Icons.person_outline,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // EMAIL
            // =========================

            const Text(
              'Email',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: emailController,

              keyboardType: TextInputType.emailAddress,

              textInputAction: TextInputAction.next,

              decoration: InputDecoration(
                hintText: 'Enter your email',

                prefixIcon: const Icon(
                  Icons.email_outlined,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // PHONE
            // =========================

            const Text(
              'Phone Number',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: phoneController,

              keyboardType: TextInputType.phone,

              textInputAction: TextInputAction.next,

              decoration: InputDecoration(
                hintText: 'Enter your phone number',

                prefixIcon: const Icon(
                  Icons.phone_outlined,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // PASSWORD
            // =========================

            const Text(
              'Password',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: passwordController,

              obscureText: true,

              textInputAction: TextInputAction.done,

              decoration: InputDecoration(
                hintText: 'Create a password',

                prefixIcon: const Icon(
                  Icons.lock_outline,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // CREATE ACCOUNT BUTTON
            // =========================

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : createAccount,

                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,

                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create Account',
                        style: TextStyle(
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