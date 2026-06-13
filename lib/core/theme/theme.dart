import 'package:flutter/material.dart';

class MindMateTheme {
  // Calming HSL-tailored Color Palette
  static const Color lightBg = Color(0xFFFDFBF7);      // Warm Cream
  static const Color lightSurface = Color(0xFFF6F2EB); // Almond/Eggshell
  static const Color lightText = Color(0xFF2E3440);    // Slate Blue Text

  static const Color darkBg = Color(0xFF161A22);       // Deep Midnight Blue
  static const Color darkSurface = Color(0xFF212836);  // Soft Slate Surface
  static const Color darkText = Color(0xFFECEFF4);     // Crisp Soft Ice White

  // Accent Colors
  static const Color sageGreen = Color(0xFF6E9B79);    // Primary Sage Green (Calmness)
  static const Color terracotta = Color(0xFFDD8F73);   // Secondary Terracotta (Warmth)
  static const Color skyBlue = Color(0xFF80A4C2);      // Sky Blue (Confidence/Focus)
  static const Color softAmber = Color(0xFFE6AE54);    // Warm Amber (Motivation)

  // High Contrast Colors
  static const Color hcLightBg = Color(0xFFFFFFFF);
  static const Color hcLightText = Color(0xFF000000);
  static const Color hcLightPrimary = Color(0xFF0000FF);
  
  static const Color hcDarkBg = Color(0xFF000000);
  static const Color hcDarkText = Color(0xFFFFFFFF);
  static const Color hcDarkPrimary = Color(0xFF00FFCC); // High visibility Teal

  static ThemeData buildTheme({required bool isDark, required bool isHighContrast}) {
    if (isHighContrast) {
      return isDark ? _buildHighContrastDark() : _buildHighContrastLight();
    }
    return isDark ? _buildDarkTheme() : _buildLightTheme();
  }

  static ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: sageGreen,
        secondary: terracotta,
        tertiary: skyBlue,
        surface: lightSurface,
        onSurface: lightText,
        background: lightBg,
        onBackground: lightText,
      ),
      fontFamily: 'Inter',
      cardTheme: const CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: lightText),
        titleTextStyle: TextStyle(color: lightText, fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: lightText, fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: lightText, fontSize: 24, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: lightText, fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: lightText, fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(color: lightText, fontSize: 14, height: 1.4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFEFECE5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: sageGreen, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.black54),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sageGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  static ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: sageGreen,
        secondary: terracotta,
        tertiary: skyBlue,
        surface: darkSurface,
        onSurface: darkText,
        background: darkBg,
        onBackground: darkText,
      ),
      fontFamily: 'Inter',
      cardTheme: const CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: darkText),
        titleTextStyle: TextStyle(color: darkText, fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: darkText, fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: darkText, fontSize: 24, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: darkText, fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: darkText, fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(color: darkText, fontSize: 14, height: 1.4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C3545),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: sageGreen, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sageGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  static ThemeData _buildHighContrastLight() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: hcLightBg,
      colorScheme: const ColorScheme.light(
        primary: Colors.black,
        secondary: hcLightPrimary,
        tertiary: Colors.blueAccent,
        surface: Color(0xFFEEEEEE),
        onSurface: hcLightText,
        background: hcLightBg,
        onBackground: hcLightText,
      ),
      fontFamily: 'Inter',
      cardTheme: CardThemeData(
        color: const Color(0xFFEEEEEE),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black, width: 2.5),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: hcLightText, fontSize: 32, fontWeight: FontWeight.w900),
        headlineMedium: TextStyle(color: hcLightText, fontSize: 24, fontWeight: FontWeight.w800),
        titleLarge: TextStyle(color: hcLightText, fontSize: 20, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: hcLightText, fontSize: 16, fontWeight: FontWeight.bold, height: 1.5),
        bodyMedium: TextStyle(color: hcLightText, fontSize: 14, fontWeight: FontWeight.bold, height: 1.4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: hcLightPrimary, width: 3),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
    );
  }

  static ThemeData _buildHighContrastDark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: hcDarkBg,
      colorScheme: const ColorScheme.dark(
        primary: hcDarkPrimary,
        secondary: Colors.yellow,
        tertiary: Colors.white,
        surface: Color(0xFF1E1E1E),
        onSurface: hcDarkText,
        background: hcDarkBg,
        onBackground: hcDarkText,
      ),
      fontFamily: 'Inter',
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: hcDarkPrimary, width: 2.5),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: hcDarkText, fontSize: 32, fontWeight: FontWeight.w900),
        headlineMedium: TextStyle(color: hcDarkText, fontSize: 24, fontWeight: FontWeight.w800),
        titleLarge: TextStyle(color: hcDarkText, fontSize: 20, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: hcDarkText, fontSize: 16, fontWeight: FontWeight.bold, height: 1.5),
        bodyMedium: TextStyle(color: hcDarkText, fontSize: 14, fontWeight: FontWeight.bold, height: 1.4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: hcDarkPrimary, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.yellow, width: 3),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: hcDarkPrimary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: hcDarkPrimary, width: 2),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
    );
  }
}
