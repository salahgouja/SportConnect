import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/onboarding/models/onboarding_model.dart';
import 'package:sport_connect/features/onboarding/repositories/onboarding_repository.dart';

part 'onboarding_view_model.g.dart';

/// State for the onboarding screen
class OnboardingState {
  final int currentPageIndex;
  final bool isLastPage;
  final bool isCompleting;
  final String? errorMessage;

  const OnboardingState({
    this.currentPageIndex = 0,
    this.isLastPage = false,
    this.isCompleting = false,
    this.errorMessage,
  });

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

  /// Get all onboarding pages
  List<OnboardingPage> get pages => OnboardingPages.pages;

  /// Set current page index
  void setPageIndex(int index) {
    final isLast = index == pages.length - 1;
    state = state.copyWith(currentPageIndex: index, isLastPage: isLast);
  }

  /// Go to next page
  void nextPage() {
    if (state.currentPageIndex < pages.length - 1) {
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
    setPageIndex(pages.length - 1);
  }

  /// Complete onboarding
  Future<bool> completeOnboarding() async {
    state = state.copyWith(isCompleting: true, errorMessage: null);

    try {
      final repository = await ref.read(onboardingRepositoryProvider.future);
      await repository.completeOnboarding();
      state = state.copyWith(isCompleting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isCompleting: false,
        errorMessage: 'Failed to save progress: $e',
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
