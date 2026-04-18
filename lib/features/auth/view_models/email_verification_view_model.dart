import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';

part 'email_verification_view_model.g.dart';

/// State for the email verification screen.
///
/// All timer and polling logic lives here so the widget
/// never needs `if (mounted)` checks.
class EmailVerificationState {
  const EmailVerificationState({
    this.isEmailVerified = false,
    this.isSending = false,
    this.resendCooldown = 0,
    this.userEmail = '',
    this.errorMessage,
  });
  final bool isEmailVerified;
  final bool isSending;
  final int resendCooldown;
  final String userEmail;
  final String? errorMessage;

  EmailVerificationState copyWith({
    bool? isEmailVerified,
    bool? isSending,
    int? resendCooldown,
    String? userEmail,
    String? errorMessage,
    bool clearError = false,
  }) => EmailVerificationState(
    isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    isSending: isSending ?? this.isSending,
    resendCooldown: resendCooldown ?? this.resendCooldown,
    userEmail: userEmail ?? this.userEmail,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}

@riverpod
class EmailVerificationViewModel extends _$EmailVerificationViewModel {
  Timer? _pollTimer;
  Timer? _cooldownTimer;

  @override
  EmailVerificationState build() {
    ref.onDispose(() {
      _pollTimer?.cancel();
      _cooldownTimer?.cancel();
    });

    // Start polling immediately.
    _startPolling();

    final userEmail =
        ref.read(authActionsViewModelProvider).currentUser?.email ?? '';
    return EmailVerificationState(userEmail: userEmail);
  }

  // ── Polling ──────────────────────────────────────────────────────────

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => checkEmailVerified(),
    );
  }

  Future<void> checkEmailVerified() async {
    if (!ref.mounted) return;

    try {
      final authActions = ref.read(authActionsViewModelProvider);
      final user = authActions.currentUser;
      if (user == null) return;

      await authActions.reloadUser();
      if (!ref.mounted) return;

      final verified = await authActions.isEmailVerified();
      if (!ref.mounted) return;

      if (verified) {
        _pollTimer?.cancel();
        state = state.copyWith(isEmailVerified: true);

        // Small grace period so the UI can show the verified animation
        // before the auth state change triggers navigation.
        await Future<void>.delayed(const Duration(seconds: 2));
        if (!ref.mounted) return;

        ref.invalidate(authStateProvider);
      }
    } on Exception catch (e) {
      TalkerService.debug('Email verification poll error: $e');
    }
  }

  // ── Resend ──────────────────────────────────────────────────────────

  Future<void> resendVerification() async {
    if (state.resendCooldown > 0 || state.isSending) return;

    state = state.copyWith(isSending: true);

    try {
      await ref.read(authActionsViewModelProvider).sendEmailVerification();
      if (!ref.mounted) return;

      state = state.copyWith(
        isSending: false,
        resendCooldown: 60,
        clearError: true,
      );
      _startCooldown();
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isSending: false, errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    await ref.read(authActionsViewModelProvider).signOut();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!ref.mounted) {
        _cooldownTimer?.cancel();
        return;
      }
      final next = state.resendCooldown - 1;
      state = state.copyWith(resendCooldown: next);
      if (next <= 0) _cooldownTimer?.cancel();
    });
  }
}
