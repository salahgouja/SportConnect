import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/auth/repositories/auth_repository.dart';
import 'package:sport_connect/features/auth/models/models.dart';

part 'auth_view_model.g.dart';

/// Tracks whether a new social sign-in user needs to pick a role.
///
/// Set to `true` right after Google/Apple sign-in creates a new account.
/// The route guard reads this to redirect to role-selection instead of home.
/// Cleared when the user selects a role on the RoleSelectionScreen.
@riverpod
class PendingRoleSelection extends _$PendingRoleSelection {
  @override
  bool build() => false;

  /// Sets the pending role selection state.
  void set(bool value) => state = value;
}

/// Auth repository provider
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository();
}

/// Login view model
@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> login(String email, String password, bool rememberMe) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithEmail(email, password, rememberMe);
      state = const AsyncValue.data(null);
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

/// Register view model
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

final authActionsViewModelProvider = Provider<AuthActionsViewModel>((ref) {
  return AuthActionsViewModel(ref);
});

class AuthActionsViewModel {
  AuthActionsViewModel(this._ref);

  final Ref _ref;

  Future<void> signOut() {
    return _ref.read(authRepositoryProvider).signOut();
  }

  Future<void> deleteAccount() {
    return _ref.read(authRepositoryProvider).deleteAccount();
  }

  User? get currentUser {
    return _ref.read(authRepositoryProvider).currentUser;
  }

  Future<void> createUserDocument(UserModel user) {
    return _ref.read(authRepositoryProvider).createUserDocument(user);
  }

  Future<SocialSignInResult> signInWithGoogle() {
    return _ref.read(authRepositoryProvider).signInWithGoogle();
  }

  Future<SocialSignInResult> signInWithApple() {
    return _ref.read(authRepositoryProvider).signInWithApple();
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
  }

  Future<void> updateUserRole(String uid, UserRole role) {
    return _ref.read(authRepositoryProvider).updateUserRole(uid, role);
  }

  Future<void> clearNeedsRoleSelection(String uid) {
    return _ref.read(authRepositoryProvider).clearNeedsRoleSelection(uid);
  }
}
