import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/auth/repositories/auth_repository.dart';
import 'package:sport_connect/features/auth/models/user_model.dart';
import 'package:sport_connect/core/config/app_router.dart';

part 'auth_view_model.g.dart';

/// Auth repository provider
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository();
}

/// Auth state changes provider
@riverpod
Stream<User?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

/// Current user data provider
@riverpod
Future<UserModel?> currentUser(Ref ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return await ref.read(authRepositoryProvider).getUserData(user.uid);
    },
    loading: () => null,
    error: (_, _) => null,
  );
}

/// Helper function to get the home route based on user role
/// Note: Driver onboarding for vehicles is handled within the driver home screen
String getHomeRouteForRole(UserModel userData) {
  switch (userData) {
    case DriverModel _:
      if (userData.vehicles.isEmpty) {
        return AppRouter.driverOnboarding;
      }
      return AppRouter.driverHome;
    case RiderModel _:
      return AppRouter.home;
  }
}

/// Initial route determination provider - follows MVVM by using repository
@riverpod
Future<String> initialRoute(Ref ref) async {
  final authRepo = ref.read(authRepositoryProvider);
  final user = authRepo.currentUser;

  TalkerService.debug(
    user != null ? '✅ User is logged in: ${user.uid}' : 'ℹ️ No user logged in.',
  );

  if (user != null) {
    try {
      // Refresh the token
      await user.getIdToken(true);

      // Get user data from repository
      final userData = await authRepo.getUserData(user.uid);

      TalkerService.debug(
        userData != null
            ? '✅ User document found in Firestore. Role: ${userData.role}'
            : '⚠️ No user document found in Firestore.',
      );

      if (userData == null) {
        TalkerService.debug(
          '⚠️ Account exists in Auth but not Firestore. Cleaning up...',
        );
        await authRepo.signOut();
        return AppRouter.login;
      }

      return getHomeRouteForRole(userData);
    } catch (e) {
      TalkerService.error('🔥 Critical Auth Error: $e');
      await authRepo.signOut();
      return AppRouter.login;
    }
  }

  // Not logged in flow
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  return onboardingCompleted ? AppRouter.login : AppRouter.onboarding;
}

/// Login view model using modern Riverpod Notifier
@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> login(String email, String password, bool rememberMe) async {
    state = const AsyncValue.loading();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signInWithEmail(email, password, rememberMe);
      state = AsyncValue<UserModel?>.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await ref.read(authRepositoryProvider).resetPassword(email);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

/// Register view model using modern Riverpod Notifier
@riverpod
class RegisterViewModel extends _$RegisterViewModel {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    String? phone,
    String? bio,
    List<String> interests = const [],
    File? profileImage,
  }) async {
    state = const AsyncValue.loading();

    try {
      await ref
          .read(authRepositoryProvider)
          .registerWithEmail(
            email: email,
            password: password,
            displayName: displayName,
            role: role,
            phone: phone,
            bio: bio,
            interests: interests,
            profileImage: profileImage,
          );
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
