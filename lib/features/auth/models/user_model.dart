import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User roles in the app
enum UserRole {
  @JsonValue('rider')
  rider,
  @JsonValue('driver')
  driver;

  String get displayName {
    switch (this) {
      case UserRole.rider:
        return 'Rider';
      case UserRole.driver:
        return 'Driver';
    }
  }

  String get description {
    switch (this) {
      case UserRole.rider:
        return 'Find and book rides to sporting events';
      case UserRole.driver:
        return 'Offer rides and earn money';
    }
  }
}

/// User levels based on XP
enum UserLevel {
  bronze(0, 1000, 'Bronze', 1),
  silver(1000, 5000, 'Silver', 2),
  gold(5000, 15000, 'Gold', 3),
  platinum(15000, 35000, 'Platinum', 4),
  diamond(35000, double.infinity, 'Diamond', 5);

  final double minXP;
  final double maxXP;
  final String name;
  final int level;

  const UserLevel(this.minXP, this.maxXP, this.name, this.level);

  static UserLevel fromXP(int xp) {
    for (final level in UserLevel.values.reversed) {
      if (xp >= level.minXP) return level;
    }
    return UserLevel.bronze;
  }
}

/// Achievement model
@freezed
abstract class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String title,
    required String description,
    required String iconName,
    required int xpReward,
    @Default(false) bool isUnlocked,
    @TimestampConverter() DateTime? unlockedAt,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

/// Base gamification stats (shared by all users)
@freezed
abstract class GamificationStats with _$GamificationStats {
  const factory GamificationStats({
    @Default(0) int totalXP,
    @Default(1) int level,
    @Default(0) int currentLevelXP,
    @Default(1000) int xpToNextLevel,
    @Default(0) int totalRides,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0.0) double co2Saved,
    @Default(0.0) double totalDistance,
    @Default([]) List<String> unlockedBadges,
    @Default([]) List<Achievement> achievements,
    @TimestampConverter() DateTime? lastRideDate,
  }) = _GamificationStats;

  factory GamificationStats.fromJson(Map<String, dynamic> json) =>
      _$GamificationStatsFromJson(json);
}

/// Rider-specific gamification stats
@freezed
abstract class RiderGamificationStats with _$RiderGamificationStats {
  const factory RiderGamificationStats({
    @Default(0) int totalXP,
    @Default(1) int level,
    @Default(0) int currentLevelXP,
    @Default(1000) int xpToNextLevel,
    @Default(0) int totalRides,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0.0) double co2Saved,
    @Default(0.0) double moneySaved,
    @Default(0.0) double totalDistance,
    @Default([]) List<String> unlockedBadges,
    @Default([]) List<Achievement> achievements,
    @TimestampConverter() DateTime? lastRideDate,
  }) = _RiderGamificationStats;

  factory RiderGamificationStats.fromJson(Map<String, dynamic> json) =>
      _$RiderGamificationStatsFromJson(json);
}

/// Driver-specific gamification stats
@freezed
abstract class DriverGamificationStats with _$DriverGamificationStats {
  const factory DriverGamificationStats({
    @Default(0) int totalXP,
    @Default(1) int level,
    @Default(0) int currentLevelXP,
    @Default(1000) int xpToNextLevel,
    @Default(0) int totalRides,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0.0) double co2Saved,
    @Default(0.0) double totalEarnings,
    @Default(0.0) double totalDistance,
    @Default([]) List<String> unlockedBadges,
    @Default([]) List<Achievement> achievements,
    @TimestampConverter() DateTime? lastRideDate,
  }) = _DriverGamificationStats;

  factory DriverGamificationStats.fromJson(Map<String, dynamic> json) =>
      _$DriverGamificationStatsFromJson(json);
}

/// User preferences
@freezed
abstract class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default(true) bool notificationsEnabled,
    @Default(true) bool emailNotifications,
    @Default(true) bool rideReminders,
    @Default(true) bool chatNotifications,
    @Default(true) bool marketingEmails,
    @Default('en') String language,
    @Default('system') String theme,
    @Default(5.0) double maxPickupRadius,
    @Default(true) bool showOnlineStatus,
    @Default(true) bool allowMessages,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}

