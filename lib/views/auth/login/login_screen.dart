
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/worker/worker_home_screen.dart';
import '../../../models/user_role.dart';
import '../../../screens/user/user_home_screen.dart';
import '../signup/signup_screen.dart';

import 'login_controller.dart';
import 'login_form.dart';

class LoginScreen extends StatefulWidget {
  final UserRole role;

  const LoginScreen({
    super.key,
    required this.role,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // =====================================================
  // TEXT CONTROLLERS
  // =====================================================

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  // =====================================================
  // LOGIN CONTROLLER
  // =====================================================

  final LoginController loginController =
      LoginController();

  // =====================================================
  // SCREEN VARIABLES
  // =====================================================

  bool isLoading = false;

  bool obscurePassword = true;

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // =====================================================
  // LOGIN
  // =====================================================

  Future<void> loginUser() async {

    final String email =
        emailController.text.trim();

    final String password =
        passwordController.text.trim();

    // ---------------------------------------------------
    // VALIDATION
    // ---------------------------------------------------

    if (email.isEmpty || password.isEmpty) {

      showMessage(
        'Please enter email and password',
        Colors.red,
      );

      return;
    }

    // ---------------------------------------------------
    // START LOADING
    // ---------------------------------------------------

    setState(() {
      isLoading = true;
    });

    // ---------------------------------------------------
    // LOGIN THROUGH CONTROLLER
    // ---------------------------------------------------

    final LoginResult result =
        await loginController.login(
      email: email,
      password: password,
      selectedRole: widget.role,
    );

    if (!mounted) return;

    // ---------------------------------------------------
    // STOP LOADING
    // ---------------------------------------------------

    setState(() {
      isLoading = false;
    });

    // ---------------------------------------------------
    // LOGIN FAILED
    // ---------------------------------------------------

    if (!result.isSuccess) {

      showMessage(
        result.message,
        Colors.red,
      );

      return;
    }

    // ---------------------------------------------------
    // LOGIN SUCCESSFUL
    // ---------------------------------------------------

    final String name =
        result.name ?? '';

    final String role =
        result.role ?? '';

    print('Final login role: $role');
    print('Final login name: $name');

    // ===================================================
    // USER
    // ===================================================

    if (widget.role == UserRole.user) {

      Navigator.pushReplacement(
        context,

        MaterialPageRoute(
          builder: (context) =>
              UserHomeScreen(
            name: name,
          ),
        ),
      );

      return;
    }

    // ===================================================
    // WORKER
    // ===================================================

    if (widget.role == UserRole.worker) {

      Navigator.pushReplacement(
        context,

        MaterialPageRoute(
          builder: (context) =>
              WorkerHomeScreen(
            name: name,
          ),
        ),
      );

      return;
    }

    // ===================================================
    // UNKNOWN ROLE
    // ===================================================

    showMessage(
      'Invalid selected role.',
      Colors.red,
    );
  }

  // =====================================================
  // FORGOT PASSWORD
  // =====================================================

  Future<void> forgotPassword() async {

    final String email =
        emailController.text.trim();

    if (email.isEmpty) {

      showMessage(
        'Enter your email first.',
        Colors.orange,
      );

      return;
    }

    // ---------------------------------------------------
    // START LOADING
    // ---------------------------------------------------

    setState(() {
      isLoading = true;
    });

    // ---------------------------------------------------
    // RESET PASSWORD
    // ---------------------------------------------------

    final LoginResult result =
        await loginController.forgotPassword(
      email,
    );

    if (!mounted) return;

    // ---------------------------------------------------
    // STOP LOADING
    // ---------------------------------------------------

    setState(() {
      isLoading = false;
    });

    showMessage(
      result.message,
      result.isSuccess
          ? Colors.green
          : Colors.red,
    );
  }

  // =====================================================
  // OPEN SIGNUP
  // =====================================================

  void openSignup() {

    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (context) =>
            SignupScreen(
          role: widget.role,
        ),
      ),
    );
  }

  // =====================================================
  // SHOW SNACKBAR
  // =====================================================

  void showMessage(
    String message,
    Color color,
  ) {

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {

    final bool isUser =
        widget.role == UserRole.user;

    return Scaffold(

      // =================================================
      // APP BAR
      // =================================================

      appBar: AppBar(
        title: Text(
          isUser
              ? 'User Login'
              : 'Worker Login',
        ),

        centerTitle: true,
      ),

      // =================================================
      // BODY
      // =================================================

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(24),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 30),

            // =============================================
            // TITLE
            // =============================================

            Text(
              isUser
                  ? 'Welcome, User!'
                  : 'Welcome, Worker!',

              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // =============================================
            // SUBTITLE
            // =============================================

            Text(
              'Login to continue using Suvidha.',

              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 40),

            // =============================================
            // LOGIN FORM
            // =============================================

            LoginForm(

              emailController:
                  emailController,

              passwordController:
                  passwordController,

              obscurePassword:
                  obscurePassword,

              isLoading:
                  isLoading,

              onLogin:
                  loginUser,

              onForgotPassword:
                  forgotPassword,

              onCreateAccount:
                  openSignup,

              onTogglePassword: () {

                setState(() {
                  obscurePassword =
                      !obscurePassword;
                });
              },
            ),

            const SizedBox(height: 20),

            // =============================================
            // ROLE INFORMATION
            // =============================================

            Center(

              child: Text(

                isUser
                    ? 'You are logging in as a User'
                    : 'You are logging in as a Worker',

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

