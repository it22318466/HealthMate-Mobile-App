import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color stepsColor = Color(0xFF4CAF50);
  static const Color caloriesColor = Color(0xFFE53935);
  static const Color waterColor = Color(0xFF1E88E5);

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: stepsColor,
        secondary: waterColor,
        error: caloriesColor,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      appBarTheme: base.appBarTheme.copyWith(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      cardTheme: base.cardTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      ),
    );
  }
}
