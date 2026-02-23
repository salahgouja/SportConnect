import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';

/// Premium App Theme for SportConnect
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        tertiary: AppColors.accent,
        tertiaryContainer: AppColors.accentLight,
        error: AppColors.error,
        errorContainer: AppColors.errorLight,
        surface: AppColors.surface,
        background: AppColors.background,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnPrimary,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        outline: AppColors.border,
        surfaceVariant: AppColors.surfaceVariant,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24.sp),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 40.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.5,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: AppColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiary,
        ),
        labelLarge: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppColors.textTertiary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          minimumSize: Size(double.infinity, 56.h),
          // Platform-adaptive: pill on iOS, standard on Android
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              PlatformAdaptive.buttonRadiusMd,
            ),
          ),
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          minimumSize: Size(double.infinity, 56.h),
          side: BorderSide(
            color: AppColors.primary,
            width: PlatformAdaptive.outlineBorderWidth,
          ),
          // Platform-adaptive: pill on iOS, standard on Android
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              PlatformAdaptive.buttonRadiusMd,
            ),
          ),
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ),
      // Platform-adaptive input borders
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.inputRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.inputRadius),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.inputRadius),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.inputRadius),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 16.sp),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),
      // Platform-adaptive card — glass on iOS, Material on Android
      cardTheme: CardThemeData(
        elevation: PlatformAdaptive.isApple ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.radiusLg),
          side: PlatformAdaptive.cardBorderSide,
        ),
        color: AppColors.cardBg.withValues(alpha: PlatformAdaptive.cardAlpha),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      // ─── Platform-Adaptive Theme Adaptations ───
      // iOS: Liquid Glass (translucent, rounded, zero-elevation)
      // Android: Material 3 (opaque, standard radii, standard elevation)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface.withValues(
          alpha: PlatformAdaptive.navBarAlpha,
        ),
        indicatorColor: AppColors.primary.withValues(alpha: 0.14),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 72.h,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: PlatformAdaptive.isApple ? 11.sp : 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            );
          }
          return TextStyle(
            fontSize: PlatformAdaptive.isApple ? 11.sp : 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: AppColors.primary, size: 24.sp);
          }
          return IconThemeData(color: AppColors.textSecondary, size: 24.sp);
        }),
      ),
      // Platform-adaptive chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant.withValues(
          alpha: PlatformAdaptive.isApple ? 0.72 : 1.0,
        ),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.chipRadius),
          side: PlatformAdaptive.isApple
              ? BorderSide(
                  color: AppColors.border.withValues(alpha: 0.15),
                  width: 0.5,
                )
              : BorderSide.none,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      // Platform-adaptive snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary.withValues(
          alpha: PlatformAdaptive.isApple ? 0.9 : 1.0,
        ),
        contentTextStyle: TextStyle(color: Colors.white, fontSize: 14.sp),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: PlatformAdaptive.snackBarElevation,
      ),
      // Platform-adaptive bottom sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface.withValues(
          alpha: PlatformAdaptive.sheetAlpha,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(PlatformAdaptive.sheetRadius),
          ),
        ),
        elevation: PlatformAdaptive.sheetElevation,
      ),
      // Platform-adaptive dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface.withValues(
          alpha: PlatformAdaptive.dialogAlpha,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        elevation: PlatformAdaptive.dialogElevation,
        titleTextStyle: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
