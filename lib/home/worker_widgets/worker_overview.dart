
import 'package:flutter/material.dart';

class WorkerOverview extends StatelessWidget {
  const WorkerOverview({
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
          'Overview',

          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        // =============================================
        // FIRST ROW
        // =============================================

        Row(
          children: [

            Expanded(
              child: _StatCard(
                icon: Icons.assignment,
                title: 'Requests',
                value: '0',
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: _StatCard(
                icon: Icons.work_outline,
                title: 'Jobs',
                value: '0',
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        // =============================================
        // SECOND ROW
        // =============================================

        Row(
          children: [

            Expanded(
              child: _StatCard(
                icon: Icons.star_outline,
                title: 'Rating',
                value: '0.0',
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: _StatCard(
                icon: Icons.currency_rupee,
                title: 'Earnings',
                value: '₹0',
              ),
            ),
          ],
        ),
      ],
    );
  }
}


// =====================================================
// STAT CARD
// =====================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // =======================================
            // ICON
            // =======================================

            Icon(
              icon,
              size: 30,
            ),

            const SizedBox(height: 12),

            // =======================================
            // VALUE
            // =======================================

            Text(
              value,

              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            // =======================================
            // TITLE
            // =======================================

            Text(
              title,

              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

