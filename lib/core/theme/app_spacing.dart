import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Spacing constants for consistent layouts
class AppSpacing {
  AppSpacing._();

  // Base spacing unit (4dp)
  static double get xxs => 2.w;
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 12.w;
  static double get lg => 16.w;
  static double get xl => 20.w;
  static double get xxl => 24.w;
  static double get xxxl => 32.w;
  static double get huge => 40.w;
  static double get massive => 48.w;
  static double get giant => 64.w;

  // Semantic spacing
  static double get cardPadding => 16.w;
  static double get screenPadding => 20.w;
  static double get sectionSpacing => 24.w;
  static double get listItemSpacing => 12.w;
  static double get iconTextSpacing => 8.w;

  // Border Radius
  static double get radiusXs => 4.r;
  static double get radiusSm => 8.r;
  static double get radiusMd => 12.r;
  static double get radiusLg => 16.r;
  static double get radiusXl => 20.r;
  static double get radiusXxl => 24.r;
  static double get radiusFull => 999.r;

  // Common BorderRadius
  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);

  // Button Heights
  static double get buttonHeightSm => 40.h;
  static double get buttonHeightMd => 48.h;
  static double get buttonHeightLg => 56.h;

  // Icon Sizes
  static double get iconXs => 16.sp;
  static double get iconSm => 20.sp;
  static double get iconMd => 24.sp;
  static double get iconLg => 32.sp;
  static double get iconXl => 40.sp;
  static double get iconXxl => 48.sp;

  // Avatar Sizes
  static double get avatarXs => 24.w;
  static double get avatarSm => 32.w;
  static double get avatarMd => 40.w;
  static double get avatarLg => 56.w;
  static double get avatarXl => 80.w;
  static double get avatarXxl => 120.w;

  // Card Elevation
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get shadowXl => [
    BoxShadow(
      color: Colors.black.withOpacity(0.16),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  // Colored Shadows
  static List<BoxShadow> primaryShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
