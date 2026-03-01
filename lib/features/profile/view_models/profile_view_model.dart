import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/core/providers/repository_providers.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';

part 'profile_view_model.g.dart';

/// Profile Edit State
class ProfileEditState {
  final String displayName;
  final String? bio;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final List<String> interests;
  final File? newPhotoFile;
  final bool isLoading;
  final bool isSaved;
  final String? error;

  const ProfileEditState({
    this.displayName = '',
    this.bio,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.interests = const [],
    this.newPhotoFile,
    this.isLoading = false,
    this.isSaved = false,
    this.error,
  });

  ProfileEditState copyWith({
    String? displayName,
    String? bio,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    List<String>? interests,
    File? newPhotoFile,
    bool? isLoading,
    bool? isSaved,
    String? error,
  }) {
    return ProfileEditState(
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      interests: interests ?? this.interests,
      newPhotoFile: newPhotoFile ?? this.newPhotoFile,
      isLoading: isLoading ?? this.isLoading,
      isSaved: isSaved ?? this.isSaved,
      error: error,
    );
  }

  factory ProfileEditState.fromUser(UserModel user) {
    return ProfileEditState(
      displayName: user.displayName,
      bio: user.bio,
      phoneNumber: user.phoneNumber,
      dateOfBirth: user.dateOfBirth,
      gender: user.gender,
      interests: user.interests,
    );
  }
}

final profileActionsViewModelProvider = Provider<ProfileActionsViewModel>((
  ref,
) {
  return ProfileActionsViewModel(ref);
});

class ProfileActionsViewModel {
  ProfileActionsViewModel(this._ref);

  final Ref _ref;

  Future<List<UserModel>> searchUsers({required String query}) {
    return _ref.read(profileRepositoryProvider).searchUsers(query: query);
  }

  Future<UserModel?> getUserById(String userId) {
    return _ref.read(profileRepositoryProvider).getUserById(userId);
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> updates) {
    return _ref.read(profileRepositoryProvider).updateProfile(uid, updates);
  }

  Future<void> updateProfilePhoto(String uid, File imageFile) {
    return _ref
        .read(profileRepositoryProvider)
        .updateProfilePhoto(uid, imageFile);
  }

  Future<void> setDefaultVehicle(String uid, String vehicleId) {
    return _ref
        .read(profileRepositoryProvider)
        .setDefaultVehicle(uid, vehicleId);
  }

  Future<void> removeVehicle(String uid, String vehicleId) {
    return _ref.read(profileRepositoryProvider).removeVehicle(uid, vehicleId);
  }

  Future<void> updateVehicle(String uid, VehicleModel vehicle) {
    return _ref.read(profileRepositoryProvider).updateVehicle(uid, vehicle);
  }

  Future<void> addVehicle(String uid, VehicleModel vehicle) {
    return _ref.read(profileRepositoryProvider).addVehicle(uid, vehicle);
  }

  /// Submits a report about a user or ride.
  Future<String> submitReport({
    required String reporterId,
    required String reporterEmail,
    required String type,
    required String severity,
    required String description,
    String? reportedUserId,
    String? rideId,
    List<File> attachments = const [],
  }) {
    return _ref
        .read(supportRepositoryProvider)
        .submitReport(
          reporterId: reporterId,
          reporterEmail: reporterEmail,
          type: type,
          severity: severity,
          description: description,
          reportedUserId: reportedUserId,
          rideId: rideId,
          attachments: attachments,
        );
  }

  /// Submits a support ticket on behalf of the user.
  Future<String> submitSupportTicket({
    required String userId,
    required String userEmail,
    required String userName,
    required String category,
    required String subject,
    required String message,
    List<File> attachments = const [],
  }) {
    return _ref
        .read(supportRepositoryProvider)
        .submitSupportTicket(
          userId: userId,
          userEmail: userEmail,
          userName: userName,
          category: category,
          subject: subject,
          message: message,
          attachments: attachments,
        );
  }
}

/// Current User Profile Stream
@riverpod
Stream<UserModel?> currentUserProfile(Ref ref, String uid) {
  final repository = ref.read(profileRepositoryProvider);
  return repository.streamUser(uid);
}

/// Other User Profile
@riverpod
Future<UserModel?> userProfile(Ref ref, String uid) async {
  final repository = ref.read(profileRepositoryProvider);
  return repository.getUserById(uid);
}

/// Profile Edit View Model
@riverpod
class ProfileEditViewModel extends _$ProfileEditViewModel {
  @override
  ProfileEditState build(String uid) {
    return const ProfileEditState();
  }

  void initFromUser(UserModel user) {
    state = ProfileEditState.fromUser(user);
  }

