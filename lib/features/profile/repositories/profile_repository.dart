import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/features/auth/models/user_model.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';

part 'profile_repository.g.dart';

/// Profile Repository for user operations - Firebase only
class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProfileRepository(this._firestore, this._storage);

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(AppConstants.usersCollection);

  // ==================== USER PROFILE ====================

  /// Get user by ID
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data()!);
  }

  /// Stream user profile
  Stream<UserModel?> streamUser(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!);
    });
  }

  /// Update user profile
  Future<void> updateProfile(String uid, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _usersCollection.doc(uid).update(updates);
  }

  /// Upload profile photo
  Future<String> uploadProfilePhoto(String uid, File file) async {
    final ref = _storage.ref().child('users/$uid/profile.jpg');

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'userId': uid},
    );

    await ref.putFile(file, metadata);
    return await ref.getDownloadURL();
  }

  /// Update profile photo
  Future<void> updateProfilePhoto(String uid, File file) async {
    final photoUrl = await uploadProfilePhoto(uid, file);
    await updateProfile(uid, {'photoUrl': photoUrl});
  }

  /// Delete profile photo
  Future<void> deleteProfilePhoto(String uid) async {
    try {
      final ref = _storage.ref().child('users/$uid/profile.jpg');
      await ref.delete();
      await updateProfile(uid, {'photoUrl': null});
    } catch (e) {
      // Photo might not exist, ignore
    }
  }

  // ==================== ONLINE STATUS ====================

  /// Update online status
  Future<void> setOnlineStatus(String uid, bool isOnline) async {
    await _usersCollection.doc(uid).update({
      'isOnline': isOnline,
      'lastSeenAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update FCM token
  Future<void> updateFCMToken(String uid, String token) async {
    await _usersCollection.doc(uid).update({'fcmToken': token});
  }

  // ==================== SOCIAL FEATURES ====================

  /// Follow a user
  Future<void> followUser(String currentUserId, String targetUserId) async {
    final batch = _firestore.batch();

    batch.update(_usersCollection.doc(currentUserId), {
      'following': FieldValue.arrayUnion([targetUserId]),
    });

    batch.update(_usersCollection.doc(targetUserId), {
      'followers': FieldValue.arrayUnion([currentUserId]),
    });

    await batch.commit();
  }

  /// Unfollow a user
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    final batch = _firestore.batch();

    batch.update(_usersCollection.doc(currentUserId), {
      'following': FieldValue.arrayRemove([targetUserId]),
    });

    batch.update(_usersCollection.doc(targetUserId), {
      'followers': FieldValue.arrayRemove([currentUserId]),
    });

    await batch.commit();
  }

  /// Block a user
  Future<void> blockUser(String currentUserId, String targetUserId) async {
    await unfollowUser(currentUserId, targetUserId);
    await _usersCollection.doc(currentUserId).update({
      'blockedUsers': FieldValue.arrayUnion([targetUserId]),
    });
  }

  /// Unblock a user
  Future<void> unblockUser(String currentUserId, String targetUserId) async {
    await _usersCollection.doc(currentUserId).update({
      'blockedUsers': FieldValue.arrayRemove([targetUserId]),
    });
  }

  /// Get user's followers (deprecated - social features removed)
  Future<List<UserModel>> getFollowers(String uid) async {
    // Followers feature has been removed - return empty list
    return [];
  }

  /// Get users that user is following (deprecated - social features removed)
  Future<List<UserModel>> getFollowing(String uid) async {
    // Following feature has been removed - return empty list
    return [];
  }

  // ==================== VEHICLES (Driver Only) ====================

  /// Add a vehicle (only for drivers)
  Future<void> addVehicle(String uid, Vehicle vehicle) async {
    final user = await getUserById(uid);
    if (user == null || user is! DriverModel) return;

    final driver = user;
    final isDefault = driver.vehicles.isEmpty;
    final vehicleWithDefault = vehicle.copyWith(isDefault: isDefault);

    await _usersCollection.doc(uid).update({
      'vehicles': FieldValue.arrayUnion([vehicleWithDefault.toJson()]),
    });
  }

  /// Update a vehicle (only for drivers)
  Future<void> updateVehicle(String uid, Vehicle vehicle) async {
    final user = await getUserById(uid);
    if (user == null || user is! DriverModel) return;

    final driver = user;
    final updatedVehicles = driver.vehicles.map((v) {
      if (v.id == vehicle.id) return vehicle;
      return v;
    }).toList();

    await _usersCollection.doc(uid).update({
      'vehicles': updatedVehicles.map((v) => v.toJson()).toList(),
    });
  }

  /// Remove a vehicle (only for drivers)
  Future<void> removeVehicle(String uid, String vehicleId) async {
    final user = await getUserById(uid);
    if (user == null || user is! DriverModel) return;

    final driver = user;
    final updatedVehicles = driver.vehicles
        .where((v) => v.id != vehicleId)
        .toList();

    await _usersCollection.doc(uid).update({
      'vehicles': updatedVehicles.map((v) => v.toJson()).toList(),
    });
  }

  /// Set default vehicle (only for drivers)
  Future<void> setDefaultVehicle(String uid, String vehicleId) async {
    final user = await getUserById(uid);
    if (user == null || user is! DriverModel) return;

    final driver = user;
    final updatedVehicles = driver.vehicles.map((v) {
      return v.copyWith(isDefault: v.id == vehicleId);
    }).toList();

    await _usersCollection.doc(uid).update({
      'vehicles': updatedVehicles.map((v) => v.toJson()).toList(),
    });
  }

  // ==================== GAMIFICATION ====================

  /// Add XP to user - works with both RiderModel and DriverModel
  Future<void> addXP(String uid, int xp) async {
    final user = await getUserById(uid);
    if (user == null) return;

    // Get current gamification stats based on user type
    final (
      int totalXP,
      int currentLevelXP,
      int level,
      int xpToNextLevel,
    ) = switch (user) {
      RiderModel(:final gamification) => (
        gamification.totalXP,
        gamification.currentLevelXP,
        gamification.level,
        gamification.xpToNextLevel,
      ),
      DriverModel(:final gamification) => (
        gamification.totalXP,
        gamification.currentLevelXP,
        gamification.level,
        gamification.xpToNextLevel,
      ),
    };

    var newTotalXP = totalXP + xp;
    var newCurrentLevelXP = currentLevelXP + xp;
    var newLevel = level;
    var newXpToNextLevel = xpToNextLevel;

    // Check for level up
    while (newCurrentLevelXP >= newXpToNextLevel) {
      newLevel++;
      newCurrentLevelXP -= newXpToNextLevel;
      newXpToNextLevel = (newXpToNextLevel * 1.2).round();
    }

    await _usersCollection.doc(uid).update({
      'gamification.totalXP': newTotalXP,
      'gamification.level': newLevel,
      'gamification.currentLevelXP': newCurrentLevelXP,
      'gamification.xpToNextLevel': newXpToNextLevel,
    });
  }

  /// Update streak
  Future<void> updateStreak(String uid) async {
    final user = await getUserById(uid);
    if (user == null) return;

    final now = DateTime.now();
    final (
      DateTime? lastRide,
      int currentStreak,
      int longestStreak,
    ) = switch (user) {
      RiderModel(:final gamification) => (
        gamification.lastRideDate,
        gamification.currentStreak,
        gamification.longestStreak,
      ),
      DriverModel(:final gamification) => (
        gamification.lastRideDate,
        gamification.currentStreak,
        gamification.longestStreak,
      ),
    };

    var newCurrentStreak = currentStreak;
    var newLongestStreak = longestStreak;

    if (lastRide == null) {
      newCurrentStreak = 1;
    } else {
      final difference = now.difference(lastRide).inDays;
      if (difference == 1) {
        newCurrentStreak++;
      } else if (difference > 1) {
        newCurrentStreak = 1;
      }
    }

    if (newCurrentStreak > newLongestStreak) {
      newLongestStreak = newCurrentStreak;
    }

    await _usersCollection.doc(uid).update({
      'gamification.currentStreak': newCurrentStreak,
      'gamification.longestStreak': newLongestStreak,
      'gamification.lastRideDate': Timestamp.now(),
    });
  }

  /// Update ride stats
  Future<void> updateRideStats({
    required String uid,
    required bool asDriver,
    required double distance,
  }) async {
    final updates = <String, dynamic>{
      'gamification.totalRides': FieldValue.increment(1),
      'gamification.totalDistance': FieldValue.increment(distance),
      'gamification.co2Saved': FieldValue.increment(distance * 0.12),
    };

    if (asDriver) {
      updates['gamification.ridesAsDriver'] = FieldValue.increment(1);
    } else {
      updates['gamification.ridesAsPassenger'] = FieldValue.increment(1);
      updates['gamification.moneySaved'] = FieldValue.increment(
        distance * 0.15,
      );
    }

    await _usersCollection.doc(uid).update(updates);
  }

  /// Unlock achievement
  Future<void> unlockAchievement(String uid, String achievementId) async {
    await _usersCollection.doc(uid).update({
      'gamification.unlockedBadges': FieldValue.arrayUnion([achievementId]),
    });
  }

  // ==================== RATINGS ====================

  /// Add rating - now simplified since each user type has one rating
  Future<void> addRating({
    required String uid,
    required double rating,
    required bool asDriver,
  }) async {
    final user = await getUserById(uid);
    if (user == null) return;

    // Get current rating breakdown
    final breakdown = user.rating;
    final newTotal = breakdown.total + 1;
    final newAverage =
        ((breakdown.average * breakdown.total) + rating) / newTotal;

    final updates = <String, dynamic>{};

    updates['rating.total'] = newTotal;
    updates['rating.average'] = newAverage;

    if (rating >= 4.5) {
      updates['rating.fiveStars'] = FieldValue.increment(1);
    } else if (rating >= 3.5) {
      updates['rating.fourStars'] = FieldValue.increment(1);
    } else if (rating >= 2.5) {
      updates['rating.threeStars'] = FieldValue.increment(1);
    } else if (rating >= 1.5) {
      updates['rating.twoStars'] = FieldValue.increment(1);
    } else {
      updates['rating.oneStars'] = FieldValue.increment(1);
    }

    await _usersCollection.doc(uid).update(updates);
  }

  // ==================== LEADERBOARD ====================

  /// Get leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 50}) async {
    final query = await _usersCollection
        .orderBy('gamification.totalXP', descending: true)
        .limit(limit)
        .get();

    int rank = 0;
    return query.docs.map((doc) {
      rank++;
      final user = UserModel.fromJson(doc.data());
      return LeaderboardEntry(
        odid: user.uid,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        totalXP: user.totalXP,
        level: user.userLevel.level,
        rank: rank,
        ridesThisMonth: user.totalRides,
      );
    }).toList();
  }

  /// Get user's rank
  Future<int> getUserRank(String uid) async {
    final user = await getUserById(uid);
    if (user == null) return 0;

    final query = await _usersCollection
        .where('gamification.totalXP', isGreaterThan: user.totalXP)
        .count()
        .get();

    return (query.count ?? 0) + 1;
  }

  // ==================== PREFERENCES ====================

  /// Update preferences
  Future<void> updatePreferences(
    String uid,
    UserPreferences preferences,
  ) async {
    await _usersCollection.doc(uid).update({
      'preferences': preferences.toJson(),
    });
  }

  // ==================== SEARCH ====================

  /// Search users
  Future<List<UserModel>> searchUsers(String query, {int limit = 20}) async {
    if (query.isEmpty) return [];

    final results = await _usersCollection
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(limit)
        .get();

    return results.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }
}

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
}

/// Stream provider for current user
@riverpod
Stream<UserModel?> currentUserStream(Ref ref) {
  final repository = ref.watch(profileRepositoryProvider);
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return repository.streamUser(user.uid);
}

/// Stream provider for a user by ID
@riverpod
Stream<UserModel?> userStream(Ref ref, String userId) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.streamUser(userId);
}
