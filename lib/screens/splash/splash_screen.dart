
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  // =====================================================
  // INIT
  // =====================================================
  @override
  void initState() {
    super.initState();
    _startSplash();
  }

  // =====================================================
  // SPLASH TIMER
  // =====================================================
  Future<void> _startSplash() async {
    await Future.delayed(
      const Duration(seconds: 3),
    );

    if (!mounted) return;
    _checkLoginStatus();
  }

  // =====================================================
  // CHECK LOGIN STATUS
  // =====================================================
  void _checkLoginStatus() {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // User is already logged in.
      //
      // We will connect the correct
      // User/Worker home screen here.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPlaceholderScreen(),
        ),
      );
    } else {
      // User is not logged in.
      //
      // We will connect your existing
      // role selection/login screen here.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPlaceholderScreen(),
        ),
      );
    }
  }

  // =====================================================
  // BUILD
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            // ===========================================
            // APP ICON
            // ===========================================
            Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(25),
                border: Border.all(
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.home_repair_service,
                size: 65,
              ),
            ),

            const SizedBox(height: 25),

            // ===========================================
            // APP NAME
            // ===========================================
            const Text(
              'Suvidha',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // ===========================================
            // TAGLINE
            // ===========================================
            Text(
              'Services made simple',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 40),

            // ===========================================
            // LOADING
            // ===========================================
            const SizedBox(
              height: 25,
              width: 25,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// TEMPORARY SCREEN
// =======================================================
//
// We will remove this screen after connecting
// SplashScreen to your actual login/role screen.
//
class LoginPlaceholderScreen
  extends StatelessWidget {
  const LoginPlaceholderScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Next Screen',
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}

