
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/worker/worker_request_screen.dart';
import '../../home/worker_widgets/worker_availability_card.dart';
import '../../home/worker_widgets/worker_overview.dart';
import '../../home/worker_widgets/worker_actions.dart';
import 'package:flutter_application_1/screens/worker/worker_request_screen.dart';

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

class _WorkerHomeScreenState
    extends State<WorkerHomeScreen> {

  // =====================================================
  // CURRENT TAB
  // =====================================================

  int _currentIndex = 0;

  // =====================================================
  // HOME SCREEN
  // =====================================================

  Widget _homeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

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
      _homeScreen(),

      const WorkerRequestsScreen(),

      const Center(
        child: Text(
          'Worker Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
        title: const Text('Suvidha'),

        centerTitle: true,

        automaticallyImplyLeading: false,

        actions: [
          IconButton(
            onPressed: () {
              // Profile will be added later.
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

        items: const [

          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
            ),

            activeIcon: Icon(
              Icons.home,
            ),

            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.assignment_outlined,
            ),

            activeIcon: Icon(
              Icons.assignment,
            ),

            label: 'Requests',
          ),

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

