import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConstants {
  // Premium Nature Palette
  static const Color forestGreen = Color(0xFF1B5E20); // Deep Forest Green
  static const Color primaryGreen = forestGreen;
  static const Color creamApp = Color(0xFFF9F6F0); // Premium ivory background
  static const Color paleGreen = Color(0xFFE8F5E9); // Soft light green
  static const Color headingOrange = Color(0xFFE65100); // Professional orange for sub-headings
  static const Color accentGold = Color(0xFFD4AF37); // Metallic Gold
  
  static const Color surfaceWhite = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF757575);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      primary: primaryGreen,
      secondary: headingOrange,
      surface: surfaceWhite,
      onSurface: textDark,
      // background is deprecated, use surface variant or background in Scaffold
    ),
    scaffoldBackgroundColor: creamApp,
    textTheme: GoogleFonts.outfitTextTheme().apply(
      bodyColor: textDark,
      displayColor: textDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textDark,
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  );
}
