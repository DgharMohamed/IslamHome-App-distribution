import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Colors (Al Mosaly Inspired)
  static const primaryColor = Color(0xFFD4AF37); // Gold
  static const secondaryColor = Color(0xFF1A237E); // Deep Navy
  static const darkBlue = Color(0xFF0F172A);
  static const darkBurgundy = Color(0xFF2D1212);
  static const surfaceColor = Color(0xFF1E293B);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF94A3B8);
  static const textColor = Color(0xFF0F172A);
  static const backgroundColor = darkBlue;
  static const quranBackground = Color(0xFFF3E5AB); // Beige

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: Color(0xFFE91E63),
        onPrimary: Colors.black,
        onSurface: textPrimary,
      ),
      cardTheme: const CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      textTheme: GoogleFonts.tajawalTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: GoogleFonts.cairo(
            fontWeight: FontWeight.w900,
            color: textPrimary,
          ),
          displayMedium: GoogleFonts.cairo(
            fontWeight: FontWeight.w900,
            color: textPrimary,
          ),
          displaySmall: GoogleFonts.cairo(
            fontWeight: FontWeight.w900,
            color: textPrimary,
          ),
          headlineLarge: GoogleFonts.cairo(
            fontWeight: FontWeight.w900,
            color: textPrimary,
          ),
          headlineMedium: GoogleFonts.cairo(
            fontWeight: FontWeight.w900,
            color: textPrimary,
          ),
          titleLarge: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          bodyLarge: GoogleFonts.tajawal(color: textPrimary),
          bodyMedium: GoogleFonts.tajawal(color: textSecondary),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0F172A), // Dark Navy
        selectedItemColor: primaryColor, // Gold for active
        unselectedItemColor: Color(0xFF64748B), // Muted for inactive
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}
