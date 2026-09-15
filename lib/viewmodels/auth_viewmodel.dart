
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // =====================================================
  // STATE
  // =====================================================

  bool _isLoading = false;

  String? _errorMessage;

  String? _userName;

  String? _userRole;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String? get userName => _userName;

  String? get userRole => _userRole;

  User? get currentUser => _authService.currentUser;

  // =====================================================
  // LOGIN
  // =====================================================

  Future<bool> login({
    required String email,
    required String password,
    required UserRole selectedRole,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      // -------------------------------------------------
      // 1. Firebase Authentication
      // -------------------------------------------------

      final User? user = await _authService.login(
        email: email.trim(),
        password: password.trim(),
      );

      if (user == null) {
        _errorMessage =
            'Login failed. Please check your email and password.';

        return false;
      }

      // -------------------------------------------------
      // 2. Get User Profile From Firestore
      // -------------------------------------------------

      final DocumentSnapshot userDocument =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!userDocument.exists) {
        _errorMessage =
            'User profile not found in Firestore.';

        return false;
      }

      // -------------------------------------------------
      // 3. Read User Data
      // -------------------------------------------------

      final Map<String, dynamic> userData =
          userDocument.data() as Map<String, dynamic>;

      _userName =
          userData['name']?.toString() ?? '';

      _userRole =
          userData['role']?.toString().toLowerCase() ?? '';

      // -------------------------------------------------
      // 4. Check Selected Role
      // -------------------------------------------------

      final String selectedRoleName =
          selectedRole.name;

      if (_userRole != selectedRoleName) {
        _errorMessage =
            'This account is registered as '
            '${_formatRole(_userRole ?? '')}, '
            'not ${_formatRole(selectedRoleName)}.';

        return false;
      }

      // -------------------------------------------------
      // 5. Login Successful
      // -------------------------------------------------

      return true;
    }

    // ===================================================
    // FIREBASE AUTH ERROR
    // ===================================================

    on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _errorMessage =
              'No account found with this email.';
          break;

        case 'wrong-password':
        case 'invalid-credential':
          _errorMessage =
              'Incorrect email or password.';
          break;

        case 'invalid-email':
          _errorMessage =
              'Please enter a valid email.';
          break;

        case 'user-disabled':
          _errorMessage =
              'This account has been disabled.';
          break;

        case 'too-many-requests':
          _errorMessage =
              'Too many attempts. Try again later.';
          break;

        default:
          _errorMessage =
              e.message ?? 'Login failed.';
      }

      return false;
    }

    // ===================================================
    // FIREBASE / FIRESTORE ERROR
    // ===================================================

    on FirebaseException catch (e) {
      _errorMessage =
          'Database error: ${e.message ?? e.code}';

      return false;
    }

    // ===================================================
    // OTHER ERROR
    // ===================================================

    catch (e) {
      _errorMessage =
          'Something went wrong: $e';

      return false;
    }

    // ===================================================
    // FINALLY
    // ===================================================

    finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // =====================================================
  // SIGN UP
  // =====================================================

  Future<User?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final User? user =
          await _authService.signUp(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );

      return user;
    } catch (e) {
      _errorMessage = e.toString();

      return null;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // =====================================================
  // FORGOT PASSWORD
  // =====================================================

  Future<bool> resetPassword(
    String email,
  ) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final bool success =
          await _authService.resetPassword(
        email.trim(),
      );

      if (!success) {
        _errorMessage =
            'Unable to send password reset email.';
      }

      return success;
    } catch (e) {
      _errorMessage =
          'Something went wrong while resetting your password.';

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> logout() async {
    await _authService.logout();

    _userName = null;
    _userRole = null;
    _errorMessage = null;

    notifyListeners();
  }

  // =====================================================
  // CLEAR ERROR
  // =====================================================

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }

  // =====================================================
  // FORMAT ROLE
  // =====================================================

  String _formatRole(String role) {
    if (role.isEmpty) {
      return 'Unknown';
    }

    return role[0].toUpperCase() +
        role.substring(1);
  }
}
