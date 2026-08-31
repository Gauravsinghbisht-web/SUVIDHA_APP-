import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================
  // SIGN UP
  // =========================
  Future<User?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      // 1. Create account in Firebase Authentication
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? user = credential.user;

      if (user == null) {
        return null;
      }

      // 2. Save additional user information in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      print('Firebase Signup Error: ${e.code}');
      print('Message: ${e.message}');
      return null;
    } on FirebaseException catch (e) {
      print('Firestore Error: ${e.code}');
      print('Message: ${e.message}');
      return null;
    } catch (e) {
      print('Signup Error: $e');
      return null;
    }
  }

  // =========================
  // LOGIN
  // =========================
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      return credential.user;
    } on FirebaseAuthException catch (e) {
      print('Firebase Login Error: ${e.code}');
      print('Message: ${e.message}');
      return null;
    } catch (e) {
      print('Login Error: $e');
      return null;
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // =========================
  // CURRENT USER
  // =========================
  User? get currentUser {
    return _auth.currentUser;
  }

  // =========================
  // CHECK LOGIN STATUS
  // =========================
  bool get isLoggedIn {
    return _auth.currentUser != null;
  }

  // =========================
  // RESET PASSWORD
  // =========================
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );

      return true;
    } on FirebaseAuthException catch (e) {
      print('Password Reset Error: ${e.code}');
      print('Message: ${e.message}');
      return false;
    } catch (e) {
      print('Password Reset Error: $e');
      return false;
    }
  }
}