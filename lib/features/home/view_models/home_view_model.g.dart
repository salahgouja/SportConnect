// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel for the home screen with full business logic extraction
/// Manages navigation, map state, location tracking, and routing

@ProviderFor(HomeViewModel)
final homeViewModelProvider = HomeViewModelProvider._();

/// ViewModel for the home screen with full business logic extraction
/// Manages navigation, map state, location tracking, and routing
final class HomeViewModelProvider
    extends $NotifierProvider<HomeViewModel, HomeState> {
  /// ViewModel for the home screen with full business logic extraction
  /// Manages navigation, map state, location tracking, and routing
  HomeViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeViewModelHash();

  @$internal
  @override
  HomeViewModel create() => HomeViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeState>(value),
    );
  }
}

String _$homeViewModelHash() => r'c455c0d505164b7ea42117c7261b0d995ed844fb';

/// ViewModel for the home screen with full business logic extraction
/// Manages navigation, map state, location tracking, and routing

abstract class _$HomeViewModel extends $Notifier<HomeState> {
  HomeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HomeState, HomeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeState, HomeState>,
              HomeState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
