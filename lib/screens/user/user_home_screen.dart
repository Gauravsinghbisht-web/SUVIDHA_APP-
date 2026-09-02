

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/user/user/service_results_screen.dart';
import 'package:flutter_application_1/screens/user/user_profile_screen.dart';
import 'package:flutter_application_1/screens/user/user_requests_screen.dart';
import 'package:flutter_application_1/views/search/service_search_bar.dart';
import 'package:flutter_application_1/screens/user/user_requests_screen.dart';
import 'package:flutter_application_1/screens/user/user_profile_screen.dart';

class UserHomeScreen extends StatefulWidget {
  final String name;

  const UserHomeScreen({
    super.key,
    required this.name,
  });

  @override
  State<UserHomeScreen> createState() =>
      _UserHomeScreenState();
}

class _UserHomeScreenState
    extends State<UserHomeScreen> {

  // =====================================================
  // VARIABLES
  // =====================================================
  int _currentIndex = 0;
  final TextEditingController searchController =
      TextEditingController();

  // =====================================================
  // DISPOSE
  // =====================================================
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // =====================================================
  // SEARCH SERVICE
  // =====================================================
  void searchService(String value) {
    final String serviceType = value.trim();

    if (serviceType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a service name.',
          ),
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ServiceResultsScreen(
          serviceType: serviceType,
        ),
      ),
    );
  }

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
            'What service do you need today?',

            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 30),

          // =============================================
          // SEARCH BAR
          // =============================================

          ServiceSearchBar(
            controller: searchController,

            onChanged: (value) {
              // Search text changes here.
            },

            onSubmitted: searchService,
          ),

          const SizedBox(height: 30),

          // =============================================
          // POPULAR SERVICES
          // =============================================

          const Text(
            'Popular Services',

            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          // =============================================
          // SERVICE GRID
          // =============================================

          GridView.count(
            crossAxisCount: 2,

            shrinkWrap: true,

            physics:
                const NeverScrollableScrollPhysics(),

            crossAxisSpacing: 15,

            mainAxisSpacing: 15,

            childAspectRatio: 1.2,

            children: [

              // PLUMBER
              _serviceCard(
                icon: Icons.plumbing,
                title: 'Plumber',
              ),

              // ELECTRICIAN
              _serviceCard(
                icon:
                    Icons.electrical_services,
                title: 'Electrician',
              ),

              // CLEANER
              _serviceCard(
                icon:
                    Icons.cleaning_services,
                title: 'Cleaner',
              ),

              // CARPENTER
              _serviceCard(
                icon: Icons.handyman,
                title: 'Carpenter',
              ),
            ],
          ),

          const SizedBox(height: 30),

          // =============================================
          // FIND WORKER BUTTON
          // =============================================

          SizedBox(
            width: double.infinity,

            height: 55,

            child: ElevatedButton.icon(
              onPressed: () {
                searchService(
                  searchController.text,
                );
              },

              icon: const Icon(
                Icons.search,
              ),

              label: const Text(
                'Find a Worker',

                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ALL USER SCREENS
  // =====================================================

  List<Widget> get _screens {
    return [

      // INDEX 0
      // HOME
      _homeScreen(),

      // INDEX 1
      // REQUESTS
      const UserRequestsScreen(),

      // INDEX 2
      // PROFILE
      const UserProfileScreen(),
    ];
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ===================================================
      // APP BAR
      // ===================================================

      appBar: AppBar(
        title: const Text(
          'Suvidha',
        ),

        centerTitle: true,

        automaticallyImplyLeading: false,

        actions: [

          // PROFILE ICON
          IconButton(
            onPressed: () {
              setState(() {
                _currentIndex = 2;
              });
            },

            icon: const Icon(
              Icons.person_outline,
            ),
          ),
        ],
      ),

      // ===================================================
      // BODY
      // ===================================================

      body: IndexedStack(
        index: _currentIndex,

        children: _screens,
      ),

      // ===================================================
      // BOTTOM NAVIGATION
      // ===================================================

      bottomNavigationBar:
          BottomNavigationBar(

        currentIndex: _currentIndex,

        onTap: (index) {

          setState(() {
            _currentIndex = index;
          });

        },

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

  // =====================================================
  // SERVICE CARD
  // =====================================================

  Widget _serviceCard({
    required IconData icon,
    required String title,
  }) {

    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(15),
      ),

      child: InkWell(
        borderRadius:
            BorderRadius.circular(15),

        onTap: () {

          searchService(title);

        },

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            // ICON
            Icon(
              icon,
              size: 38,
            ),

            const SizedBox(height: 10),

            // SERVICE NAME
            Text(
              title,

              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

