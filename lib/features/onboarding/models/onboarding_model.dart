import 'package:flutter/material.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/services.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class OnboardingPage {
  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.gradientColors,
    required this.illustration,
    this.features = const [],
  });
  final String title;
  final String subtitle;
  final String description;
  final List<Color> gradientColors;
  final List<String> features;
  final IllustrationVariant illustration;
}

enum IllustrationVariant { findRide, offerSeat, planRoute, connectGo }

// ---------------------------------------------------------------------------
// Page definitions
// ---------------------------------------------------------------------------

final List<OnboardingPage> onboardingPages = [
  OnboardingPage(
    title: 'Find Your\nRide',
    subtitle: 'Match with Runners',
    description:
        'Instantly match with runners heading the same direction. '
        'Share a car, save money, and arrive at the start-line together.',
    gradientColors: [
      AppColors.primary,
      AppColors.primary.withValues(alpha: 0.65),
    ],
    illustration: IllustrationVariant.findRide,
    features: ['Smart Matching', 'Nearby Runners', 'Pace Filters'],
  ),
  OnboardingPage(
    title: 'Offer a\nSeat',
    subtitle: 'Drive & Split Costs',
    description:
        'Got a car? Offer spare seats to fellow runners. '
        'Cover fuel costs and build bonds with your local running community.',
    gradientColors: [
      AppColors.secondary,
      AppColors.secondary.withValues(alpha: 0.65),
    ],
    illustration: IllustrationVariant.offerSeat,
    features: ['Cost Splitting', 'Seat Control', 'Driver Rating'],
  ),
  OnboardingPage(
    title: 'Plan Your\nRoute',
    subtitle: 'Smart Route Sync',
    description:
        'Set your pickup point, race venue, or training ground. '
        'SportConnect syncs detours automatically to keep everyone on schedule.',
    gradientColors: [
      AppColors.primary,
      AppColors.primary.withValues(alpha: 0.65),
    ],
    illustration: IllustrationVariant.planRoute,
    features: ['Live Routing', 'Detour Sync', 'Event Zones'],
  ),
  OnboardingPage(
    title: 'Connect\n& Go',
    subtitle: 'Community You Trust',
    description:
        'Verified runner profiles, in-app chat, and real-time tracking '
        'keep every carpool safe, social, and on time.',
    gradientColors: [
      AppColors.secondary,
      AppColors.secondary.withValues(alpha: 0.65),
    ],
    illustration: IllustrationVariant.connectGo,
    features: ['Verified Profiles', 'In-App Chat', 'Live Tracking'],
  ),
];
