// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel for driver-related operations
/// Manages driver online status, ride requests, and dashboard state

@ProviderFor(DriverViewModel)
final driverViewModelProvider = DriverViewModelProvider._();

/// ViewModel for driver-related operations
/// Manages driver online status, ride requests, and dashboard state
final class DriverViewModelProvider
    extends $NotifierProvider<DriverViewModel, DriverState> {
  /// ViewModel for driver-related operations
  /// Manages driver online status, ride requests, and dashboard state
  DriverViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverViewModelHash();

  @$internal
  @override
  DriverViewModel create() => DriverViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverState>(value),
    );
  }
}

String _$driverViewModelHash() => r'27e00342a3f0dab2075aa7e78c0fa4b7e4914a1e';

/// ViewModel for driver-related operations
/// Manages driver online status, ride requests, and dashboard state

abstract class _$DriverViewModel extends $Notifier<DriverState> {
  DriverState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DriverState, DriverState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DriverState, DriverState>,
              DriverState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for the current driver tab index

@ProviderFor(DriverTabIndex)
final driverTabIndexProvider = DriverTabIndexProvider._();

/// Provider for the current driver tab index
final class DriverTabIndexProvider
    extends $NotifierProvider<DriverTabIndex, int> {
  /// Provider for the current driver tab index
  DriverTabIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverTabIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverTabIndexHash();

  @$internal
  @override
  DriverTabIndex create() => DriverTabIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$driverTabIndexHash() => r'324335a15f3fa81dc8bb20e00ad2cd30370b0070';

/// Provider for the current driver tab index

abstract class _$DriverTabIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
