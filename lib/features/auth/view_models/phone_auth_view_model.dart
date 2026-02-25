import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/services/analytics_service.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';

part 'phone_auth_view_model.freezed.dart';
part 'phone_auth_view_model.g.dart';

/// Represents the current state of the phone-OTP flow.
@freezed
class PhoneAuthState with _$PhoneAuthState {
  /// Initial idle state – the user hasn't started verification yet.
  const factory PhoneAuthState.idle() = _Idle;

  /// A verification code is being sent.
  const factory PhoneAuthState.sending() = _Sending;

  /// A code has been sent. Contains the Firebase [verificationId] and
  /// optional [resendToken] for re-sending.
  const factory PhoneAuthState.codeSent({
    required String verificationId,
    int? resendToken,
  }) = _CodeSent;

  /// The SMS code is being verified.
  const factory PhoneAuthState.verifying() = _Verifying;

  /// Verification succeeded.
  const factory PhoneAuthState.verified() = _Verified;

  /// An error occurred at any stage.
  const factory PhoneAuthState.error(String message) = _Error;
}

/// ViewModel that manages the phone-OTP verification flow.
///
/// States flow:  idle → sending → codeSent ↔ verifying → verified
///                                    ↘ error ↙
@riverpod
class PhoneAuthViewModel extends _$PhoneAuthViewModel {
  @override
  PhoneAuthState build() => const PhoneAuthState.idle();

  /// Step 1: Send verification SMS to [phoneNumber].
  Future<void> sendCode(String phoneNumber) async {
    state = const PhoneAuthState.sending();

    try {
      await ref.read(authActionsViewModelProvider).verifyPhoneNumber(
            phoneNumber: phoneNumber,
            onCodeSent: (verificationId, resendToken) {
              state = PhoneAuthState.codeSent(
                verificationId: verificationId,
                resendToken: resendToken,
              );
            },
            onVerificationFailed: (error) {
              state = PhoneAuthState.error(
                error.message ?? 'Verification failed',
              );
            },
            onVerificationCompleted: (credential) async {
              // Auto-verified (Android only) — sign in via DI-aware
              // repository method.
              state = const PhoneAuthState.verifying();
              try {
                await ref
                    .read(authActionsViewModelProvider)
                    .signInWithPhoneAutoCredential(credential);
                final uid =
                    ref.read(authActionsViewModelProvider).currentUser?.uid;
                if (uid != null) AnalyticsService.instance.setUserId(uid);
                AnalyticsService.instance.logLogin('phone');
                state = const PhoneAuthState.verified();
              } catch (e) {
                state = PhoneAuthState.error(e.toString());
              }
            },
            onAutoRetrievalTimeout: (_) {
              // No-op: the user can still enter the code manually.
            },
          );
    } catch (e) {
      state = PhoneAuthState.error(e.toString());
    }
  }

  /// Step 2: Verify the [smsCode] the user entered.
  Future<void> verifyCode(String smsCode) async {
    final currentState = state;
    if (currentState is! _CodeSent) return;

    state = const PhoneAuthState.verifying();

    try {
      await ref.read(authActionsViewModelProvider).signInWithPhoneCredential(
            verificationId: currentState.verificationId,
            smsCode: smsCode,
          );
      final uid = ref.read(authActionsViewModelProvider).currentUser?.uid;
      if (uid != null) AnalyticsService.instance.setUserId(uid);
      AnalyticsService.instance.logLogin('phone');

      state = const PhoneAuthState.verified();
    } on FirebaseAuthException catch (e) {
      state = PhoneAuthState.error(e.message ?? 'Verification failed');
    } catch (e) {
      state = PhoneAuthState.error(e.toString());
    }
  }

  /// Resend the verification code (uses the cached [resendToken]).
  Future<void> resendCode(String phoneNumber) async {
    final currentState = state;
    final resendToken = currentState is _CodeSent
        ? currentState.resendToken
        : null;

    state = const PhoneAuthState.sending();

    try {
      await ref.read(authActionsViewModelProvider).verifyPhoneNumber(
            phoneNumber: phoneNumber,
            forceResendingToken: resendToken,
            onCodeSent: (verificationId, newToken) {
              state = PhoneAuthState.codeSent(
                verificationId: verificationId,
                resendToken: newToken,
              );
            },
            onVerificationFailed: (error) {
              state = PhoneAuthState.error(
                error.message ?? 'Verification failed',
              );
            },
            onVerificationCompleted: (credential) async {
              // Auto-verified (Android only) — sign in via DI-aware
              // repository method, same as sendCode.
              state = const PhoneAuthState.verifying();
              try {
                await ref
                    .read(authActionsViewModelProvider)
                    .signInWithPhoneAutoCredential(credential);
                final uid =
                    ref.read(authActionsViewModelProvider).currentUser?.uid;
                if (uid != null) AnalyticsService.instance.setUserId(uid);
                AnalyticsService.instance.logLogin('phone');
                state = const PhoneAuthState.verified();
              } catch (e) {
                state = PhoneAuthState.error(e.toString());
              }
            },
            onAutoRetrievalTimeout: (_) {},
          );
    } catch (e) {
      state = PhoneAuthState.error(e.toString());
    }
  }

  /// Reset to idle state.
  void reset() => state = const PhoneAuthState.idle();
}
