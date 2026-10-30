

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/services/location_service.dart';
import 'package:flutter_application_1/widgets/notification_dot.dart';
import '../../home/worker_widgets/worker_availability_card.dart';
import '../../home/worker_widgets/worker_overview.dart';
import '../../home/worker_widgets/worker_actions.dart';
import 'worker_request_screen.dart';
import 'worker_chat_screen.dart';
import 'worker_profile_screen.dart';
import 'worker_notifications_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  final String name;

  const WorkerHomeScreen({
    super.key,
    required this.name,
  });

  @override
  State<WorkerHomeScreen> createState() =>
      _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  final LocationService _locationService = LocationService();

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _saveWorkerLocation();
  }

  // SAVE WORKER LOCATION TO FIRESTORE
  Future<void> _saveWorkerLocation() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('No logged-in worker found.');
      return;
    }

    try {
      final position =
          await _locationService.getCurrentLocation();

      if (position == null) {
        debugPrint('Could not get worker location.');
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });

      debugPrint('Worker location saved successfully!');
      debugPrint('Latitude: ${position.latitude}');
      debugPrint('Longitude: ${position.longitude}');
    } catch (e) {
      debugPrint('Error saving worker location: $e');
    }
  }

  // NAVIGATION ICON WITH NOTIFICATION DOTS
  Widget _workerNavIcon(
    IconData icon, {
    bool showRequests = false,
    bool showChats = false,
  }) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (user != null && showRequests)
          PendingRequestDot(workerId: user.uid),
        if (user != null && showChats)
          UnreadChatDot(userId: user.uid),
      ],
    );
  }

  // RETURN TO HOME TAB
  void _backToHome() {
    if (!mounted) return;

    setState(() {
      _currentIndex = 0;
    });
  }

  // HOME SCREEN
  Widget _homeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          const WorkerAvailabilityCard(),

          const SizedBox(height: 25),

          WorkerOverview(
            onRequestsTap: () {
              setState(() {
                _currentIndex = 1;
              });
            },
          ),

          const SizedBox(height: 30),

          const WorkerActions(),
        ],
      ),
    );
  }

  // SCREEN LIST
  List<Widget> get _screens {
    return [
      _homeScreen(),

      WorkerRequestsScreen(
        onBackToHome: _backToHome,
      ),

      WorkerChatScreen(
        onBackToHome: _backToHome,
      ),

      WorkerProfileScreen(
        onBackToHome: _backToHome,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EASY'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        
actions: [
  // Notifications bell with live unread count
  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: FirebaseAuth.instance.currentUser == null
        ? null
        : FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('notifications')
            .where('isRead', isEqualTo: false)
            .snapshots(),
    builder: (context, snapshot) {
      final unreadCount = snapshot.data?.docs.length ?? 0;

      return IconButton(
        tooltip: 'Notifications',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const WorkerNotificationsScreen(),
            ),
          );
        },
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_outlined),
            if (unreadCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      );
    },
  ),

  // Existing profile button
  IconButton(
    onPressed: () {
      setState(() {
        _currentIndex = 3;
      });
    },
    icon: const Icon(Icons.person_outline),
  ),
],

      ),

      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF1565C0),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: _workerNavIcon(
              Icons.assignment_outlined,
              showRequests: true,
            ),
            activeIcon: _workerNavIcon(
              Icons.assignment,
              showRequests: true,
            ),
            label: 'Requests',
          ),

          BottomNavigationBarItem(
            icon: _workerNavIcon(
              Icons.chat_bubble_outline,
              showChats: true,
            ),
            activeIcon: _workerNavIcon(
              Icons.chat_bubble,
              showChats: true,
            ),
            label: 'Chats',
          ),

          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
