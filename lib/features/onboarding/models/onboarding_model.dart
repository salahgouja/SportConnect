import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

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

const onboardingPageCount = 4;

List<OnboardingPage> localizedOnboardingPages(AppLocalizations l10n) => [
  OnboardingPage(
    title: l10n.onboardingFindYourRideTitle,
    subtitle: l10n.onboardingMatchWithRunners,
    description: l10n.onboardingFindYourRideDescription,
    gradientColors: [
      AppColors.primary,
      AppColors.primary.withValues(alpha: 0.65),
    ],
    illustration: IllustrationVariant.findRide,
    features: [
      l10n.onboardingSmartMatching,
      l10n.onboardingNearbyRunners,
      l10n.onboardingPaceFilters,
    ],
  ),
  OnboardingPage(
    title: l10n.onboardingOfferASeatTitle,
    subtitle: l10n.onboardingDriveSplitCosts,
    description: l10n.onboardingOfferASeatDescription,
    gradientColors: [
      AppColors.secondary,
      AppColors.secondary.withValues(alpha: 0.65),
    ],
    illustration: IllustrationVariant.offerSeat,
    features: [
      l10n.onboardingCostSplitting,
      l10n.onboardingSeatControl,
      l10n.onboardingDriverRating,
    ],
  ),
  OnboardingPage(
    title: l10n.onboardingPlanYourRouteTitle,
    subtitle: l10n.onboardingSmartRouteSync,
    description: l10n.onboardingPlanYourRouteDescription,
    gradientColors: [
      AppColors.primary,
      AppColors.primary.withValues(alpha: 0.65),
    ],
    illustration: IllustrationVariant.planRoute,
    features: [
      l10n.onboardingLiveRouting,
      l10n.onboardingDetourSync,
      l10n.onboardingEventZones,
    ],
  ),
  OnboardingPage(
    title: l10n.onboardingConnectGoModelTitle,
    subtitle: l10n.onboardingCommunityYouTrust,
    description: l10n.onboardingConnectGoModelDescription,
    gradientColors: [
      AppColors.secondary,
      AppColors.secondary.withValues(alpha: 0.65),
    ],
    illustration: IllustrationVariant.connectGo,
    features: [
      l10n.onboardingVerifiedProfiles,
      l10n.onboardingInAppChat,
      l10n.onboardingLiveTracking,
    ],
  ),
];
