import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    // Paleta principal (proporcionada por el usuario)
    const neonIce = Color(0xFF34E4EA);
    const whiteSmoke = Color(0xFFF1EDEE);
    const navy = Color(0xFF150578);
    const steelBlue = Color(0xFF0A81D1);
    const cerulean = Color(0xFF437C90);
    const dangerRed = Color(0xFFB00020);

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: navy,
      onPrimary: whiteSmoke,
      secondary: steelBlue,
      onSecondary: whiteSmoke,
      background: whiteSmoke,
      onBackground: navy,
      surface: Colors.white,
      onSurface: navy,
      error: dangerRed,
      onError: Colors.white,
      tertiary: cerulean,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: whiteSmoke,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
      ),
      // Mantener compatibilidad con definición previa
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      textTheme: TextTheme(
        headlineSmall: const TextStyle(color: navy, fontWeight: FontWeight.w700),
        titleMedium: const TextStyle(color: navy, fontWeight: FontWeight.w600),
        bodyMedium: const TextStyle(color: navy),
        bodySmall: const TextStyle(color: navy),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: steelBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: navy),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: navy,
          side: BorderSide(color: navy.withOpacity(0.12)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: neonIce,
        foregroundColor: Colors.white,
      ),
      iconTheme: const IconThemeData(color: navy),
    );
  }
}