/// Vehicle information (Driver-specific)
@freezed
abstract class Vehicle with _$Vehicle {
  const factory Vehicle({
    required String id,
    required String make,
    required String model,
    required String fuelType,
    required int year,
    required String color,
    required String licensePlate,
    @Default(4) int seats,
    String? imageUrl,
    @Default(false) bool isDefault,
    @Default(false) bool isVerified,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);
}

/// Rating breakdown
@freezed
abstract class RatingBreakdown with _$RatingBreakdown {
  const factory RatingBreakdown({
    @Default(0) int total,
    @Default(0.0) double average,
    @Default(0) int fiveStars,
    @Default(0) int fourStars,
    @Default(0) int threeStars,
    @Default(0) int twoStars,
    @Default(0) int oneStars,
  }) = _RatingBreakdown;

  factory RatingBreakdown.fromJson(Map<String, dynamic> json) =>
      _$RatingBreakdownFromJson(json);
}

/// Base User model with fields shared by all user types
@freezed
sealed class UserModel with _$UserModel {
  const UserModel._();

  /// Rider user type
  const factory UserModel.rider({
    required String uid,
    required String email,
    required String displayName,
    String? photoUrl,
    String? phoneNumber,
    String? bio,
    @TimestampConverter() DateTime? dateOfBirth,
    String? gender,
    @Default([]) List<String> interests,

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
    @Default(RiderGamificationStats()) RiderGamificationStats gamification,

    // Preferences
    @Default(UserPreferences()) UserPreferences preferences,

    // FCM Token for push notifications
    String? fcmToken,

    // Timestamps
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @TimestampConverter() DateTime? lastSeenAt,
  }) = RiderModel;

  /// Driver user type
  const factory UserModel.driver({
    required String uid,
    required String email,
    required String displayName,
    String? photoUrl,
    String? phoneNumber,
    String? bio,
    @TimestampConverter() DateTime? dateOfBirth,
    String? gender,
    @Default([]) List<String> interests,

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

    // Driver-specific: Vehicles
    @Default([]) List<Vehicle> vehicles,

    // Driver-specific: Driver rating
    @Default(RatingBreakdown()) RatingBreakdown rating,

    // Driver-specific: Gamification
    @Default(DriverGamificationStats()) DriverGamificationStats gamification,

    // Driver-specific: Stripe
    String? stripeAccountId,
    @Default(false) bool isStripeEnabled,
    @Default(false) bool isStripeOnboarded,

    // Preferences
    @Default(UserPreferences()) UserPreferences preferences,

    // FCM Token for push notifications
    String? fcmToken,

    // Timestamps
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @TimestampConverter() DateTime? lastSeenAt,
  }) = DriverModel;

  /// Factory to create from JSON based on role field
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as String?;
    const timestampConverter = TimestampConverter();

    // Parse common fields
    final uid = json['uid'] as String;
    final email = json['email'] as String;
    final displayName = json['displayName'] as String? ?? '';
    final photoUrl = json['photoUrl'] as String?;
    final phoneNumber = json['phoneNumber'] as String?;
    final bio = json['bio'] as String?;
    final dateOfBirth = timestampConverter.fromJson(json['dateOfBirth']);
    final gender = json['gender'] as String?;
    final interests =
        (json['interests'] as List<dynamic>?)?.cast<String>() ?? [];
    final address = json['address'] as String?;
    final latitude = (json['latitude'] as num?)?.toDouble();
    final longitude = (json['longitude'] as num?)?.toDouble();
    final city = json['city'] as String?;
    final country = json['country'] as String?;
    final isEmailVerified = json['isEmailVerified'] as bool? ?? false;
    final isPhoneVerified = json['isPhoneVerified'] as bool? ?? false;
    final isIdVerified = json['isIdVerified'] as bool? ?? false;
    final isActive = json['isActive'] as bool? ?? true;
    final isOnline = json['isOnline'] as bool? ?? false;
    final isPremium = json['isPremium'] as bool? ?? false;
    final blockedUsers =
        (json['blockedUsers'] as List<dynamic>?)?.cast<String>() ?? [];
    final preferences = json['preferences'] != null
        ? UserPreferences.fromJson(
            Map<String, dynamic>.from(json['preferences'] as Map),
          )
        : const UserPreferences();
    final fcmToken = json['fcmToken'] as String?;
    final createdAt = timestampConverter.fromJson(json['createdAt']);
    final updatedAt = timestampConverter.fromJson(json['updatedAt']);
    final lastSeenAt = timestampConverter.fromJson(json['lastSeenAt']);
    final rating = json['rating'] != null
        ? RatingBreakdown.fromJson(
            Map<String, dynamic>.from(json['rating'] as Map),
          )
        : const RatingBreakdown();

