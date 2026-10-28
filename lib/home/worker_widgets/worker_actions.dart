// TODO Implement this library.

import 'package:flutter/material.dart';
import '../worker/add_service_screen.dart';

class WorkerActions extends StatelessWidget {
  const WorkerActions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        // =============================================
        // SERVICE PROFILE TITLE
        // =============================================

        const Text('Your Services',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        // =============================================
        // ADD SERVICE BUTTON
        // =============================================
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddServiceScreen(),
                ),
              );
            },

            icon: const Icon(Icons.add),
            label: const Text('Add Your Service',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
          ),
        ),

        const SizedBox(height: 15),

        // =============================================
        // SERVICE REQUEST BUTTON
        // =============================================

      ],
    );
  }
}

