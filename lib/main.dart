
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // =====================================================
  // FIREBASE INITIALIZATION
  // =====================================================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('Firebase initialized successfully.');

  // =====================================================
  // START APP FIRST
  // =====================================================
  runApp(
    const SuvidhaApp(),
  );

  // =====================================================
  // FIREBASE APP CHECK
  // =====================================================
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );

    debugPrint('Firebase App Check activated successfully.');
  } catch (e) {
    debugPrint('Firebase App Check error: $e');
  }
}

// =======================================================
// SUVIDHA APP
// =======================================================
class SuvidhaApp extends StatelessWidget {
  const SuvidhaApp({
    super.key,
  });

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
