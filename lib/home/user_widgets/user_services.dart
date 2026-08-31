import 'package:flutter/material.dart';

class UserServices extends StatelessWidget {
  const UserServices({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // =============================================
        // TITLE
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
        // SERVICES GRID
        // =============================================
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),

          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.2,
          children: const [
            ServiceCard(
              icon: Icons.plumbing,
              title: 'Plumber',
            ),

            ServiceCard(
              icon: Icons.electrical_services,
              title: 'Electrician',
            ),

            ServiceCard(
              icon: Icons.cleaning_services,
              title: 'Cleaner',
            ),

            ServiceCard(
              icon: Icons.handyman,
              title: 'Carpenter',
            ),
          ],
        ),
      ],
    );
  }
}
// =====================================================
// SERVICE CARD
// =====================================================
class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(15),

        onTap: () {
          // Service page will be added later
        },

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            // =======================================
            // ICON
            // =======================================
            Icon(
              icon,
              size: 38,
            ),

            const SizedBox(height: 10),
            // =======================================
            // TITLE
            // =======================================
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}