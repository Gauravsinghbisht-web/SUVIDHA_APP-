

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'providers/service_provider.dart';
import 'providers/service_request_provider.dart';
import 'views/role_selection/role_selection_screen.dart';
import 'screens/gemini_test_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check
debugPrint('Starting Firebase App Check...');

  await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.debug,
  appleProvider: AppleProvider.debug,
);

  runApp(
    const SuvidhaApp(),
  ); 
}

class SuvidhaApp extends StatelessWidget {
  const SuvidhaApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        ChangeNotifierProvider(
          create: (_) => AuthViewModel(),  // it is for Authentication 
        ),

        ChangeNotifierProvider(
          create: (_) => ServiceProvider(),  // it is for Service
        ),

        ChangeNotifierProvider(
          create: (_) => ServiceRequestProvider(),  // it is for Service Request 
        ),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Suvidha',
        theme : AppTheme.lightTheme,
        home: const RoleSelectionScreen(),
      ),
    );
  }
}
