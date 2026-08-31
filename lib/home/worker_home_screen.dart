
import 'package:flutter/material.dart';

import 'worker_widgets/worker_availability_card.dart';
import 'worker_widgets/worker_overview.dart';
import 'worker_widgets/worker_actions.dart';

class WorkerHomeScreen extends StatelessWidget {
  final String name;

  const WorkerHomeScreen({
    super.key,
    required this.name,
  });

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
              // Profile will be added later
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // =============================================
            // WELCOME
            // =============================================

            Text(
              'Hello, $name 👋',

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
      ),

      // =================================================
      // BOTTOM NAVIGATION
      // =================================================

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,

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

