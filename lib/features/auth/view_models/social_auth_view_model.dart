import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';

part 'social_auth_view_model.g.dart';

class SocialAuthState {
  const SocialAuthState({
    this.isLoading = false,
    this.error,
    this.completedProvider,
  });
  final bool isLoading;
  final Object? error;
  final String? completedProvider;

  SocialAuthState copyWith({
    bool? isLoading,
    Object? error,
    String? completedProvider,
    bool clearError = false,
    bool clearCompletedProvider = false,
  }) {
    return SocialAuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      completedProvider: clearCompletedProvider
          ? null
          : (completedProvider ?? this.completedProvider),
    );
  }
}

@riverpod
class SocialAuthViewModel extends _$SocialAuthViewModel {
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
      await ref.read(authActionsViewModelProvider.notifier).signInWithGoogle();
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, completedProvider: 'google');
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e);
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
      await ref.read(authActionsViewModelProvider.notifier).signInWithApple();
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, completedProvider: 'apple');
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e);
    }
  }
}
