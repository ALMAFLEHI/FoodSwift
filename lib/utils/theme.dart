import 'package:flutter/material.dart';

class AppTheme {
  static const Color deepPurple = Color(0xFF6A1B9A);
  static const Color mintGreen = Color(0xFF81C784);
  static const Color orange = Color(0xFFFFB74D);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);

  static ThemeData lightTheme = ThemeData(
    primaryColor: deepPurple,
    scaffoldBackgroundColor: lightGrey,
    appBarTheme: const AppBarTheme(
      backgroundColor: deepPurple,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: deepPurple,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    // FIX: Change CardTheme to CardThemeData
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
