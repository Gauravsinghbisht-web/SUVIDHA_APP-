
import 'package:flutter/material.dart';

class AppTheme {
  // =====================================================
  // BRAND COLORS
  // =====================================================

  static const Color primaryColor = Color(0xFF1565C0);
  static const Color secondaryColor = Color(0xFF00A896);

  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color cardColor = Colors.white;

  // =====================================================
  // LIGHT THEME
  // =====================================================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // ---------------------------------------------------
    // COLOR SCHEME
    // ---------------------------------------------------

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      brightness: Brightness.light,
    ),

    // ---------------------------------------------------
    // SCAFFOLD
    // ---------------------------------------------------

    scaffoldBackgroundColor: backgroundColor,

    // ---------------------------------------------------
    // APP BAR
    // ---------------------------------------------------

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF17202A),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF17202A),
      ),
    ),

    // ---------------------------------------------------
    // CARD
    // ---------------------------------------------------

    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.zero,
    ),

    // ---------------------------------------------------
    // ELEVATED BUTTON
    // ---------------------------------------------------

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ---------------------------------------------------
    // OUTLINED BUTTON
    // ---------------------------------------------------

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        side: const BorderSide(
          color: primaryColor,
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ---------------------------------------------------
    // TEXT FIELD
    // ---------------------------------------------------

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE1E5EA),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE1E5EA),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 2,
        ),
      ),

      hintStyle: const TextStyle(
        color: Color(0xFF9AA3AE),
      ),
    ),

    // ---------------------------------------------------
    // BOTTOM NAVIGATION
    // ---------------------------------------------------

    bottomNavigationBarTheme:
        const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Color(0xFF8A94A3),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
      ),
    ),

    // ---------------------------------------------------
    // DIVIDER
    // ---------------------------------------------------

    dividerTheme: const DividerThemeData(
      color: Color(0xFFE8EBEF),
      thickness: 1,
    ),

    // ---------------------------------------------------
    // TEXT THEME
    // ---------------------------------------------------

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF17202A),
      ),

      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Color(0xFF17202A),
      ),

      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFF17202A),
      ),

      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF17202A),
      ),

      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFF344054),
      ),

      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFF667085),
      ),
    ),
  );
}