import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../auth/login/login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 70),

              // =====================================================
              // APP NAME
              // =====================================================

              Text(
                'SUVIDHA',
                style: theme.textTheme.headlineLarge,
              ),

              const SizedBox(height: 12),

              // =====================================================
              // SUBTITLE
              // =====================================================

              Text(
                'How can we help you?',
                style: theme.textTheme.titleLarge,
              ),

              const SizedBox(height: 50),

              // =====================================================
              // USER ROLE
              // =====================================================

              _RoleCard(
                role: UserRole.user,
                icon: Icons.person_outline,
                title: "I'm a User",
                subtitle: 'Find & book local service providers',
                onTap: (role) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(
                        role: role,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // =====================================================
              // WORKER ROLE
              // =====================================================

              _RoleCard(
                role: UserRole.worker,
                icon: Icons.handyman_outlined,
                title: "I'm a Worker",
                subtitle: 'Offer your services and get bookings',
                onTap: (role) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(
                        role: role,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// ROLE CARD
// =====================================================

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final IconData icon;
  final String title;
  final String subtitle;
  final void Function(UserRole role) onTap;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        onTap(role);
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // =====================================================
              // ROLE ICON
              // =====================================================

              Icon(
                icon,
                size: 48,
                color: theme.colorScheme.primary,
              ),

              const SizedBox(width: 20),

              // =====================================================
              // ROLE TEXT
              // =====================================================

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              // =====================================================
              // ARROW
              // =====================================================

              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}