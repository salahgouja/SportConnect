import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';

import 'gamification_stats.dart';
import 'rating_breakdown.dart';
import 'user_enums.dart';
import 'user_preferences.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Base User model
@Freezed(unionKey: 'role')
sealed class UserModel with _$UserModel {
  const UserModel._();

  /// Rider user type
  @FreezedUnionValue('rider')
  const factory UserModel.rider({
    required String uid,
    required String email,
    required String displayName,
    String? photoUrl,
    String? phoneNumber,
    @TimestampConverter() DateTime? dateOfBirth,
    String? gender,
    @Default("") String fcmToken,

    // Address & location
    String? address,
    double? latitude,
    double? longitude,
    String? city,
    String? country,

    // Verification & status
    @Default(false) bool isEmailVerified,
    @Default(false) bool isPhoneVerified,
    @Default(false) bool isIdVerified,
    @Default(true) bool isActive,
    @Default(false) bool isOnline,
    @Default(false) bool isPremium,

    // Social
    @Default([]) List<String> blockedUsers,

    // Rider-specific: Favorite routes
    @Default([]) List<String> favoriteRoutes,

    // Rider-specific: Passenger rating
    @Default(RatingBreakdown()) RatingBreakdown rating,

    // Rider-specific: Gamification
    // CHANGED: Use the factory constructor .rider()
    @Default(GamificationStats.rider()) GamificationStats gamification,

    // Onboarding
    @Default(false) bool needsRoleSelection,

    // Preferences
    @Default(UserPreferences()) UserPreferences preferences,

    // Expertise
    @Default(Expertise.rookie) Expertise expertise,

    // Timestamps
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @TimestampConverter() DateTime? lastSeenAt,
  }) = RiderModel;

  /// Driver user type
  @FreezedUnionValue('driver')
  const factory UserModel.driver({
    required String uid,
    required String email,
    required String displayName,
    String? photoUrl,
    String? phoneNumber,
    @TimestampConverter() DateTime? dateOfBirth,
    String? gender,
    @Default("") String fcmToken,

    // Address & location
    String? address,
    double? latitude,
    double? longitude,
    String? city,
    String? country,

    // Verification & status
    @Default(false) bool isEmailVerified,
    @Default(false) bool isPhoneVerified,
    @Default(false) bool isIdVerified,
    @Default(true) bool isActive,
    @Default(false) bool isOnline,
    @Default(false) bool isPremium,

    // Social
    @Default([]) List<String> blockedUsers,

    // Driver-specific: Vehicle IDs (resolved through VehicleRepository)
    @Default([]) List<String> vehicleIds,

    // Driver-specific: Driver rating
    @Default(RatingBreakdown()) RatingBreakdown rating,

    // Driver-specific: Gamification
    @Default(GamificationStats.driver()) GamificationStats gamification,

    // Driver-specific: Stripe Connect (fields mirror Cloud Function writes)
    String? stripeAccountId,
    String? stripeCustomerId,
    @Default(false) bool isStripeEnabled,
    @Default(false) bool isStripeOnboarded,

    /// "pending" | "active" | "under_review" | "incomplete"
    String? stripeAccountStatus,

    /// Whether Stripe has enabled charges on this account
    @Default(false) bool chargesEnabled,

    /// Whether Stripe has enabled payouts on this account
    @Default(false) bool payoutsEnabled,

    /// Whether the driver has submitted all required Stripe details
    @Default(false) bool detailsSubmitted,

    /// Outstanding Stripe requirements (e.g. ["individual.dob"])
    @Default([]) List<String> stripeRequirements,

    /// Reason charges/payouts are disabled, if any
    String? stripeDisabledReason,

    // Onboarding
    @Default(false) bool needsRoleSelection,

    // Preferences
    @Default(UserPreferences()) UserPreferences preferences,

    // Expertise
    @Default(Expertise.rookie) Expertise expertise,

    // Timestamps
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @TimestampConverter() DateTime? lastSeenAt,
  }) = DriverModel;

  /// Auto-generated JSON serialization
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

// ==============================================================================
// LOGIC EXTENSIONS
// ==============================================================================

/// Logic for all User types
extension UserModelLogic on UserModel {
  GamificationStats get _commonStats =>
      map(rider: (r) => r.gamification, driver: (d) => d.gamification);

  UserRole get role =>
      map(rider: (_) => UserRole.rider, driver: (_) => UserRole.driver);

  // Works because 'totalXP' exists on the base GamificationStats class
  UserLevel get userLevel => UserLevel.fromXP(_commonStats.totalXP);

  double get levelProgress {
    final stats = _commonStats;
    return stats.xpToNextLevel == 0
        ? 1.0
        : stats.currentLevelXP / stats.xpToNextLevel;
  }

  int get xpNeeded {
    final stats = _commonStats;
    return stats.xpToNextLevel - stats.currentLevelXP;
  }

  int get totalXP => _commonStats.totalXP;
  int get totalRides => _commonStats.totalRides;

  /// Profile completion check
  bool get isProfileComplete {
    final bool basicInfo =
        displayName.isNotEmpty &&
        photoUrl != null &&
        phoneNumber != null &&
        isEmailVerified;

    return map(
      rider: (_) => basicInfo,
      driver: (d) => basicInfo && d.vehicleIds.isNotEmpty,
    );
  }
}

/// Helper getters for type checking
extension UserTypeCheck on UserModel {
  bool get isRider => this is RiderModel;
  bool get isDriver => this is DriverModel;

  RiderModel? get asRider => this is RiderModel ? this as RiderModel : null;
  DriverModel? get asDriver => this is DriverModel ? this as DriverModel : null;
}

/// Rider specific logic
extension RiderLogic on RiderModel {
  double get moneySaved => gamification.maybeMap(
    rider: (data) => data.moneySaved,
    orElse: () => 0.0,
  );

  bool isFavoriteRoute(String routeId) => favoriteRoutes.contains(routeId);
}

/// Driver specific logic
extension DriverLogic on DriverModel {
  /// Safely extract totalEarnings using pattern matching
  double get totalEarnings => gamification.maybeMap(
    driver: (data) => data.totalEarnings,
    orElse: () => 0.0,
  );

  /// Backward-compat alias – views reference `.vehicles` but
  /// the Freezed field is `vehicleIds`.
  List<String> get vehicles => vehicleIds;

  bool get hasVehicles => vehicleIds.isNotEmpty;
  bool get hasCompletedOnboarding => vehicleIds.isNotEmpty;
  bool get canReceivePayments => isStripeEnabled && isStripeOnboarded;
}
