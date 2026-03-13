import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/providers/repository_providers.dart';
import 'package:sport_connect/core/services/analytics_service.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';

part 'phone_auth_view_model.freezed.dart';
part 'phone_auth_view_model.g.dart';

/// Represents the current state of the phone-OTP flow.
@freezed
sealed class PhoneAuthState with _$PhoneAuthState {
  const PhoneAuthState._();

  /// Initial idle state – the user hasn't started verification yet.
  const factory PhoneAuthState.idle({
    @Default('') String sentPhone,
    @Default(0) int resendCooldown,
  }) = _Idle;

  /// A verification code is being sent.
  const factory PhoneAuthState.sending({
    @Default('') String sentPhone,
    @Default(0) int resendCooldown,
  }) = _Sending;

  /// A code has been sent. Contains the Firebase [verificationId] and
  /// optional [resendToken] for re-sending.
  const factory PhoneAuthState.codeSent({
    required String verificationId,
    int? resendToken,
    required String sentPhone,
    @Default(0) int resendCooldown,
  }) = _CodeSent;

  /// The SMS code is being verified.
  const factory PhoneAuthState.verifying({
    @Default('') String sentPhone,
    @Default(0) int resendCooldown,
  }) = _Verifying;

  /// Verification succeeded.
  const factory PhoneAuthState.verified({
    @Default('') String sentPhone,
    @Default(0) int resendCooldown,
  }) = _Verified;

  /// An error occurred at any stage.
  const factory PhoneAuthState.error(
    String message, {
    @Default('') String sentPhone,
    @Default(0) int resendCooldown,
  }) = _Error;
}

/// ViewModel that manages the phone-OTP verification flow.
///
/// States flow:  idle → sending → codeSent ↔ verifying → verified
///                                    ↘ error ↙
@riverpod
class PhoneAuthViewModel extends _$PhoneAuthViewModel {
  Timer? _cooldownTimer;

  @override
  PhoneAuthState build() {
    ref.onDispose(() => _cooldownTimer?.cancel());
    return const PhoneAuthState.idle();
  }

