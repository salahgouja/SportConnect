import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Typography system for SportConnect
class AppTypography {
  AppTypography._();

  // Font Family
  static const String fontFamily = 'Inter';

  // Display Styles - For heroes and large headings
  static TextStyle displayLarge = TextStyle(
    fontSize: 40.sp,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static TextStyle displayMedium = TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.2,
  );

  static TextStyle displaySmall = TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  // Headline Styles
  static TextStyle headlineLarge = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static TextStyle headlineMedium = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.3,
  );

  static TextStyle headlineSmall = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Title Styles
  static TextStyle titleLarge = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle titleMedium = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle titleSmall = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Body Styles
  static TextStyle bodyLarge = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle bodyMedium = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle bodySmall = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // Label Styles
  static TextStyle labelLarge = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static TextStyle labelMedium = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static TextStyle labelSmall = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // Button Text
  static TextStyle button = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // Caption
  static TextStyle caption = TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.4,
  );

  // Overline
  static TextStyle overline = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    height: 1.6,
  );

  // Gamification Styles
  static TextStyle xpText = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static TextStyle levelText = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.0,
  );

  static TextStyle badgeText = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle streakText = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w800,
  );
}
