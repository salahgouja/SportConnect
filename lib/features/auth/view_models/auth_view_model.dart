import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/interfaces/repositories/i_auth_repository.dart';
import 'package:sport_connect/core/services/analytics_service.dart';
import 'package:sport_connect/features/auth/repositories/auth_repository.dart';
import 'package:sport_connect/features/auth/models/models.dart';

part 'auth_view_model.g.dart';

/// Auth repository provider.
///
/// Returns the interface type so consumers depend on the abstraction,
/// making it easy to swap implementations or provide mocks in tests.
@riverpod
IAuthRepository authRepository(Ref ref) {
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
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) AnalyticsService.instance.setUserId(uid);
      AnalyticsService.instance.logLogin('email');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      // Rethrow so calling widgets (e.g. ForgotPasswordScreen) can also
      // handle the error directly (e.g. show a snackbar with the message).
      rethrow;
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
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) AnalyticsService.instance.setUserId(uid);
      AnalyticsService.instance.logSignUp('email');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

/// Provides shared auth actions (sign-out, social sign-in, role management).
///
/// Declaring this as a [Provider] at global scope is intentional: the class
/// is a thin pass-through over [authRepositoryProvider] and carries no local
/// state, so it does not need to be auto-disposed per-widget.
@riverpod
AuthActionsViewModel authActionsViewModel(Ref ref) => AuthActionsViewModel(ref);

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

  Future<SocialSignInResult> signInWithGoogle() async {
    final result = await _ref.read(authRepositoryProvider).signInWithGoogle();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) AnalyticsService.instance.setUserId(uid);
    AnalyticsService.instance.logLogin('google');
    return result;
  }

  Future<SocialSignInResult> signInWithApple() async {
    final result = await _ref.read(authRepositoryProvider).signInWithApple();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) AnalyticsService.instance.setUserId(uid);
    AnalyticsService.instance.logLogin('apple');
    return result;
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

  Future<void> reauthenticateWithPassword(String password) {
    return _ref
        .read(authRepositoryProvider)
        .reauthenticateWithPassword(password);
  }

  Future<void> reauthenticateWithGoogle() {
    return _ref.read(authRepositoryProvider).reauthenticateWithGoogle();
  }

  // ── Email verification ──────────────────────────────────────────────

  Future<void> sendEmailVerification() {
    return _ref.read(authRepositoryProvider).sendEmailVerification();
  }

  Future<bool> isEmailVerified() {
    return _ref.read(authRepositoryProvider).isEmailVerified();
  }

  Future<void> reloadUser() {
    return _ref.read(authRepositoryProvider).reloadUser();
  }

  // ── Phone OTP ───────────────────────────────────────────────────────

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken)
        onCodeSent,
    required void Function(FirebaseAuthException error)
        onVerificationFailed,
    required void Function(PhoneAuthCredential credential)
        onVerificationCompleted,
    required void Function(String verificationId) onAutoRetrievalTimeout,
    int? forceResendingToken,
  }) {
    return _ref.read(authRepositoryProvider).verifyPhoneNumber(
          phoneNumber: phoneNumber,
          onCodeSent: onCodeSent,
          onVerificationFailed: onVerificationFailed,
          onVerificationCompleted: onVerificationCompleted,
          onAutoRetrievalTimeout: onAutoRetrievalTimeout,
          forceResendingToken: forceResendingToken,
        );
  }

  Future<UserCredential> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) {
    return _ref.read(authRepositoryProvider).signInWithPhoneCredential(
          verificationId: verificationId,
          smsCode: smsCode,
        );
  }

  Future<UserCredential> signInWithPhoneAutoCredential(
    PhoneAuthCredential credential,
  ) {
    return _ref
        .read(authRepositoryProvider)
        .signInWithPhoneAutoCredential(credential);
  }
}
