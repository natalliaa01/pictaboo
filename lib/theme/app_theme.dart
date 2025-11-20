import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryPink = Color(0xFFAD2F6B);
  static const Color softPink1 = Color(0xFFFBD1DC);
  static const Color softPink2 = Color(0xFFF5B7C6);
  static const Color accentPurple = Color(0xFF5B2B78);

  static ThemeData lightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryPink),
      scaffoldBackgroundColor: softPink1,
      primaryColor: primaryPink,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: primaryPink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: primaryPink,
        ),
      ),

      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        headlineSmall: GoogleFonts.poppins(
            fontSize: 22, fontWeight: FontWeight.w700, color: accentPurple),
        titleLarge: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w600, color: accentPurple),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
        labelLarge: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 2,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryPink,
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.white,
        elevation: 6,
      ), // ← KOMA WAJIB DI SINI

      cardTheme: const CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 2,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
      ),
    );
  }
}