    if (role == 'driver') {
      final vehicles =
          (json['vehicles'] as List<dynamic>?)
              ?.map(
                (v) => Vehicle.fromJson(Map<String, dynamic>.from(v as Map)),
              )
              .toList() ??
          [];
      final gamification = json['gamification'] != null
          ? DriverGamificationStats.fromJson(
              Map<String, dynamic>.from(json['gamification'] as Map),
            )
          : const DriverGamificationStats();

      return DriverModel(
        uid: uid,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        phoneNumber: phoneNumber,
        bio: bio,
        dateOfBirth: dateOfBirth,
        gender: gender,
        interests: interests,
        address: address,
        latitude: latitude,
        longitude: longitude,
        city: city,
        country: country,
        isEmailVerified: isEmailVerified,
        isPhoneVerified: isPhoneVerified,
        isIdVerified: isIdVerified,
        isActive: isActive,
        isOnline: isOnline,
        isPremium: isPremium,
        blockedUsers: blockedUsers,
        vehicles: vehicles,
        rating: rating,
        gamification: gamification,
        stripeAccountId: json['stripeAccountId'] as String?,
        isStripeEnabled: json['isStripeEnabled'] as bool? ?? false,
        isStripeOnboarded: json['isStripeOnboarded'] as bool? ?? false,
        preferences: preferences,
        fcmToken: fcmToken,
        createdAt: createdAt,
        updatedAt: updatedAt,
        lastSeenAt: lastSeenAt,
      );
    }

    // Default to RiderModel
    final favoriteRoutes =
        (json['favoriteRoutes'] as List<dynamic>?)?.cast<String>() ?? [];
    final gamification = json['gamification'] != null
        ? RiderGamificationStats.fromJson(
            Map<String, dynamic>.from(json['gamification'] as Map),
          )
        : const RiderGamificationStats();

    return RiderModel(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      bio: bio,
      dateOfBirth: dateOfBirth,
      gender: gender,
      interests: interests,
      address: address,
      latitude: latitude,
      longitude: longitude,
      city: city,
      country: country,
      isEmailVerified: isEmailVerified,
      isPhoneVerified: isPhoneVerified,
      isIdVerified: isIdVerified,
      isActive: isActive,
      isOnline: isOnline,
      isPremium: isPremium,
      blockedUsers: blockedUsers,
      favoriteRoutes: favoriteRoutes,
      rating: rating,
      gamification: gamification,
      preferences: preferences,
      fcmToken: fcmToken,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastSeenAt: lastSeenAt,
    );
  }

  /// Get the user role
  UserRole get role => switch (this) {
    RiderModel() => UserRole.rider,
    DriverModel() => UserRole.driver,
  };

  /// Get computed level info
  UserLevel get userLevel => switch (this) {
    RiderModel(:final gamification) => UserLevel.fromXP(gamification.totalXP),
    DriverModel(:final gamification) => UserLevel.fromXP(gamification.totalXP),
  };

  /// Progress to next level (0.0 to 1.0)
  double get levelProgress => switch (this) {
    RiderModel(:final gamification) =>
      gamification.xpToNextLevel == 0
          ? 1.0
          : gamification.currentLevelXP / gamification.xpToNextLevel,
    DriverModel(:final gamification) =>
      gamification.xpToNextLevel == 0
          ? 1.0
          : gamification.currentLevelXP / gamification.xpToNextLevel,
  };

  /// XP needed for next level
  int get xpNeeded => switch (this) {
    RiderModel(:final gamification) =>
      gamification.xpToNextLevel - gamification.currentLevelXP,
    DriverModel(:final gamification) =>
      gamification.xpToNextLevel - gamification.currentLevelXP,
  };

  /// Get total XP
  int get totalXP => switch (this) {
    RiderModel(:final gamification) => gamification.totalXP,
    DriverModel(:final gamification) => gamification.totalXP,
  };

  /// Get total rides
  int get totalRides => switch (this) {
    RiderModel(:final gamification) => gamification.totalRides,
    DriverModel(:final gamification) => gamification.totalRides,
  };

