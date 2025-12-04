import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://snbblfyjxefxivuuyqid.supabase.co'; // Ganti dengan URL Supabase kamu
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNuYmJsZnlqeGVmeGl2dXV5cWlkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ4MzE4NDQsImV4cCI6MjA4MDQwNzg0NH0.nxrT7CEjbqj7tlpMiCH8K-M94ePY07z2nixOC6J5E2w';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}
