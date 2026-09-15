
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/screens/worker/worker_home_screen.dart';
import '../../../models/user_role.dart';
import '../../../screens/user/user_home_screen.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../signup/signup_screen.dart';
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
  // SCREEN VARIABLES
  // =====================================================

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
    // GET AUTH VIEWMODEL
    // ---------------------------------------------------

    final AuthViewModel authViewModel =
        context.read<AuthViewModel>();

    // ---------------------------------------------------
    // LOGIN
    // ---------------------------------------------------

    final bool success =
        await authViewModel.login(
      email: email,
      password: password,
      selectedRole: widget.role,
    );

    if (!mounted) return;

    // ---------------------------------------------------
    // LOGIN FAILED
    // ---------------------------------------------------

    if (!success) {
      showMessage(
        authViewModel.errorMessage ??
            'Login failed.',
        Colors.red,
      );

      return;
    }

    // ---------------------------------------------------
    // GET USER INFORMATION
    // ---------------------------------------------------

    final String name =
        authViewModel.userName ?? '';

    final String role =
        authViewModel.userRole ?? '';

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
    // GET AUTH VIEWMODEL
    // ---------------------------------------------------

    final AuthViewModel authViewModel =
        context.read<AuthViewModel>();

    // ---------------------------------------------------
    // RESET PASSWORD
    // ---------------------------------------------------

    final bool success =
        await authViewModel.resetPassword(
      email,
    );

    if (!mounted) return;

    // ---------------------------------------------------
    // SHOW MESSAGE
    // ---------------------------------------------------

    showMessage(
      success
          ? 'Password reset email sent. Check your inbox.'
          : authViewModel.errorMessage ??
              'Unable to reset password.',
      success
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
  // SHOW MESSAGE
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

    // ===================================================
    // LISTEN TO AUTH VIEWMODEL
    // ===================================================

    final bool isLoading =
        context.watch<AuthViewModel>().isLoading;

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
