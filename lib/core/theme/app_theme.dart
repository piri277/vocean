import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color bgCream = Color(0xFFFBF2E9);
  static const Color darkTeal = Color(0xFF103633);
  static const Color buttonTeal = Color(0xFF136862);
  static const Color lightTeal = Color(0xFFE2F4EC);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color ringBackground = Color(0xFFE0E0E0);
  static const Color coral = Color(0xFFFF5E5E);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgCream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: buttonTeal,
        brightness: Brightness.light,
      ),
      fontFamily: 'Nunito',
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: bgCream,
        foregroundColor: darkTeal,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: darkTeal,
        displayColor: darkTeal,
      ),
    );
  }
}
