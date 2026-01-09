import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PpTheme {
  // ===================== COLOR PALETTE SCIENCE =====================
  // Primary Blue: 0xFF0095F6 (calm, encourages "flow state", reduces fatigue)
  // Action Red:   0xFFFF3B30 (urgency, notifications, excitement)
  // Pure Canvas:  0xFFFFFFFF (removes friction, highlights content)

  /* ===================== LIGHT THEME — RETENTION FOCUSED ===================== */

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    // fontFamily: 'Chillax', // Replaced by GoogleFonts.montserrat

    // Backgrounds: Pure White for "Invisible UI"
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    canvasColor: const Color(0xFFFFFFFF),

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0095F6), // "Social Blue" - Non-fatiguing
      secondary: Color(0xFFFF2D55), // "Dopamine Pink" - For Likes/Hearts
      surface: Color(0xFFFFFFFF),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF121212), // High contrast for readability
      background: Color(0xFFFFFFFF),
      error: Color(0xFFFF3B30), // Urgent Red for errors/alerts
    ),

    // Text: Sharp contrast for fast scanning
    textTheme: GoogleFonts.montserratTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: Color(0xFF000000),
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF262626),
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Color(0xFF262626),
          height: 1.4, // Good line height improves reading endurance
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF8E8E8E),
        ),
      ),
    ),

    // AppBar: White to blend with scaffold (Content is King)
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0, // Flat design encourages scrolling
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF121212)),
      titleTextStyle: TextStyle(
        color: Color(0xFF121212),
        fontSize: 22,
        fontWeight: FontWeight.w800,
        fontFamily: 'Bosaka',
        letterSpacing: -0.5,
      ),
    ),

    // Cards: Flat or subtle to keep feed smooth
    cardTheme: const CardThemeData(
      color: Color(0xFFFFFFFF),
      elevation: 0, // Removed elevation to reduce visual weight
      margin: EdgeInsets.symmetric(vertical: 8), // Tighter spacing
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color(0xFFDBDBDB), width: 0.5), // Subtle border
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    // Icons & Dividers
    iconTheme: const IconThemeData(color: Color(0xFF262626)),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFDBDBDB),
      thickness: 0.5,
    ),

    // Buttons: High Saturation for Call-to-Action
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0095F6), // Brand Blue
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ), // Less rounded = more serious/action
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
  );

  /* ===================== DARK THEME — IMMERSION FOCUSED ===================== */

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    // fontFamily: 'Chillax', // Replaced by GoogleFonts.montserrat

    // Backgrounds: True Black (AMOLED) saves battery and reduces eye strain at night
    scaffoldBackgroundColor: const Color(0xFF000000),
    canvasColor: const Color(0xFF000000),

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF0A84FF), // Lighter Blue for dark mode visibility
      secondary: Color(0xFFFF375F), // Vivid Pink
      surface: Color(0xFF121212), // Slightly lighter for cards
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFFF5F5F5),
      background: Color(0xFF000000),
      error: Color(0xFFFF453A),
    ),

    // Text
    textTheme: GoogleFonts.montserratTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF5F5F5),
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Color(0xFFFAFAFA),
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFFA8A8A8),
        ),
      ),
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF000000),
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        fontFamily: 'Bosaka',
      ),
    ),

    // Cards
    cardTheme: const CardThemeData(
      color: Color(0xFF121212), // Subtle separation from black background
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color(0xFF262626), width: 1),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    // Icons & Dividers
    iconTheme: const IconThemeData(color: Colors.white),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF262626),
      thickness: 0.5,
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0A84FF),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
