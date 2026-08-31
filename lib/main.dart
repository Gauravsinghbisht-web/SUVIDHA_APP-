
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home/worker_profile/worker_profile_screen.dart';
import 'package:flutter_application_1/providers/service_request_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'providers/service_provider.dart';
import 'views/role_selection/role_selection_screen.dart';
import 'firebase_options.dart';
import 'providers/service_request_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Connect Flutter application to Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
          create: (_) => AuthViewModel()),
        ChangeNotifierProvider(
          create: (_) => ServiceProvider()),
        ChangeNotifierProvider(
          create: (_) => ServiceRequestProvider()),
          ],
          
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Suvidha',
        home: const RoleSelectionScreen(),
      ),
    );
  }
}
