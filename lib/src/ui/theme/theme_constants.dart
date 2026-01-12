import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConstants {
  // Premium Nature Palette
  static const Color forestGreen = Color(0xFF1B5E20); // Deep Forest Green
  // Refined Color Palette
  static const Color primaryGreen = Color(0xFF1B5E20);   // Headers, Primary Buttons, Active States
  static const Color secondaryGreen = Color(0xFF2E7D32); // Prices, Positive Trends, Charts
  static const Color softGreen = Color(0xFFE8F5E9);      // subtle backgrounds, card highlights
  
  static const Color creamApp = Color(0xFFF9F6F0);       // Main Background
  static const Color textDark = Color(0xFF002117);       // Headings, Page Titles
  static const Color headingOrange = Color(0xFFD35400);  // Desaturated Base (Pumpkin)
  static const Color sectionOrange = Color(0xFFA35B3F);  // Muted, Earthy Orange for Headers
  static const Color actionOrange = Color(0xFFE67E22);   // Brighter Action Orange (Carrot)
  
  static const Color alertRed = Color(0xFFD32F2F);       // Negative Trends
  static const Color smaGold = Color(0xFFF9A825);        // Moving Averages
  static const Color neutralGrey = Color(0xFF757575);    // Soft details, info icons

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryGreen,
      secondary: headingOrange,
      surface: Colors.white,
      error: alertRed,
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
