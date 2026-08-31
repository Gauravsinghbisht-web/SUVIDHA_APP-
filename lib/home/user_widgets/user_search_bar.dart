
import 'package:flutter/material.dart';

class UserSearchBar extends StatelessWidget {
  const UserSearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search for a service',

        prefixIcon: const Icon(
          Icons.search,
        ),

        filled: true,

        fillColor: Colors.grey.shade100,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
