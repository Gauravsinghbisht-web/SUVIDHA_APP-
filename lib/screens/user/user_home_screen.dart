
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/user/user/service_results_screen.dart';
import 'package:flutter_application_1/screens/user/user_chat_screen.dart';
import 'package:flutter_application_1/screens/user/user_profile_screen.dart';
import 'package:flutter_application_1/screens/user/user_requests_screen.dart';
import 'package:flutter_application_1/views/search/service_search_bar.dart';
import 'package:flutter_application_1/screens/map/google_map_screen.dart';
import 'package:flutter_application_1/screens/ai_assistant_screen.dart';

class UserHomeScreen extends StatefulWidget {
  final String name;

  const UserHomeScreen({
    super.key,
    required this.name,
  });

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
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
          content: Text('Please enter a service name.'),
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceResultsScreen(
          serviceType: serviceType,
        ),
      ),
    );
  }

  // =====================================================
  // OPEN AI ASSISTANT
  // =====================================================

  void openAiAssistant() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AiAssistantScreen(),
      ),
    );
  }

  // =====================================================
  // OPEN MAP
  // =====================================================

  void openMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GoogleMapScreen(),
      ),
    );
  }

  // =====================================================
  // HOME SCREEN
  // =====================================================

  Widget _homeScreen() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================
            // WELCOME SECTION
            // =================================================

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${widget.name} 👋',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium,
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'What service do you need today?',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium,
                      ),
                    ],
                  ),
                ),

                // LOCATION ICON
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =================================================
            // SEARCH BAR
            // =================================================

            ServiceSearchBar(
              controller: searchController,
              onChanged: (value) {},
              onSubmitted: searchService,
            ),

            const SizedBox(height: 20),

            // =================================================
            // AI ASSISTANT CARD
            // =================================================

            _buildAiCard(),

            const SizedBox(height: 28),

            // =================================================
            // POPULAR SERVICES HEADER
            // =================================================

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popular Services',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge,
                ),

                TextButton(
                  onPressed: () {
                    searchController.clear();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Search for the service you need.',
                        ),
                      ),
                    );
                  },
                  child: const Text('See all'),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // =================================================
            // SERVICE GRID
            // =================================================

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.10,
              children: [
                _serviceCard(
                  icon: Icons.plumbing,
                  title: 'Plumber',
                ),

                _serviceCard(
                  icon: Icons.electrical_services,
                  title: 'Electrician',
                ),

                _serviceCard(
                  icon: Icons.cleaning_services,
                  title: 'Cleaner',
                ),

                _serviceCard(
                  icon: Icons.handyman,
                  title: 'Carpenter',
                ),
              ],
            ),

            const SizedBox(height: 25),

            // =================================================
            // NEARBY WORKERS / MAP CARD
            // =================================================

            _buildMapCard(),

            const SizedBox(height: 18),

            // =================================================
            // FIND WORKER BUTTON
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 56,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // AI ASSISTANT CARD
  // =====================================================

  Widget _buildAiCard() {
    final primary =
        Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary,
            primary.withValues(alpha: 0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.20),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          // AI ICON
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 15),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Not sure what you need?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Describe your problem and let AI help you.',
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.85,
                    ),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // AI BUTTON
          IconButton(
            onPressed: openAiAssistant,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primary,
            ),
            icon: const Icon(
              Icons.arrow_forward,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // MAP CARD
  // =====================================================

  Widget _buildMapCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.orange,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find workers near you',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'View available workers on the map',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: openMap,
            icon: const Icon(
              Icons.arrow_forward_ios,
              size: 18,
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
      // INDEX 0: HOME
      _homeScreen(),

      // INDEX 1: REQUESTS
      const UserRequestsScreen(),

      // INDEX 2: CHATS
      UserChatScreen(),

      // INDEX 3: PROFILE
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
          IconButton(
            onPressed: () {
              setState(() {
                _currentIndex = 3;
              });
            },
            icon: const Icon(
              Icons.person_outline,
            ),
          ),

          const SizedBox(width: 8),
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

        selectedItemColor:
            Theme.of(context)
                .colorScheme
                .primary,

        unselectedItemColor:
            Colors.grey.shade500,

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        items: const [
          // HOME
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
            ),
            activeIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),

          // REQUESTS
          BottomNavigationBarItem(
            icon: Icon(
              Icons.assignment_outlined,
            ),
            activeIcon: Icon(
              Icons.assignment,
            ),
            label: 'Requests',
          ),

          // CHATS
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat_outlined,
            ),
            activeIcon: Icon(
              Icons.chat,
            ),
            label: 'Chats',
          ),

          // PROFILE
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
    final primary =
        Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          searchService(title);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.035,
                ),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              // ICON
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: primary.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: primary,
                ),
              ),

              const SizedBox(height: 12),

              // SERVICE NAME
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Book now',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
