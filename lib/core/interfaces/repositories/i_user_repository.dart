import 'dart:io';

import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/profile/models/leaderboard_entry.dart';
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
  });

  Future<void> updateUser(UserModel user);
  Future<void> updateUserField(String userId, String field, dynamic value);
  Future<void> updateProfile(String uid, Map<String, dynamic> updates);
  Future<void> updateProfilePhoto(String uid, File file);

  // Online Status
  Future<void> updateOnlineStatus(String userId, bool isOnline);
  Stream<bool> getUserOnlineStatus(String userId);

  // Block/Unblock
  Future<void> blockUser(String currentUserId, String targetUserId);
  Future<void> unblockUser(String currentUserId, String targetUserId);

  // Vehicles
  Future<void> addVehicle(String uid, VehicleModel vehicle);
  Future<void> updateVehicle(String uid, VehicleModel vehicle);
  Future<void> removeVehicle(String uid, String vehicleId);
  Future<void> setDefaultVehicle(String uid, String vehicleId);
  Future<List<VehicleModel>> getDriverVehicles(String uid);

  // Leaderboard / Gamification
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 50});
  Future<int> getUserRank(String uid);
}
