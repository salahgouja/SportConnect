import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Configuration for Firebase UI Auth widgets
/// Uses SportConnect's AppColors for consistent branding
class FirebaseUIConfig {
  FirebaseUIConfig._();

  /// Configure Firebase UI Auth providers
  /// Call this in main() after Firebase.initializeApp()
  static void configureProviders() {
    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
      // GoogleProvider and AppleProvider are handled separately
      // due to version conflicts with google_sign_in ^7.x
    ]);
  }

  /// Get the themed InputDecoration for Firebase UI forms
  static InputDecorationTheme get inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(color: AppColors.textTertiary),
      errorStyle: TextStyle(color: AppColors.error, fontSize: 12),
    );
  }

  /// Get the themed ButtonStyle for Firebase UI buttons
  static ButtonStyle get elevatedButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Get the themed OutlinedButtonStyle for Firebase UI secondary buttons
  static ButtonStyle get outlinedButtonStyle {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: BorderSide(color: AppColors.primary, width: 1.5),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  /// Get the themed TextButtonStyle for Firebase UI text links
  static ButtonStyle get textButtonStyle {
    return TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  /// Create a theme for Firebase UI Auth screens
  static ThemeData getFirebaseUITheme(BuildContext context) {
    final baseTheme = Theme.of(context);

    return baseTheme.copyWith(
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      inputDecorationTheme: inputDecorationTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(style: elevatedButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedButtonStyle),
      textButtonTheme: TextButtonThemeData(style: textButtonStyle),
      textTheme: baseTheme.textTheme.copyWith(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        bodySmall: TextStyle(fontSize: 12, color: AppColors.textTertiary),
      ),
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.cardBg,
      dividerColor: AppColors.divider,
    );
  }

  /// Email form field decoration builder
  static InputDecoration emailInputDecoration({String? hint}) {
    return InputDecoration(
      labelText: 'Email',
      hintText: hint ?? 'Enter your email',
      prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
    );
  }

  /// Password form field decoration builder
  static InputDecoration passwordInputDecoration({
    String? hint,
    bool isConfirm = false,
  }) {
    return InputDecoration(
      labelText: isConfirm ? 'Confirm Password' : 'Password',
      hintText:
          hint ?? (isConfirm ? 'Confirm your password' : 'Enter your password'),
      prefixIcon: Icon(
        Icons.lock_outline_rounded,
        color: AppColors.textSecondary,
      ),
    );
  }

  /// Name form field decoration builder
  static InputDecoration nameInputDecoration({String? hint}) {
    return InputDecoration(
      labelText: 'Full Name',
      hintText: hint ?? 'Enter your full name',
      prefixIcon: Icon(
        Icons.person_outline_rounded,
        color: AppColors.textSecondary,
      ),
    );
  }
}

/// Custom header builder for Firebase UI screens
/// Creates a branded header with SportConnect logo
class SportConnectHeaderBuilder {
  static Widget build(
    BuildContext context,
    BoxConstraints constraints,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.directions_run_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'SportConnect',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

/// Custom subtitle builder for Firebase UI screens
class SportConnectSubtitleBuilder {
  static Widget buildLogin(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to continue your running journey',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Widget buildRegister(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            'Create Account',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Join our community of eco-friendly riders',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
