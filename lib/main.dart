import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/welcome/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PictABooApp());
}

class PictABooApp extends StatelessWidget {
  const PictABooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pict A Boo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      home: const WelcomeScreen(),
    );
  }
}
