import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF6C63FF);
  static const primaryLight = Color(0xFF9C8FFF);
  static const secondary = Color(0xFF43E97B);
  static const accent = Color(0xFFFA8231);
  static const danger = Color(0xFFFF4757);
  static const dark = Color(0xFF1A1A2E);
  static const grey = Color(0xFF8A8A8A);
  static const background = Color(0xFFF8F9FA);
  static const white = Colors.white;
}

class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.dark,
  );
  static const heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.dark,
  );
  static const heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.dark,
  );
  static const body = TextStyle(fontSize: 14, color: AppColors.dark);
  static const caption = TextStyle(fontSize: 12, color: AppColors.grey);
}

class AppStrings {
  static const appName = '알바메이트';
  static const minimumWage2025 = 10320;
}
