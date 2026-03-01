import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_connect/core/providers/repository_providers.dart';

part 'onboarding_repository.g.dart';

/// Repository for onboarding preferences
class OnboardingRepository {
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _lastOnboardingVersionKey = 'last_onboarding_version';
  static const int currentOnboardingVersion = 1;

  final SharedPreferences _prefs;

  OnboardingRepository(this._prefs);

  /// Check if onboarding has been completed
  bool get isOnboardingComplete {
    return _prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  /// Get the last onboarding version the user has seen
  int get lastOnboardingVersion {
    return _prefs.getInt(_lastOnboardingVersionKey) ?? 0;
  }

  /// Check if user needs to see new onboarding content
  bool get needsOnboardingUpdate {
    return lastOnboardingVersion < currentOnboardingVersion;
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    await _prefs.setBool(_onboardingCompleteKey, true);
    await _prefs.setInt(_lastOnboardingVersionKey, currentOnboardingVersion);
  }

  /// Reset onboarding (for testing or re-showing)
  Future<void> resetOnboarding() async {
    await _prefs.setBool(_onboardingCompleteKey, false);
  }
}

/// Provider for checking if onboarding is complete
@riverpod
Future<bool> isOnboardingComplete(Ref ref) async {
  final repository = await ref.watch(onboardingRepositoryProvider.future);
  return repository.isOnboardingComplete;
}
