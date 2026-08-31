
import 'package:flutter/material.dart';

class WorkerAvailabilityCard extends StatelessWidget {
  const WorkerAvailabilityCard({
    super.key,
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

        child: Row(
          children: [

            // =========================================
            // ICON
            // =========================================

            const Icon(
              Icons.check_circle,
              size: 35,
            ),

            const SizedBox(width: 15),

            // =========================================
            // TEXT
            // =========================================

            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    'Availability',

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'You are available for work',
                  ),
                ],
              ),
            ),

            // =========================================
            // SWITCH
            // =========================================

            Switch(
              value: true,

              onChanged: (value) {
                // Availability feature
                // will be added later
              },
            ),
          ],
        ),
      ),
    );
  }
}

