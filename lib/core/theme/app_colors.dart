import 'package:flutter/material.dart';

/// SportConnect Premium Color Palette
/// Modern carpooling app design system - Light Classy Green Theme
/// Lighter Emerald, Sage, Fresh Green tones for a clean, modern, premium feel
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════
  // PRIMARY BRAND COLORS - Light Classy Green (Fresh & Premium)
  // ═══════════════════════════════════════════════════════════════
  static const Color primary = Color(0xFF40916C); // Emerald Green (lighter)
  static const Color primaryLight = Color(0xFF52B788); // Fresh Emerald
  static const Color primaryDark = Color(0xFF2D6A4F); // Deep Emerald
  static const Color primarySurface = Color(0xFFE8F5E9); // Very Light Green

  // ═══════════════════════════════════════════════════════════════
  // SECONDARY - Sage Green (Elegant & Light)
  // ═══════════════════════════════════════════════════════════════
  static const Color secondary = Color(0xFF74C69D); // Sage Green
  static const Color secondaryLight = Color(0xFF95D5B2); // Light Sage
  static const Color secondaryDark = Color(0xFF52B788); // Emerald Sage
  static const Color secondarySurface = Color(0xFFF0FFF4); // Mint Surface

  // ═══════════════════════════════════════════════════════════════
  // ACCENT - Mint Green (Subtle & Fresh)
  // ═══════════════════════════════════════════════════════════════
  static const Color accent = Color(0xFF95D5B2); // Mint Green
  static const Color accentLight = Color(0xFFB7E4C7); // Light Mint
  static const Color accentDark = Color(0xFF74C69D); // Sage
  static const Color accentSurface = Color(0xFFF5FBF7); // Mint Mist

  // ═══════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════
  // Success - Fresh Green
  static const Color success = Color(0xFF40916C);
  static const Color successLight = Color(0xFF52B788);
  static const Color successDark = Color(0xFF2D6A4F);
  static const Color successSurface = Color(0xFFE8F5E9);

  // Warning - Warm Amber
  static const Color warning = Color(0xFFD4A373);
  static const Color warningLight = Color(0xFFE6BE8A);
  static const Color warningDark = Color(0xFFBC8A5F);
  static const Color warningSurface = Color(0xFFFDF6EE);

  // Error - Muted Rose
  static const Color error = Color(0xFFC1666B);
  static const Color errorLight = Color(0xFFD4878B);
  static const Color errorDark = Color(0xFFA84C51);
  static const Color errorSurface = Color(0xFFFAEBEC);

  // Info - Slate Blue
  static const Color info = Color(0xFF4A7C88);
  static const Color infoLight = Color(0xFF6B9AA6);
  static const Color infoDark = Color(0xFF3A616B);
  static const Color infoSurface = Color(0xFFEBF2F4);

  // ═══════════════════════════════════════════════════════════════
  // NEUTRAL COLORS - Clean & Modern
  // ═══════════════════════════════════════════════════════════════
  static const Color background = Color(
    0xFFF8FAF9,
  ); // Off White with green tint
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceVariant = Color(0xFFF1F5F3); // Light Gray Green
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color scaffoldBg = Color(0xFFF8FAF9);

  // Text Colors - High Contrast
  static const Color textPrimary = Color(0xFF1B2E24); // Dark Green Black
  static const Color textSecondary = Color(0xFF5C7266); // Muted Green Gray
  static const Color textTertiary = Color(0xFF8FA399); // Light Green Gray
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFB8C7BF);

  // Input Field
  static const Color inputFill = Color(0xFFF5F8F6);
  static const Color inputBorder = Color(0xFFD8E0DB);
  static const Color inputFocusBorder = Color(0xFF40916C);

  // Border & Divider
  static const Color border = Color(0xFFD8E0DB);
  static const Color divider = Color(0xFFE8EDE9);
  static const Color borderLight = Color(0xFFEDF1EE);

  // Shimmer / Loading
  static const Color shimmer = Color(0xFFE8EDE9);
  static const Color shimmerHighlight = Color(0xFFF5F8F6);

  // ═══════════════════════════════════════════════════════════════
  // GAMIFICATION COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color xpGold = Color(0xFF52B788); // Emerald XP
  static const Color xpPurple = Color(0xFF7B6D8D);
  static const Color levelBronze = Color(0xFFB7E4C7); // Light Mint (Level 1)
  static const Color levelSilver = Color(0xFF95D5B2); // Soft Sage (Level 2)
  static const Color levelGold = Color(0xFF74C69D); // Sage Green (Level 3)
  static const Color levelPlatinum = Color(0xFF40916C); // Emerald (Level 4)
  static const Color levelDiamond = Color(0xFF2D6A4F); // Forest Green (Level 5)
  static const Color levelMaster = Color(0xFF1B4332); // Deep Forest

  // Rating Stars
  static const Color starFilled = Color(0xFFD4A373);
  static const Color starEmpty = Color(0xFFD8E0DB);

  // Status Colors
  static const Color online = Color(0xFF40916C);
  static const Color offline = Color(0xFF8FA399);
  static const Color busy = Color(0xFFD4A373);
  static const Color away = Color(0xFFC1666B);

  // ═══════════════════════════════════════════════════════════════
  // RIDE STATUS COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color rideActive = Color(0xFF40916C);
  static const Color ridePending = Color(0xFFD4A373);
  static const Color rideCancelled = Color(0xFFC1666B);
  static const Color rideCompleted = Color(0xFF4A7C88);
  static const Color rideScheduled = Color(0xFF7B6D8D);

  // ═══════════════════════════════════════════════════════════════
  // MAP COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color mapRoute = Color(0xFF40916C); // Emerald Green
  static const Color mapRouteAlt = Color(0xFF52B788); // Light Emerald
  static const Color mapPickup = Color(0xFF52B788);
  static const Color mapDropoff = Color(0xFFC1666B);
  static const Color mapDriver = Color(0xFF40916C); // Emerald Green

  // ═══════════════════════════════════════════════════════════════
  // DARK MODE COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color darkBackground = Color(0xFF0A1410);
  static const Color darkSurface = Color(0xFF121F1A);
  static const Color darkSurfaceVariant = Color(0xFF1A2D25);
  static const Color darkCardBg = Color(0xFF121F1A);
  static const Color darkTextPrimary = Color(0xFFE8F0EB);
  static const Color darkTextSecondary = Color(0xFF8FA399);
  static const Color darkBorder = Color(0xFF2D4A3C);

  // ═══════════════════════════════════════════════════════════════
  // PREMIUM GRADIENTS
  // ═══════════════════════════════════════════════════════════════
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondary],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentLight, accent],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successLight, success],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF74C69D), Color(0xFF52B788), Color(0xFF40916C)],
  );

  // Hero gradient for headers - Light Classy Green
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF40916C), Color(0xFF52B788), Color(0xFF74C69D)],
  );

  // Nature gradient - Fresh green tones
  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2D6A4F), Color(0xFF40916C), Color(0xFF52B788)],
  );

  // Alternative hero for variety - Sage tones
  static const LinearGradient heroGradientAlt = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF52B788), Color(0xFF74C69D), Color(0xFF95D5B2)],
  );

  // Card shimmer gradient
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F8F6)],
  );

  // Glass effect gradient — Liquid Glass
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x40FFFFFF), Color(0x10FFFFFF)],
  );

  // Liquid Glass highlight gradient — for glass container top-left shimmer
  static LinearGradient get liquidGlassHighlight => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFFFFFFFF).withValues(alpha: 0.30),
      const Color(0xFFFFFFFF).withValues(alpha: 0.0),
      const Color(0xFFFFFFFF).withValues(alpha: 0.0),
      const Color(0xFFFFFFFF).withValues(alpha: 0.08),
    ],
    stops: const [0.0, 0.3, 0.7, 1.0],
  );

  // Liquid Glass surface — translucent white for glass panels
  static Color get liquidGlassSurface =>
      const Color(0xFFFFFFFF).withValues(alpha: 0.68);

  // Liquid Glass border — subtle glass edge
  static Color get liquidGlassBorder =>
      const Color(0xFFFFFFFF).withValues(alpha: 0.20);

  // ═══════════════════════════════════════════════════════════════
  // LEVEL GRADIENTS FOR AVATARS
  // ═══════════════════════════════════════════════════════════════
  static const LinearGradient diamondGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA3C4BC), Color(0xFF7BA39A), Color(0xFFA3C4BC)],
  );

  static const LinearGradient platinumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFCDD5D0), Color(0xFFADB8B3), Color(0xFFCDD5D0)],
  );

  static const LinearGradient goldGradientLevel = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF52B788), Color(0xFF40916C), Color(0xFF52B788)],
  );

  static const LinearGradient silverGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF95D5B2), Color(0xFF74C69D), Color(0xFF95D5B2)],
  );

  static const LinearGradient bronzeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB7E4C7), Color(0xFF95D5B2), Color(0xFFB7E4C7)],
  );

  // ═══════════════════════════════════════════════════════════════
  // ECO-FRIENDLY COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color ecoGreen = Color(0xFF2D6A4F);
  static const Color ecoLeaf = Color(0xFF40916C);
  static const Color distanceGreen = Color(0xFF2D6A4F);

  // ═══════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════
  static Color withAlpha(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}
