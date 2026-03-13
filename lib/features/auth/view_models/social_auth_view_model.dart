import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';

class SocialAuthState {
  final bool isLoading;
  final String? errorMessage;
  final String? completedProvider;

  const SocialAuthState({
    this.isLoading = false,
    this.errorMessage,
    this.completedProvider,
  });

  SocialAuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? completedProvider,
    bool clearError = false,
    bool clearCompletedProvider = false,
  }) {
    return SocialAuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      completedProvider: clearCompletedProvider
          ? null
          : (completedProvider ?? this.completedProvider),
    );
  }
}

class SocialAuthViewModel extends Notifier<SocialAuthState> {
  @override
  SocialAuthState build() => const SocialAuthState();

  Future<void> signInWithGoogle() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearCompletedProvider: true,
    );

    try {
      await ref.read(authActionsViewModelProvider).signInWithGoogle();
      state = state.copyWith(isLoading: false, completedProvider: 'google');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signInWithApple() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearCompletedProvider: true,
    );

    try {
      await ref.read(authActionsViewModelProvider).signInWithApple();
      state = state.copyWith(isLoading: false, completedProvider: 'apple');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final socialAuthViewModelProvider =
    NotifierProvider<SocialAuthViewModel, SocialAuthState>(
      SocialAuthViewModel.new,
    );
