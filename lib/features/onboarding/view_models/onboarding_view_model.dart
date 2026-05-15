import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/onboarding/models/onboarding_model.dart';
import 'package:sport_connect/features/onboarding/repositories/onboarding_repository.dart';

part 'onboarding_view_model.g.dart';

/// State for the onboarding screen
class OnboardingState {
  const OnboardingState({
    this.currentPageIndex = 0,
    this.isLastPage = false,
    this.isCompleting = false,
    this.errorMessage,
  });
  final int currentPageIndex;
  final bool isLastPage;
  final bool isCompleting;
  final String? errorMessage;

  OnboardingState copyWith({
    int? currentPageIndex,
    bool? isLastPage,
    bool? isCompleting,
    String? errorMessage,
  }) {
    return OnboardingState(
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      isLastPage: isLastPage ?? this.isLastPage,
      isCompleting: isCompleting ?? this.isCompleting,
      errorMessage: errorMessage,
    );
  }
}

/// ViewModel for the onboarding screen
@riverpod
class OnboardingViewModel extends _$OnboardingViewModel {
  @override
  OnboardingState build() {
    return const OnboardingState();
  }

  /// Set current page index
  void setPageIndex(int index) {
    final isLast = index == onboardingPageCount - 1;
    state = state.copyWith(currentPageIndex: index, isLastPage: isLast);
  }

  /// Go to next page
  void nextPage() {
    if (state.currentPageIndex < onboardingPageCount - 1) {
      setPageIndex(state.currentPageIndex + 1);
    }
  }

  /// Go to previous page
  void previousPage() {
    if (state.currentPageIndex > 0) {
      setPageIndex(state.currentPageIndex - 1);
    }
  }

  /// Skip to last page
  void skipToEnd() {
    setPageIndex(onboardingPageCount - 1);
  }

  /// Complete onboarding
  Future<bool> completeOnboarding() async {
    state = state.copyWith(isCompleting: true);

    try {
      final repository = await ref.read(onboardingRepositoryProvider.future);
      if (!ref.mounted) return false;
      await repository.completeOnboarding();
      if (!ref.mounted) return false;
      // Invalidating isOnboardingCompleteProvider triggers router navigation,
      // which disposes this provider. Guard subsequent state writes with
      // ref.mounted so we don't crash after disposal.
      ref.invalidate(isOnboardingCompleteProvider);
      if (!ref.mounted) return true;
      state = state.copyWith(isCompleting: false);
      return true;
    } on Exception catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isCompleting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith();
  }
}
