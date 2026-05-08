import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/utils/user_facing_error.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';

part 'email_verification_view_model.g.dart';

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
  }) {
    return EmailVerificationState(
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isSending: isSending ?? this.isSending,
      resendCooldown: resendCooldown ?? this.resendCooldown,
      userEmail: userEmail ?? this.userEmail,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@riverpod
class EmailVerificationViewModel extends _$EmailVerificationViewModel {
  Timer? _pollTimer;
  Timer? _cooldownTimer;
  var _isCheckingVerification = false;

  @override
  EmailVerificationState build() {
    ref.onDispose(_cancelTimers);

    final userEmail =
        ref.read(authActionsViewModelProvider.notifier).currentUser?.email ??
        '';

    _startPolling();

    scheduleMicrotask(() {
      if (ref.mounted) {
        unawaited(checkEmailVerified());
      }
    });

    return EmailVerificationState(userEmail: userEmail);
  }

  void _cancelTimers() {
    _pollTimer?.cancel();
    _pollTimer = null;

    _cooldownTimer?.cancel();
    _cooldownTimer = null;
  }

  void _startPolling() {
    _pollTimer?.cancel();

    _pollTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => unawaited(checkEmailVerified()),
    );
  }

  Future<void> checkEmailVerified({bool showErrors = false}) async {
    if (_isCheckingVerification || !ref.mounted) return;

    _isCheckingVerification = true;

    try {
      final authActions = ref.read(authActionsViewModelProvider.notifier);
      final user = authActions.currentUser;

      if (user == null) return;

      await authActions.reloadUser();
      if (!ref.mounted) return;

      final verified = await authActions.isEmailVerified();
      if (!ref.mounted || !verified) return;

      _pollTimer?.cancel();
      _pollTimer = null;

      ref.invalidate(authStateProvider);

      state = state.copyWith(
        isEmailVerified: true,
        clearError: true,
      );
    } on Exception catch (e, st) {
      TalkerService.debug('Email verification check error: $e\n$st');

      if (showErrors && ref.mounted) {
        state = state.copyWith(errorMessage: userFacingError(e));
      }
    } finally {
      _isCheckingVerification = false;
    }
  }

  Future<void> resendVerification() async {
    if (state.resendCooldown > 0 || state.isSending) return;

    state = state.copyWith(
      isSending: true,
      clearError: true,
    );

    try {
      await ref
          .read(authActionsViewModelProvider.notifier)
          .sendEmailVerification();

      if (!ref.mounted) return;

      state = state.copyWith(
        isSending: false,
        resendCooldown: 60,
        clearError: true,
      );

      _startCooldown();
    } on Exception catch (e, st) {
      TalkerService.debug('Email verification resend error: $e\n$st');

      if (!ref.mounted) return;

      state = state.copyWith(
        isSending: false,
        errorMessage: userFacingError(e),
      );
    }
  }

  Future<void> signOut() {
    _cancelTimers();
    return ref.read(authActionsViewModelProvider.notifier).signOut();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!ref.mounted) {
        _cooldownTimer?.cancel();
        _cooldownTimer = null;
        return;
      }

      final nextCooldown = state.resendCooldown - 1;
      final safeCooldown = nextCooldown < 0 ? 0 : nextCooldown;

      state = state.copyWith(resendCooldown: safeCooldown);

      if (safeCooldown == 0) {
        _cooldownTimer?.cancel();
        _cooldownTimer = null;
      }
    });
  }
}
