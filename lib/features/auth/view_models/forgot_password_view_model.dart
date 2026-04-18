import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';

part 'forgot_password_view_model.g.dart';

/// State for the forgot-password screen.
class ForgotPasswordState {
  const ForgotPasswordState({
    this.isLoading = false,
    this.emailSent = false,
    this.resendCooldown = 0,
    this.sentEmail = '',
    this.errorMessage,
  });
  final bool isLoading;
  final bool emailSent;
  final int resendCooldown;
  final String sentEmail;
  final String? errorMessage;

  ForgotPasswordState copyWith({
    bool? isLoading,
    bool? emailSent,
    int? resendCooldown,
    String? sentEmail,
    String? errorMessage,
    bool clearError = false,
  }) => ForgotPasswordState(
    isLoading: isLoading ?? this.isLoading,
    emailSent: emailSent ?? this.emailSent,
    resendCooldown: resendCooldown ?? this.resendCooldown,
    sentEmail: sentEmail ?? this.sentEmail,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}

@riverpod
class ForgotPasswordViewModel extends _$ForgotPasswordViewModel {
  Timer? _cooldownTimer;

  @override
  ForgotPasswordState build() {
    ref.onDispose(() => _cooldownTimer?.cancel());
    return const ForgotPasswordState();
  }

  Future<void> sendResetEmail(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await ref
          .read(authActionsViewModelProvider)
          .sendPasswordResetEmail(email);
      if (!ref.mounted) return;

      state = state.copyWith(
        emailSent: true,
        isLoading: false,
        resendCooldown: 60,
        sentEmail: email,
      );
      _startCooldown();
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
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
