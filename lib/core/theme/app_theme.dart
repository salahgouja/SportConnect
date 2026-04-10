import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';

/// Premium App Theme for SportConnect
///
/// Usage:
///   MaterialApp(theme: AppTheme.lightTheme)
///
/// Access text extensions:
///   Theme.of(context).textTheme.bodyMedium  — standard
///   context.textSmallBold                    — custom shortcut
class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════════════
  // COLOR SCHEME
  // ═══════════════════════════════════════════════════════════════════════════

  static ColorScheme get _colorScheme => ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        onPrimary: AppColors.textOnPrimary,
        onPrimaryContainer: AppColors.primary,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        onSecondary: AppColors.textOnPrimary,
        onSecondaryContainer: AppColors.secondary,
        tertiary: AppColors.accent,
        tertiaryContainer: AppColors.accentLight,
        onTertiary: AppColors.textOnPrimary,
        onTertiaryContainer: AppColors.accent,
        error: AppColors.error,
        errorContainer: AppColors.errorLight,
        onError: Colors.white,
        onErrorContainer: AppColors.error,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.border,
        outlineVariant: AppColors.divider,
        surfaceContainerHighest: AppColors.surfaceVariant,
        inverseSurface: AppColors.textPrimary,
        onInverseSurface: AppColors.surface,
        inversePrimary: AppColors.primaryLight,
        shadow: Colors.black.withValues(alpha: 0.08),
        scrim: Colors.black.withValues(alpha: 0.4),
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT THEME
  // ═══════════════════════════════════════════════════════════════════════════

  static TextTheme get _textTheme {
    // Build on M3 defaults so we inherit correct line heights, baseline, etc.
    const base = TextTheme();

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 40.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        height: 1.12,
        color: AppColors.textPrimary,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.16,
        color: AppColors.textPrimary,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: AppColors.textPrimary,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: AppColors.textPrimary,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppColors.textPrimary,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        height: 1.33,
        color: AppColors.textPrimary,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        height: 1.33,
        color: AppColors.textPrimary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        height: 1.38,
        letterSpacing: 0.15,
        color: AppColors.textPrimary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.1,
        color: AppColors.textPrimary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textPrimary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.43,
        color: AppColors.textSecondary,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 1.33,
        color: AppColors.textTertiary,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.5,
        color: AppColors.textPrimary,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.5,
        color: AppColors.textSecondary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        height: 1.45,
        letterSpacing: 0.5,
        color: AppColors.textTertiary,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUTTON THEMES (with pressed/disabled states)
  // ═══════════════════════════════════════════════════════════════════════════

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.primary.withValues(alpha: 0.38);
          }
          if (states.contains(WidgetState.pressed)) {
            return AppColors.primary.withValues(alpha: 0.88);
          }
          return AppColors.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.white.withValues(alpha: 0.6);
          }
          return Colors.white;
        }),
        overlayColor: WidgetStateProperty.all(
          Colors.white.withValues(alpha: 0.08),
        ),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return 0.0;
          if (states.contains(WidgetState.disabled)) return 0.0;
          return 0.0;
        }),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        ),
        minimumSize: WidgetStateProperty.all(Size(double.infinity, 56.h)),
        maximumSize: WidgetStateProperty.all(const Size(double.infinity, 64)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              PlatformAdaptive.buttonRadiusMd,
            ),
          ),
        ),
        textStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        splashFactory: PlatformAdaptive.isApple
            ? NoSplash.splashFactory
            : InkSparkle.splashFactory,
        animationDuration: const Duration(milliseconds: 180),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }

  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.primary.withValues(alpha: 0.38);
          }
          return AppColors.primary;
        }),
        overlayColor: WidgetStateProperty.all(
          AppColors.primary.withValues(alpha: 0.06),
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        ),
        minimumSize: WidgetStateProperty.all(Size(0, 56.h)),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: PlatformAdaptive.outlineBorderWidth,
            );
          }
          return BorderSide(
            color: AppColors.primary,
            width: PlatformAdaptive.outlineBorderWidth,
          );
        }),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              PlatformAdaptive.buttonRadiusMd,
            ),
          ),
        ),
        textStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        splashFactory: PlatformAdaptive.isApple
            ? NoSplash.splashFactory
            : InkSparkle.splashFactory,
      ),
    );
  }

  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.primary.withValues(alpha: 0.38);
          }
          return AppColors.primary;
        }),
        overlayColor: WidgetStateProperty.all(
          AppColors.primary.withValues(alpha: 0.06),
        ),
        textStyle: WidgetStateProperty.all(
          TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        splashFactory: PlatformAdaptive.isApple
            ? NoSplash.splashFactory
            : InkSparkle.splashFactory,
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ICON BUTTON THEME
  // ═══════════════════════════════════════════════════════════════════════════

  static IconButtonThemeData get _iconButtonTheme {
    return IconButtonThemeData(
      style: ButtonStyle(
        iconColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.textTertiary.withValues(alpha: 0.5);
          }
          return AppColors.textPrimary;
        }),
        overlayColor: WidgetStateProperty.all(
          AppColors.textPrimary.withValues(alpha: 0.06),
        ),
        iconSize: WidgetStateProperty.all(24.sp),
        minimumSize: WidgetStateProperty.all(Size(44.w, 44.w)),
        splashFactory: PlatformAdaptive.isApple
            ? NoSplash.splashFactory
            : InkSparkle.splashFactory,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INPUT DECORATION
  // ═══════════════════════════════════════════════════════════════════════════

  static InputDecorationTheme get _inputDecorationTheme {
    final radius = BorderRadius.circular(PlatformAdaptive.inputRadius);
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(
        color: AppColors.textTertiary,
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color: AppColors.primary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
      errorStyle: TextStyle(
        color: AppColors.error,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
      ),
      helperStyle: TextStyle(
        color: AppColors.textTertiary,
        fontSize: 12.sp,
      ),
      prefixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return AppColors.primary;
        if (states.contains(WidgetState.error)) return AppColors.error;
        return AppColors.textSecondary;
      }),
      suffixIconColor: AppColors.textSecondary,
      isDense: false,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TOGGLE CONTROLS (Switch, Checkbox, Radio) — green branded
  // ═══════════════════════════════════════════════════════════════════════════

  static SwitchThemeData get _switchTheme {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.textTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withValues(alpha: 0.3);
        }
        return AppColors.textTertiary.withValues(alpha: 0.15);
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    );
  }

  static CheckboxThemeData get _checkboxTheme {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: BorderSide(color: AppColors.border, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
    );
  }

  static RadioThemeData get _radioTheme {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.textTertiary;
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PROGRESS INDICATORS — branded green
  // ═══════════════════════════════════════════════════════════════════════════

  static ProgressIndicatorThemeData get _progressTheme {
    return ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.primary.withValues(alpha: 0.12),
      circularTrackColor: AppColors.primary.withValues(alpha: 0.12),
      linearMinHeight: 4.h,
      refreshBackgroundColor: AppColors.surface,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB BAR — common in runner apps (Activity / Routes / Crew)
  // ═══════════════════════════════════════════════════════════════════════════

  static TabBarThemeData get _tabBarTheme {
    return TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textTertiary,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: AppColors.divider,
      dividerHeight: 1,
      labelStyle: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
      overlayColor: WidgetStateProperty.all(
        AppColors.primary.withValues(alpha: 0.06),
      ),
      splashFactory: PlatformAdaptive.isApple
          ? NoSplash.splashFactory
          : InkSparkle.splashFactory,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FAB
  // ═══════════════════════════════════════════════════════════════════════════

  static FloatingActionButtonThemeData get _fabTheme {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: PlatformAdaptive.isApple ? 0 : 4,
      focusElevation: PlatformAdaptive.isApple ? 0 : 6,
      hoverElevation: PlatformAdaptive.isApple ? 0 : 8,
      highlightElevation: PlatformAdaptive.isApple ? 0 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PlatformAdaptive.isApple ? 20.r : 16.r),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POPUP MENU
  // ═══════════════════════════════════════════════════════════════════════════

  static PopupMenuThemeData get _popupMenuTheme {
    return PopupMenuThemeData(
      color: AppColors.surface,
      elevation: PlatformAdaptive.isApple ? 0 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PlatformAdaptive.radiusMd),
        side: PlatformAdaptive.isApple
            ? BorderSide(color: AppColors.border.withValues(alpha: 0.3))
            : BorderSide.none,
      ),
      textStyle: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TOOLTIP
  // ═══════════════════════════════════════════════════════════════════════════

  static TooltipThemeData get _tooltipTheme {
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8.r),
      ),
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      waitDuration: const Duration(milliseconds: 500),
      showDuration: const Duration(seconds: 2),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCROLLBAR
  // ═══════════════════════════════════════════════════════════════════════════

  static ScrollbarThemeData get _scrollbarTheme {
    return ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(
        AppColors.textTertiary.withValues(alpha: 0.3),
      ),
      trackColor: WidgetStateProperty.all(Colors.transparent),
      radius: Radius.circular(4.r),
      thickness: WidgetStateProperty.all(PlatformAdaptive.isApple ? 3.0 : 4.0),
      thumbVisibility: WidgetStateProperty.all(false),
      interactive: true,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGE TRANSITIONS — platform native
  // ═══════════════════════════════════════════════════════════════════════════

  static PageTransitionsTheme get _pageTransitionsTheme {
    return const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME — ASSEMBLED
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData get lightTheme {
    final colorScheme = _colorScheme;
    final textTheme = _textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      pageTransitionsTheme: _pageTransitionsTheme,

      // ─── App Bar ───
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: PlatformAdaptive.isApple ? 0 : 0.5,
        centerTitle: PlatformAdaptive.isApple,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24.sp),
        actionsIconTheme: IconThemeData(color: AppColors.textPrimary, size: 24.sp),
        toolbarHeight: PlatformAdaptive.isApple ? 44 : 56,
      ),

      // ─── Buttons ───
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      iconButtonTheme: _iconButtonTheme,
      floatingActionButtonTheme: _fabTheme,

      // ─── Inputs ───
      inputDecorationTheme: _inputDecorationTheme,

      // ─── Cards ───
      cardTheme: CardThemeData(
        elevation: PlatformAdaptive.isApple ? 0 : 1,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.radiusLg),
          side: PlatformAdaptive.cardBorderSide,
        ),
        color: AppColors.cardBg.withValues(alpha: PlatformAdaptive.cardAlpha),
        margin: EdgeInsets.zero,
      ),

      // ─── Toggles ───
      switchTheme: _switchTheme,
      checkboxTheme: _checkboxTheme,
      radioTheme: _radioTheme,

      // ─── Navigation ───
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface.withValues(
          alpha: PlatformAdaptive.navBarAlpha,
        ),
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.14),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: PlatformAdaptive.isApple ? 49 : 72.h,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: PlatformAdaptive.isApple ? 11.sp : 12.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            size: 24.sp,
          );
        }),
      ),
      tabBarTheme: _tabBarTheme,

      // ─── Chips ───
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant.withValues(
          alpha: PlatformAdaptive.isApple ? 0.72 : 1.0,
        ),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        disabledColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
        labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
        secondaryLabelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColors.primary),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.chipRadius),
          side: PlatformAdaptive.isApple
              ? BorderSide(color: AppColors.border.withValues(alpha: 0.15), width: 0.5)
              : BorderSide.none,
        ),
        showCheckmark: true,
        checkmarkColor: AppColors.primary,
      ),

      // ─── Surfaces ───
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary.withValues(
          alpha: PlatformAdaptive.isApple ? 0.9 : 1.0,
        ),
        contentTextStyle: TextStyle(color: Colors.white, fontSize: 14.sp),
        actionTextColor: AppColors.primaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: PlatformAdaptive.snackBarElevation,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface.withValues(
          alpha: PlatformAdaptive.sheetAlpha,
        ),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(PlatformAdaptive.sheetRadius),
          ),
        ),
        elevation: PlatformAdaptive.sheetElevation,
        showDragHandle: true,
        dragHandleColor: AppColors.textTertiary.withValues(alpha: 0.3),
        dragHandleSize: Size(36.w, 4.h),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface.withValues(
          alpha: PlatformAdaptive.dialogAlpha,
        ),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        elevation: PlatformAdaptive.dialogElevation,
        titleTextStyle: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      popupMenuTheme: _popupMenuTheme,
      tooltipTheme: _tooltipTheme,

      // ─── Indicators ───
      progressIndicatorTheme: _progressTheme,

      // ─── Scrollbar ───
      scrollbarTheme: _scrollbarTheme,

      // ─── List Tile ───
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
        minVerticalPadding: 12.h,
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.radiusMd),
        ),
        titleTextStyle: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),

      // ─── Badge ───
      badgeTheme: BadgeThemeData(
        backgroundColor: AppColors.error,
        textColor: Colors.white,
        textStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700),
        smallSize: 8.w,
        largeSize: 18.w,
      ),

      // ─── Misc ───
      splashFactory: PlatformAdaptive.isApple
          ? NoSplash.splashFactory
          : InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// THEME EXTENSIONS — quick access shortcuts
// ═══════════════════════════════════════════════════════════════════════════════

extension AppThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Common text shortcuts.
  TextStyle get textDisplayLg => textTheme.displayLarge!;
  TextStyle get textHeadlineMd => textTheme.headlineMedium!;
  TextStyle get textTitleLg => textTheme.titleLarge!;
  TextStyle get textTitleMd => textTheme.titleMedium!;
  TextStyle get textTitleSm => textTheme.titleSmall!;
  TextStyle get textBodyLg => textTheme.bodyLarge!;
  TextStyle get textBodyMd => textTheme.bodyMedium!;
  TextStyle get textBodySm => textTheme.bodySmall!;
  TextStyle get textLabelLg => textTheme.labelLarge!;
  TextStyle get textLabelMd => textTheme.labelMedium!;
  TextStyle get textLabelSm => textTheme.labelSmall!;

  // Semantic shortcuts.
  TextStyle get textSmallBold => textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w700);
  TextStyle get textCaption => textTheme.labelSmall!;
  TextStyle get textOverline => textTheme.labelSmall!.copyWith(
        letterSpacing: 1.0,
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
      );

  // Brand gradient.
  LinearGradient get greenGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
      );
}