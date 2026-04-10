// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel for all driver dashboard screens.

@ProviderFor(DriverViewModel)
final driverViewModelProvider = DriverViewModelProvider._();

/// ViewModel for all driver dashboard screens.
final class DriverViewModelProvider
    extends $NotifierProvider<DriverViewModel, DriverState> {
  /// ViewModel for all driver dashboard screens.
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

String _$driverViewModelHash() => r'a1a4438118bbe45ddc2ad4a4a072d79743865483';

/// ViewModel for all driver dashboard screens.

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
