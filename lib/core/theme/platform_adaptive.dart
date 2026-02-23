import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Platform-adaptive design system.
///
/// Provides iOS (Liquid Glass / Cupertino) vs Android (Material 3) design
/// tokens so every surface, radius, shadow, and blur adapts automatically.
///
/// Usage:
/// ```dart
/// borderRadius: BorderRadius.circular(PlatformAdaptive.radiusMd)
/// ```
class PlatformAdaptive {
  PlatformAdaptive._();

  // ─── Platform Detection ───

  /// Whether the current platform is iOS (or macOS for consistency).
  static bool get isApple =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  /// Whether the current platform is Android.
  static bool get isAndroid =>
      defaultTargetPlatform == TargetPlatform.android;

  // ─── Border Radii ───
  // iOS: softer, more rounded (Liquid Glass)
  // Android: Material 3 standard

  static double get radiusXs => isApple ? 6.r : 4.r;
  static double get radiusSm => isApple ? 10.r : 8.r;
  static double get radiusMd => isApple ? 14.r : 12.r;
  static double get radiusLg => isApple ? 20.r : 16.r;
  static double get radiusXl => isApple ? 24.r : 20.r;
  static double get radiusXxl => isApple ? 28.r : 24.r;
  static double get radiusFull => 999.r;

  // ─── Button Radii ───

  static double get buttonRadiusSm => isApple ? 14.r : 10.r;
  static double get buttonRadiusMd => isApple ? 20.r : 14.r;
  static double get buttonRadiusLg => isApple ? 24.r : 18.r;

  // ─── Dialog & Sheet Radii ───

  static double get dialogRadius => isApple ? 28.r : 24.r;
  static double get sheetRadius => isApple ? 28.r : 24.r;
  static double get chipRadius => isApple ? 20.r : 12.r;

  // ─── Input Radii ───

  static double get inputRadius => isApple ? 20.r : 16.r;
  static double get searchRadius => isApple ? 20.r : 16.r;

  // ─── Card Styling ───

  /// Card border: subtle glass border on iOS, no border on Android.
  static Border? get cardBorder => isApple
      ? Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 0.5,
        )
      : null;

  /// Card border side for theme shapes (CardTheme.shape).
  static BorderSide get cardBorderSide => isApple
      ? BorderSide(
          color: Colors.white.withValues(alpha: 0.15),
          width: 0.5,
        )
      : BorderSide.none;

  /// Card shadow blur radius.
  static double get cardShadowBlur => isApple ? 12 : 16;

  /// Card shadow opacity.
  static double get cardShadowOpacity => isApple ? 0.04 : 0.06;

  /// Card shadow offset.
  static Offset get cardShadowOffset =>
      isApple ? const Offset(0, 3) : const Offset(0, 4);

  // ─── Blur (iOS Liquid Glass only) ───

  /// Whether to apply backdrop blur effects.
  static bool get useBackdropBlur => isApple;

  /// Navigation bar blur sigma.
  static double get navBarBlurSigma => 32;

  /// App bar blur sigma.
  static double get appBarBlurSigma => 28;

  /// Card blur sigma (when using glass cards).
  static double get cardBlurSigma => 16;

  /// General glass blur sigma.
  static double get glassBlurSigma => 24;

  // ─── Surface Alpha ───
  // iOS: translucent (Liquid Glass); Android: opaque (Material)

  /// Navigation bar background alpha.
  static double get navBarAlpha => isApple ? 0.68 : 1.0;

  /// App bar background alpha.
  static double get appBarAlpha => isApple ? 0.72 : 1.0;

  /// Dialog background alpha.
  static double get dialogAlpha => isApple ? 0.95 : 1.0;

  /// Bottom sheet background alpha.
  static double get sheetAlpha => isApple ? 0.92 : 1.0;

  /// Card background alpha.
  static double get cardAlpha => isApple ? 0.92 : 1.0;

  // ─── Glass Borders ───

  /// Glass highlight border for iOS Liquid Glass effect.
  static Border? get glassBorder => isApple
      ? Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 0.5,
        )
      : null;

  /// Button glass border for iOS.
  static Border get buttonGlassBorder => isApple
      ? Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 0.5,
        )
      : Border.all(color: Colors.transparent, width: 0);

  /// Ghost button border (shared styling).
  static double get ghostBorderWidth => isApple ? 1.5 : 2.0;

  // ─── Shadow Styling ───

  /// Primary shadow blur.
  static double get primaryShadowBlur => isApple ? 12 : 16;

  /// Primary shadow offset.
  static Offset get primaryShadowOffset =>
      isApple ? const Offset(0, 4) : const Offset(0, 6);

  /// Outlined button border width.
  static double get outlineBorderWidth => isApple ? 1.5 : 2.0;

  // ─── Elevation ───
  // iOS: zero elevation (Liquid Glass); Android: Material elevation

  /// Snackbar elevation.
  static double get snackBarElevation => isApple ? 0 : 6;

  /// Dialog elevation.
  static double get dialogElevation => isApple ? 0 : 24;

  /// Bottom sheet elevation.
  static double get sheetElevation => isApple ? 0 : 1;

  // ─── Helpers ───

  /// Creates a platform-adaptive box shadow list.
  static List<BoxShadow> adaptiveShadow({
    Color? color,
    double? blurRadius,
    Offset? offset,
  }) {
    return [
      BoxShadow(
        color: (color ?? Colors.black).withValues(
          alpha: cardShadowOpacity,
        ),
        blurRadius: blurRadius ?? cardShadowBlur,
        offset: offset ?? cardShadowOffset,
      ),
    ];
  }
}
