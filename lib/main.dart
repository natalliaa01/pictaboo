import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/welcome/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
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
