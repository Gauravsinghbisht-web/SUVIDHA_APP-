

import 'package:flutter/material.dart';

class AppNavigation {
  static void goToHome(BuildContext context) {
    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }
  
  static Widget homeBackButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => goToHome(context),
      tooltip: 'Back to Home',
    );
  }
}
