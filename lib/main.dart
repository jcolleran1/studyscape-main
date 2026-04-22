import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    // App still runs so you can see UI work if Firebase init fails.
    // Firestore streams will error silently — markers fall back to seed values.
    debugPrint('Firebase init failed: $e');
  }
  runApp(const StudyScapeApp());
}

class StudyScapeApp extends StatelessWidget {
  const StudyScapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyScape',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF212B58)),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}