import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Modern Orange/Red gradient
  static const Color primary = Color(0xFFFF6B35); // Modern Orange
  static const Color primaryDark = Color(0xFFE55100); // Darker Orange
  static const Color primaryLight = Color(0xFFFF8A65); // Lighter Orange

  // Accent Colors
  static const Color accent = Color(0xFF4CAF50); // Fresh Green
  static const Color accentLight = Color(0xFF81C784); // Light Green

  // Background Colors
  static const Color background = Color(0xFFF8F9FA); // Light Gray
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textDark = Color(0xFF2C3E50); // Dark Blue-Gray
  static const Color textMedium = Color(0xFF546E7A); // Medium Gray
  static const Color textLight = Color(0xFF90A4AE); // Light Gray
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
}

class AppTextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.3,
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textMedium,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
    height: 1.4,
  );

  // Button Text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    height: 1.2,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
    height: 1.3,
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppBorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double round = 50.0;
}

class AppShadows {
  static const BoxShadow card = BoxShadow(
    color: AppColors.shadow,
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow cardHover = BoxShadow(
    color: AppColors.shadow,
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  static const BoxShadow button = BoxShadow(
    color: AppColors.shadowLight,
    blurRadius: 4,
    offset: Offset(0, 2),
  );
}
