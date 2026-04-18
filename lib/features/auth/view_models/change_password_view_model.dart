import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/auth/models/auth_exception.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';

part 'change_password_view_model.g.dart';

class ChangePasswordState {
  const ChangePasswordState({
    this.isLoading = false,
    this.isSuccess = false,
    this.requiresReauth = false,
    this.errorMessage,
    this.obscureNewPassword = true,
    this.obscureConfirmPassword = true,
  });
  final bool isLoading;
  final bool isSuccess;
  final bool requiresReauth;
  final String? errorMessage;
  final bool obscureNewPassword;
  final bool obscureConfirmPassword;

  ChangePasswordState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? requiresReauth,
    String? errorMessage,
    bool? obscureNewPassword,
    bool? obscureConfirmPassword,
    bool clearError = false,
  }) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      requiresReauth: requiresReauth ?? this.requiresReauth,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      obscureNewPassword: obscureNewPassword ?? this.obscureNewPassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
    );
  }
}

@riverpod
class ChangePasswordViewModel extends _$ChangePasswordViewModel {
  String? _pendingPassword;

  @override
  ChangePasswordState build() => const ChangePasswordState();

  Future<void> submit(String newPassword) async {
    _pendingPassword = newPassword;
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      requiresReauth: false,
      clearError: true,
    );

    try {
      await ref.read(authActionsViewModelProvider).updatePassword(newPassword);
      state = state.copyWith(isLoading: false, isSuccess: true);
      _pendingPassword = null;
    } on Exception catch (e) {
      if (e is AuthException && e.code == 'requires-recent-login') {
        state = state.copyWith(isLoading: false, requiresReauth: true);
        return;
      }

      final errorMessage = e is AuthException && e.code == 'weak-password'
          ? 'weak-password'
          : 'generic';
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }

  Future<void> retryAfterReauth() async {
    final pendingPassword = _pendingPassword;
    if (pendingPassword == null || state.isLoading) return;
    state = state.copyWith(requiresReauth: false, clearError: true);
    await submit(pendingPassword);
  }

  void dismissReauthRequest() {
    state = state.copyWith(requiresReauth: false);
  }

  void toggleNewPasswordVisibility() {
    state = state.copyWith(obscureNewPassword: !state.obscureNewPassword);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      obscureConfirmPassword: !state.obscureConfirmPassword,
    );
  }
}
