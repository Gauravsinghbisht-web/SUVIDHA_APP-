
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/services/location_service.dart';
import '../../home/worker_widgets/worker_availability_card.dart';
import '../../home/worker_widgets/worker_overview.dart';
import '../../home/worker_widgets/worker_actions.dart';
import 'worker_request_screen.dart';
import 'worker_chat_screen.dart';
import 'worker_profile_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  final String name;

  const WorkerHomeScreen({
    super.key,
    required this.name,
  });

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  // =====================================================
  // LOCATION SERVICE
  // =====================================================
  final LocationService _locationService = LocationService();

  // =====================================================
  // CURRENT TAB
  // =====================================================
  int _currentIndex = 0;

  // =====================================================
  // INIT STATE
  // =====================================================
  @override
  void initState() {
    super.initState();

    // Get and save worker location
    _saveWorkerLocation();
  }

  // =====================================================
  // SAVE WORKER LOCATION TO FIRESTORE
  // =====================================================
  Future<void> _saveWorkerLocation() async {
    // Get currently logged-in Firebase user
    final User? user = FirebaseAuth.instance.currentUser;

    // Check whether worker is logged in
    if (user == null) {
      print('No logged-in worker found.');
      return;
    }

    try {
      // Get current GPS location
      final position = await _locationService.getCurrentLocation();

      // Check whether location was obtained
      if (position == null) {
        print('Could not get worker location.');
        return;
      }

      // Update worker's location in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });

      print('Worker location saved successfully!');
      print('Latitude: ${position.latitude}');
      print('Longitude: ${position.longitude}');
    } catch (e) {
      print('Error saving worker location: $e');
    }
  }

  // =====================================================
  // HOME SCREEN
  // =====================================================
  Widget _homeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =============================================
          // WELCOME
          // =============================================
          Text(
            'Hello, ${widget.name} 👋',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Manage your services and requests.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 30),

          // =============================================
          // AVAILABILITY
          // =============================================
          const WorkerAvailabilityCard(),

          const SizedBox(height: 25),
          // =============================================
          // OVERVIEW
          // =============================================
          const WorkerOverview(),

          const SizedBox(height: 30),

          // =============================================
          // ACTIONS
          // =============================================
          const WorkerActions(),
        ],
      ),
    );
  }

  // =====================================================
  // SCREEN LIST
  // =====================================================
  List<Widget> get _screens {
    return [
      // 0 - HOME
      _homeScreen(),

      // 1 - REQUESTS
      const WorkerRequestsScreen(),

      // 2 - CHATS
      WorkerChatScreen(),

      // 3 - PROFILE
      const WorkerProfileScreen(),
    ];
  }

  // =====================================================
  // BUILD
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // =================================================
      // APP BAR
      // =================================================
      appBar: AppBar(
        title: const Text(
          'Suvidha',
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              // Profile action can be added later.
            },
            icon: const Icon(
              Icons.person_outline,
            ),
          ),
        ],
      ),

      // =================================================
      // BODY
      // =================================================
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // =================================================
      // BOTTOM NAVIGATION
      // =================================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        // ===============================================
        // NAVIGATION COLORS
        // ===============================================
        backgroundColor: const Color(0xFF1565C0),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        // Keep all 4 items visible
        type: BottomNavigationBarType.fixed,

        // ===============================================
        // ITEMS
        // ===============================================

        items: const [
          // =============================================
          // HOME
          // =============================================
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
            ),
            activeIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),

          // =============================================
          // REQUESTS
          // =============================================
          BottomNavigationBarItem(
            icon: Icon(
              Icons.assignment_outlined,
            ),
            activeIcon: Icon(
              Icons.assignment,
            ),
            label: 'Requests',
          ),

          // =============================================
          // CHATS
          // ============================================
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat_bubble_outline,
            ),
            activeIcon: Icon(
              Icons.chat_bubble,
            ),
            label: 'Chats',
          ),

          // =============================================
          // PROFILE
          // =============================================
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
            ),
            activeIcon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
