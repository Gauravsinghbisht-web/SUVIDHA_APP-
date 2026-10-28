

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'providers/service_provider.dart';
import 'providers/service_request_provider.dart';
import 'views/role_selection/role_selection_screen.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('Firebase initialized successfully.');

  // 2. Activate Firebase App Check.
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );

    debugPrint('Firebase App Check activated successfully.');
  } catch (e, stackTrace) {
    debugPrint('Firebase App Check activation error: $e');
    debugPrintStack(stackTrace: stackTrace);
  }

  // 3. Initialize push notifications.
  // NotificationService catches token retrieval errors internally.
  try {
    await NotificationService.initialize();
  } catch (e, stackTrace) {
    debugPrint('Notification initialization error: $e');
    debugPrintStack(stackTrace: stackTrace);
  }

  // 4. Start the app.
  runApp(const SuvidhaApp());
}

class SuvidhaApp extends StatelessWidget {
  const SuvidhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ServiceProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ServiceRequestProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Suvidha',
        theme: AppTheme.lightTheme,
        home: const RoleSelectionScreen(),
      ),
    );
  }
}