  /// Is profile complete
  bool get isProfileComplete => switch (this) {
    RiderModel(
      :final displayName,
      :final photoUrl,
      :final phoneNumber,
      :final isEmailVerified,
    ) =>
      displayName.isNotEmpty &&
          photoUrl != null &&
          phoneNumber != null &&
          isEmailVerified,
    DriverModel(
      :final displayName,
      :final photoUrl,
      :final phoneNumber,
      :final isEmailVerified,
      :final vehicles,
    ) =>
      displayName.isNotEmpty &&
          photoUrl != null &&
          phoneNumber != null &&
          isEmailVerified &&
          vehicles.isNotEmpty,
  };

  /// Check if this is a rider
  bool get isRider => this is RiderModel;

  /// Check if this is a driver
  bool get isDriver => this is DriverModel;

  /// Cast to RiderModel (throws if not a rider)
  RiderModel get asRider => this as RiderModel;

  /// Cast to DriverModel (throws if not a driver)
  DriverModel get asDriver => this as DriverModel;

  /// Safe cast to RiderModel (returns null if not a rider)
  RiderModel? get maybeRider => this is RiderModel ? this as RiderModel : null;

  /// Safe cast to DriverModel (returns null if not a driver)
  DriverModel? get maybeDriver =>
      this is DriverModel ? this as DriverModel : null;

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    const timestampConverter = TimestampConverter();

    final baseJson = <String, dynamic>{
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'dateOfBirth': timestampConverter.toJson(dateOfBirth),
      'gender': gender,
      'interests': interests,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'country': country,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'isIdVerified': isIdVerified,
      'isActive': isActive,
      'isOnline': isOnline,
      'isPremium': isPremium,
      'blockedUsers': blockedUsers,
      'rating': rating.toJson(),
      'preferences': preferences.toJson(),
      'fcmToken': fcmToken,
      'createdAt': timestampConverter.toJson(createdAt),
      'updatedAt': timestampConverter.toJson(updatedAt),
      'lastSeenAt': timestampConverter.toJson(lastSeenAt),
    };

    return switch (this) {
      RiderModel(:final favoriteRoutes, :final gamification) => {
        ...baseJson,
        'role': 'rider',
        'favoriteRoutes': favoriteRoutes,
        'gamification': gamification.toJson(),
      },
      DriverModel(
        :final vehicles,
        :final gamification,
        :final stripeAccountId,
        :final isStripeEnabled,
        :final isStripeOnboarded,
      ) =>
        {
          ...baseJson,
          'role': 'driver',
          'vehicles': vehicles.map((v) => v.toJson()).toList(),
          'gamification': gamification.toJson(),
          'stripeAccountId': stripeAccountId,
          'isStripeEnabled': isStripeEnabled,
          'isStripeOnboarded': isStripeOnboarded,
        },
    };
  }
}

/// Extension for DriverModel-specific properties
extension DriverModelExtensions on DriverModel {
  /// Default vehicle
  Vehicle? get defaultVehicle => vehicles.isEmpty
      ? null
      : vehicles.firstWhere((v) => v.isDefault, orElse: () => vehicles.first);

  /// Check if driver has completed onboarding (has at least one vehicle)
  bool get hasCompletedOnboarding => vehicles.isNotEmpty;

  /// Check if driver can receive payments
  bool get canReceivePayments => isStripeEnabled && isStripeOnboarded;
}

/// Extension for RiderModel-specific properties
extension RiderModelExtensions on RiderModel {
  /// Get money saved from carpooling
  double get moneySaved => gamification.moneySaved;

  /// Check if route is favorited
  bool isFavoriteRoute(String routeId) => favoriteRoutes.contains(routeId);
}

/// Timestamp converter for Firestore (nullable)
class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    return null;
  }

  @override
  dynamic toJson(DateTime? date) {
    if (date == null) return null;
    return Timestamp.fromDate(date);
  }
}

/// Timestamp converter for required DateTime fields (non-nullable)
class RequiredTimestampConverter implements JsonConverter<DateTime, dynamic> {
  const RequiredTimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    return DateTime.now(); // Fallback
  }

  @override
  dynamic toJson(DateTime date) {
    return Timestamp.fromDate(date);
  }
}

/// Leaderboard entry model
@freezed
abstract class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required String odid,
    required String displayName,
    String? photoUrl,
    required int totalXP,
    required int level,
    required int rank,
    @Default(0) int ridesThisMonth,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
}
