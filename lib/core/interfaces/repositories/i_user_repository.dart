import 'dart:io';

import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';

/// User data repository interface
abstract class IUserRepository {
  // User Data Operations
  Future<UserModel?> getUserById(String userId);
  Stream<UserModel?> streamUser(String userId);
  Future<List<UserModel>> searchUsers({
    String? query,
    UserRole? role,
    int? limit,
    Iterable<String>? excludeUserIds,
    String? excludeUsersWhoBlockedId,
  });

  Future<void> updateUser(UserModel user);
  Future<void> updateUserField(String userId, String field, dynamic value);
  Future<void> updateProfile(String uid, Map<String, dynamic> updates);
  Future<void> updateProfilePhoto(String uid, File file);

  // Block/Unblock
  Future<void> blockUser(String currentUserId, String targetUserId);
  Future<void> unblockUser(String currentUserId, String targetUserId);
  Future<bool> isUserBlocked({
    required String userId,
    required String blockedUserId,
  });
  Stream<List<String>> streamBlockedUserIds(String userId);

  // Vehicles
  Future<void> addVehicle(String uid, VehicleModel vehicle);
  Future<void> updateVehicle(String uid, VehicleModel vehicle);
  Future<void> removeVehicle(String uid, String vehicleId);
  Future<void> setDefaultVehicle(String uid, String vehicleId);
  Future<List<VehicleModel>> getDriverVehicles(String uid);

  // Leaderboard / Gamification
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 50});
  Future<int> getUserRank(String uid);

  /// Add XP to user. Returns the new level if a level-up occurred, or null.
  Future<int?> addXP(String uid, int xp);
  Future<void> updateStreak(String uid);

  /// Reset streak to 0 (no-show penalty).
  Future<void> resetStreak(String uid);
  Future<void> updateRideStats({
    required String uid,
    required bool asDriver,
    required double distance,
    int fareAmountPaidInCents = 0,
  });
  Future<void> unlockAchievement(String uid, String achievementId);

  /// Evaluate and unlock achievements. Returns list of newly unlocked badge IDs.
  Future<List<String>> evaluateAchievements(String uid);
}