  void _startResendCooldown() {
    _updateResendCooldown(60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!ref.mounted) {
        _cooldownTimer?.cancel();
        return;
      }
      final nextCooldown = _currentResendCooldown - 1;
      _updateResendCooldown(nextCooldown < 0 ? 0 : nextCooldown);
      if (nextCooldown <= 0) _cooldownTimer?.cancel();
    });
  }

  int get _currentResendCooldown => state.map(
    idle: (value) => value.resendCooldown,
    sending: (value) => value.resendCooldown,
    codeSent: (value) => value.resendCooldown,
    verifying: (value) => value.resendCooldown,
    verified: (value) => value.resendCooldown,
    error: (value) => value.resendCooldown,
  );

  String get _currentSentPhone => state.map(
    idle: (value) => value.sentPhone,
    sending: (value) => value.sentPhone,
    codeSent: (value) => value.sentPhone,
    verifying: (value) => value.sentPhone,
    verified: (value) => value.sentPhone,
    error: (value) => value.sentPhone,
  );

  void _updateResendCooldown(int value) {
    state = state.map(
      idle: (current) => current.copyWith(resendCooldown: value),
      sending: (current) => current.copyWith(resendCooldown: value),
      codeSent: (current) => current.copyWith(resendCooldown: value),
      verifying: (current) => current.copyWith(resendCooldown: value),
      verified: (current) => current.copyWith(resendCooldown: value),
      error: (current) => current.copyWith(resendCooldown: value),
    );
  }

  Future<void> _ensureUserDocument({String? fallbackPhoneNumber}) async {
    final authActions = ref.read(authActionsViewModelProvider);
    final firebaseUser = authActions.currentUser;
    if (firebaseUser == null) return;

    final existingUser = await ref
        .read(authRepositoryProvider)
        .getUserData(firebaseUser.uid);
    if (existingUser != null) {
      return;
    }

    final displayName = (firebaseUser.displayName?.trim().isNotEmpty ?? false)
        ? firebaseUser.displayName!.trim()
        : 'User';

    final user = UserModel.rider(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: displayName,
      phoneNumber: firebaseUser.phoneNumber ?? fallbackPhoneNumber,
      isPhoneVerified: true,
      needsRoleSelection: true,
      createdAt: DateTime.now(),
      lastSeenAt: DateTime.now(),
    );

    await authActions.createUserDocument(user);
  }

  /// Step 1: Send verification SMS to [phoneNumber].
  Future<void> sendCode(String phoneNumber) async {
    final normalizedPhone = phoneNumber.trim();
    if (normalizedPhone.isEmpty) {
      state = const PhoneAuthState.error('Phone number is required');
      return;
    }

    state = PhoneAuthState.sending(sentPhone: normalizedPhone);

    try {
      await ref
          .read(authActionsViewModelProvider)
          .verifyPhoneNumber(
            phoneNumber: phoneNumber,
            onCodeSent: (verificationId, resendToken) {
              state = PhoneAuthState.codeSent(
                verificationId: verificationId,
                resendToken: resendToken,
                sentPhone: normalizedPhone,
              );
              _startResendCooldown();
            },
            onVerificationFailed: (error) {
              state = PhoneAuthState.error(
                error.message ?? 'Verification failed',
                sentPhone: normalizedPhone,
                resendCooldown: _currentResendCooldown,
              );
            },
            onVerificationCompleted: (credential) async {
              // Auto-verified (Android only) — sign in via DI-aware
              // repository method.
              state = PhoneAuthState.verifying(
                sentPhone: normalizedPhone,
                resendCooldown: _currentResendCooldown,
              );
              try {
                await ref
                    .read(authActionsViewModelProvider)
                    .signInWithPhoneAutoCredential(credential);
                await _ensureUserDocument(fallbackPhoneNumber: phoneNumber);
                final uid = ref
                    .read(authActionsViewModelProvider)
                    .currentUser
                    ?.uid;
                if (uid != null) AnalyticsService.instance.setUserId(uid);
                AnalyticsService.instance.logLogin('phone');
                state = PhoneAuthState.verified(sentPhone: normalizedPhone);
              } catch (e) {
                state = PhoneAuthState.error(
                  e.toString(),
                  sentPhone: normalizedPhone,
                  resendCooldown: _currentResendCooldown,
                );
              }
            },
            onAutoRetrievalTimeout: (_) {
              // No-op: the user can still enter the code manually.
            },
          );
    } catch (e) {
      state = PhoneAuthState.error(
        e.toString(),
        sentPhone: normalizedPhone,
        resendCooldown: _currentResendCooldown,
      );
    }
  }

  /// Step 2: Verify the [smsCode] the user entered.
  Future<void> verifyCode(String smsCode, {String? phoneNumber}) async {
    final currentState = state;
    if (currentState is! _CodeSent) return;

    final normalizedCode = smsCode.trim();
    if (normalizedCode.length != 6) {
      state = PhoneAuthState.error(
        'Code must be exactly 6 digits',
        sentPhone: currentState.sentPhone,
        resendCooldown: currentState.resendCooldown,
      );
      return;
    }

    state = PhoneAuthState.verifying(
      sentPhone: currentState.sentPhone,
      resendCooldown: currentState.resendCooldown,
    );

    try {
      await ref
          .read(authActionsViewModelProvider)
          .signInWithPhoneCredential(
            verificationId: currentState.verificationId,
            smsCode: normalizedCode,
          );
      await _ensureUserDocument(fallbackPhoneNumber: phoneNumber);
      final uid = ref.read(authActionsViewModelProvider).currentUser?.uid;
      if (uid != null) AnalyticsService.instance.setUserId(uid);
      AnalyticsService.instance.logLogin('phone');

      state = PhoneAuthState.verified(sentPhone: currentState.sentPhone);
    } on FirebaseAuthException catch (e) {
      state = PhoneAuthState.error(
        e.message ?? 'Verification failed',
        sentPhone: currentState.sentPhone,
        resendCooldown: currentState.resendCooldown,
      );
    } catch (e) {
      state = PhoneAuthState.error(
        e.toString(),
        sentPhone: currentState.sentPhone,
        resendCooldown: currentState.resendCooldown,
      );
    }
  }

  /// Resend the verification code (uses the cached [resendToken]).
  Future<void> resendCode(String phoneNumber) async {
    final currentState = state;
    final resendToken = currentState is _CodeSent
        ? currentState.resendToken
        : null;

    final normalizedPhone = phoneNumber.trim().isEmpty
        ? _currentSentPhone
        : phoneNumber.trim();
    if (normalizedPhone.isEmpty) {
      state = const PhoneAuthState.error('Phone number is required');
      return;
    }

    if (_currentResendCooldown > 0) {
      return;
    }

    state = PhoneAuthState.sending(sentPhone: normalizedPhone);

    try {
      await ref
          .read(authActionsViewModelProvider)
          .verifyPhoneNumber(
            phoneNumber: phoneNumber,
            forceResendingToken: resendToken,
            onCodeSent: (verificationId, newToken) {
              state = PhoneAuthState.codeSent(
                verificationId: verificationId,
                resendToken: newToken,
                sentPhone: normalizedPhone,
              );
              _startResendCooldown();
            },
            onVerificationFailed: (error) {
              state = PhoneAuthState.error(
                error.message ?? 'Verification failed',
                sentPhone: normalizedPhone,
                resendCooldown: _currentResendCooldown,
              );
            },
            onVerificationCompleted: (credential) async {
              // Auto-verified (Android only) — sign in via DI-aware
              // repository method, same as sendCode.
              state = PhoneAuthState.verifying(
                sentPhone: normalizedPhone,
                resendCooldown: _currentResendCooldown,
              );
              try {
                await ref
                    .read(authActionsViewModelProvider)
                    .signInWithPhoneAutoCredential(credential);
                await _ensureUserDocument(fallbackPhoneNumber: phoneNumber);
                final uid = ref
                    .read(authActionsViewModelProvider)
                    .currentUser
                    ?.uid;
                if (uid != null) AnalyticsService.instance.setUserId(uid);
                AnalyticsService.instance.logLogin('phone');
                state = PhoneAuthState.verified(sentPhone: normalizedPhone);
              } catch (e) {
                state = PhoneAuthState.error(
                  e.toString(),
                  sentPhone: normalizedPhone,
                  resendCooldown: _currentResendCooldown,
                );
              }
            },
            onAutoRetrievalTimeout: (_) {},
          );
    } catch (e) {
      state = PhoneAuthState.error(
        e.toString(),
        sentPhone: normalizedPhone,
        resendCooldown: _currentResendCooldown,
      );
    }
  }

  /// Reset to idle state.
  void reset() {
    _cooldownTimer?.cancel();
    state = const PhoneAuthState.idle();
  }
}
