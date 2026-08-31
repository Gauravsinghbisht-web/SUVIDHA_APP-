import 'package:flutter/material.dart';

class UserActions extends StatelessWidget {
  const UserActions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,

      child: ElevatedButton.icon(
        onPressed: () {
          // Worker search will be added later
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
    );
  }
}
