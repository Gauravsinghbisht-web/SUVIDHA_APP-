
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/user_role.dart';
import '../../../services/auth_service.dart';

class LoginController {
  final AuthService authService = AuthService();

  // =====================================================
  // LOGIN
  // =====================================================

  Future<LoginResult> login({
    required String email,
    required String password,
    required UserRole selectedRole,
  }) async {
    try {
      // ---------------------------------------------------
      // 1. Firebase Authentication
      // ---------------------------------------------------

      final User? user = await authService.login(
        email: email.trim(),
        password: password.trim(),
      );

      if (user == null) {
        return LoginResult.failure(
          'Login failed. Please check your email and password.',
        );
      }

      print('Login successful');
      print('UID: ${user.uid}');
      print('Email: ${user.email}');

      // ---------------------------------------------------
      // 2. Get Profile From Firestore
      // ---------------------------------------------------

      final DocumentSnapshot userDocument =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!userDocument.exists) {
        return LoginResult.failure(
          'User profile not found in Firestore.',
        );
      }

      final Map<String, dynamic> userData =
          userDocument.data() as Map<String, dynamic>;

      final String name =
          userData['name']?.toString() ?? '';

      final String role =
          userData['role']?.toString().toLowerCase() ?? '';

      print('Firestore role: $role');
      print('Firestore name: $name');

      // ---------------------------------------------------
      // 3. Check Selected Role
      // ---------------------------------------------------

      final String selectedRoleName =
          selectedRole.name;

      print('Selected role: $selectedRoleName');

      if (role != selectedRoleName) {
        return LoginResult.failure(
          'This account is registered as '
          '${_formatRole(role)}, '
          'not ${_formatRole(selectedRoleName)}.',
        );
      }

      // ---------------------------------------------------
      // 4. Return Successful Result
      // ---------------------------------------------------

      return LoginResult.success(
        user: user,
        name: name,
        role: role,
      );
    }

    // =====================================================
    // FIREBASE AUTH ERROR
    // =====================================================

    on FirebaseAuthException catch (e) {
      print('Firebase Login Error: ${e.code}');
      print('Message: ${e.message}');

      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;

        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email.';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        case 'too-many-requests':
          message = 'Too many attempts. Try again later.';
          break;

        default:
          message = e.message ?? 'Login failed.';
      }

      return LoginResult.failure(message);
    }

    // =====================================================
    // FIRESTORE ERROR
    // =====================================================

    on FirebaseException catch (e) {
      print('Firestore Error: ${e.code}');
      print('Message: ${e.message}');

      return LoginResult.failure(
        'Database error: ${e.message ?? e.code}',
      );
    }

    // =====================================================
    // OTHER ERROR
    // =====================================================

    catch (e) {
      print('Login Error: $e');

      return LoginResult.failure(
        'Something went wrong: $e',
      );
    }
  }

  // =====================================================
  // FORGOT PASSWORD
  // =====================================================

  Future<LoginResult> forgotPassword(
    String email,
  ) async {
    try {
      final bool success =
          await authService.resetPassword(
        email.trim(),
      );

      if (success) {
        return LoginResult.successMessage(
          'Password reset email sent. Check your inbox.',
        );
      }

      return LoginResult.failure(
        'Unable to send password reset email.',
      );
    } catch (e) {
      print('Password Reset Error: $e');

      return LoginResult.failure(
        'Error: $e',
      );
    }
  }

  // =====================================================
  // FORMAT ROLE FOR DISPLAY
  // =====================================================

  String _formatRole(String role) {
    if (role.isEmpty) {
      return 'Unknown';
    }

    return role[0].toUpperCase() +
        role.substring(1);
  }
}

// =======================================================
// LOGIN RESULT
// =======================================================

class LoginResult {
  final bool isSuccess;
  final String message;

  final User? user;
  final String? name;
  final String? role;

  LoginResult({
    required this.isSuccess,
    required this.message,
    this.user,
    this.name,
    this.role,
  });

  // Successful login
  factory LoginResult.success({
    required User user,
    required String name,
    required String role,
  }) {
    return LoginResult(
      isSuccess: true,
      message: 'Login successful',
      user: user,
      name: name,
      role: role,
    );
  }

  // Successful operation with message
  factory LoginResult.successMessage(
    String message,
  ) {
    return LoginResult(
      isSuccess: true,
      message: message,
    );
  }

  // Failed operation
  factory LoginResult.failure(
    String message,
  ) {
    return LoginResult(
      isSuccess: false,
      message: message,
    );
  }
}

