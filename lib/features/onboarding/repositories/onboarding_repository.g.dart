// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for checking if onboarding is complete

@ProviderFor(isOnboardingComplete)
final isOnboardingCompleteProvider = IsOnboardingCompleteProvider._();

/// Provider for checking if onboarding is complete

final class IsOnboardingCompleteProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider for checking if onboarding is complete
  IsOnboardingCompleteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isOnboardingCompleteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isOnboardingCompleteHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isOnboardingComplete(ref);
  }
}

String _$isOnboardingCompleteHash() =>
    r'8656ef78ce3dcc631862818631e445d3132c7f31';
