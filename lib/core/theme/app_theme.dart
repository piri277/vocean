import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Paleta 60 / 30 / 10: crema clásica, verde abeto y rojo tomate.
  static const Color bgCream = Color(0xFFEEE2CB); // 238 226 203
  static const Color darkTeal = Color(0xFF1B4532); // 27 69 50
  static const Color buttonTeal = Color(0xFF1B4532);
  static const Color lightTeal = Color(0xFFDDE2CC);
  static const Color grey = Color(0xFF8A8272);
  static const Color cardBg = Color(0xFFFAF4E8);
  static const Color ringBackground = Color(0xFFDDD0B6);
  static const Color coral = Color(0xFFEE4129); // 238 65 41
  static const Color tomato = coral;

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
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkTeal,
        contentTextStyle: const TextStyle(
          color: bgCream,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: darkTeal,
        displayColor: darkTeal,
      ),
    );
  }
}