  void setDisplayName(String name) {
    state = state.copyWith(displayName: name);
  }

  void setBio(String bio) {
    state = state.copyWith(bio: bio);
  }

  void setPhoneNumber(String phone) {
    state = state.copyWith(phoneNumber: phone);
  }

  void setDateOfBirth(DateTime date) {
    state = state.copyWith(dateOfBirth: date);
  }

  void setGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void setInterests(List<String> interests) {
    state = state.copyWith(interests: interests);
  }

  void addInterest(String interest) {
    if (!state.interests.contains(interest)) {
      state = state.copyWith(interests: [...state.interests, interest]);
    }
  }

  void removeInterest(String interest) {
    state = state.copyWith(
      interests: state.interests.where((i) => i != interest).toList(),
    );
  }

  void setPhotoFile(File? file) {
    state = state.copyWith(newPhotoFile: file);
  }

  Future<bool> saveProfile() async {
    if (state.displayName.trim().isEmpty) {
      state = state.copyWith(error: 'Display name is required');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(profileRepositoryProvider);

      // Upload photo if changed
      if (state.newPhotoFile != null) {
        await repository.updateProfilePhoto(uid, state.newPhotoFile!);
        if (!ref.mounted) return false;
      }

      // Update profile
      await repository.updateProfile(uid, {
        'displayName': state.displayName,
        'bio': state.bio,
        'phoneNumber': state.phoneNumber,
        'dateOfBirth': state.dateOfBirth,
        'gender': state.gender,
        'interests': state.interests,
      });

      if (!ref.mounted) return true;
      state = state.copyWith(isLoading: false, isSaved: true);
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

/// Social Actions View Model
@riverpod
class SocialActionsViewModel extends _$SocialActionsViewModel {
  @override
  SocialState build(String currentUserId, String targetUserId) {
    _checkFollowStatus();
    return const SocialState();
  }

  Future<void> _checkFollowStatus() async {
    try {
      final repository = ref.read(profileRepositoryProvider);
      final currentUser = await repository.getUserById(currentUserId);

      if (!ref.mounted) return;
      if (currentUser != null) {
        state = state.copyWith(
          isFollowing: false,
          isBlocked: currentUser.blockedUsers.contains(targetUserId),
        );
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> toggleBlock() async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(profileRepositoryProvider);

      if (state.isBlocked) {
        await repository.unblockUser(currentUserId, targetUserId);
      } else {
        await repository.blockUser(currentUserId, targetUserId);
      }

      if (!ref.mounted) return;
      state = state.copyWith(
        isBlocked: !state.isBlocked,
        // When blocking, clear follow status; when unblocking, preserve it.
        isFollowing: state.isBlocked ? state.isFollowing : false,
        isLoading: false,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

class SocialState {
  final bool isFollowing;
  final bool isBlocked;
  final bool isLoading;
  final String? error;

  const SocialState({
    this.isFollowing = false,
    this.isBlocked = false,
    this.isLoading = false,
    this.error,
  });

  SocialState copyWith({
    bool? isFollowing,
    bool? isBlocked,
    bool? isLoading,
    String? error,
  }) {
    return SocialState(
      isFollowing: isFollowing ?? this.isFollowing,
      isBlocked: isBlocked ?? this.isBlocked,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Vehicle Management View Model
@riverpod
class VehicleViewModel extends _$VehicleViewModel {
  @override
  VehicleState build(String uid) {
    return const VehicleState();
  }

  Future<void> addVehicle(VehicleModel vehicle) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(profileRepositoryProvider);
      await repository.addVehicle(uid, vehicle);
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateVehicle(VehicleModel vehicle) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(profileRepositoryProvider);
      await repository.updateVehicle(uid, vehicle);
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> removeVehicle(String vehicleId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(profileRepositoryProvider);
      await repository.removeVehicle(uid, vehicleId);
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setDefault(String vehicleId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(profileRepositoryProvider);
      await repository.setDefaultVehicle(uid, vehicleId);
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

class VehicleState {
  final bool isLoading;
  final String? error;

  const VehicleState({this.isLoading = false, this.error});

  VehicleState copyWith({bool? isLoading, String? error}) {
    return VehicleState(isLoading: isLoading ?? this.isLoading, error: error);
  }
}

/// Leaderboard Provider
@riverpod
Future<List<LeaderboardEntry>> leaderboard(Ref ref) async {
  final repository = ref.read(profileRepositoryProvider);
  return repository.getLeaderboard();
}

/// User Rank Provider
@riverpod
Future<int> userRank(Ref ref, String uid) async {
  final repository = ref.read(profileRepositoryProvider);
  return repository.getUserRank(uid);
}
