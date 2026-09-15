
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';
import '../models/user_role.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final LocationService _locationService = LocationService();

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
    try {
      // 1. Create Firebase Authentication account
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;

      if (user == null) {
        return null;
      }

      // 2. Get current device location
      Position? position =
          await _locationService.getCurrentLocation();

      // 3. Create user data
      Map<String, dynamic> userData = {
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'role': role.name,
        'isAvailable':
            role == UserRole.worker ? true : false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 4. Save latitude and longitude
      if (position != null) {
        userData['latitude'] = position.latitude;
        userData['longitude'] = position.longitude;
      }

      // 5. Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData);

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(
        e.message ?? 'Signup failed',
      );
    } catch (e) {
      throw Exception(
        'Signup failed: $e',
      );
    }
  }

  // =====================================================
  // LOGIN
  // =====================================================

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(
        e.message ?? 'Login failed',
      );
    } catch (e) {
      throw Exception(
        'Login failed: $e',
      );
    }
  }

  // =====================================================
  // GET USER ROLE
  // =====================================================

  Future<UserRole?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore
              .collection('users')
              .doc(uid)
              .get();

      if (!doc.exists) {
        return null;
      }

      final data =
          doc.data() as Map<String, dynamic>;

      final role = data['role'];

      if (role == 'user') {
        return UserRole.user;
      }

      if (role == 'worker') {
        return UserRole.worker;
      }

      return null;
    } catch (e) {
      throw Exception(
        'Unable to get user role: $e',
      );
    }
  }

  // =====================================================
  // RESET PASSWORD
  // =====================================================

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );

      return true;
    } on FirebaseAuthException catch (e) {
      print(
        'Password Reset Error: ${e.code}',
      );
      print(
        'Message: ${e.message}',
      );

      return false;
    } catch (e) {
      print(
        'Password Reset Error: $e',
      );

      return false;
    }
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> logout() async {
    await _auth.signOut();
  }

  // =====================================================
  // CURRENT USER
  // =====================================================

  User? get currentUser {
    return _auth.currentUser;
  }
}
