// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_location_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DriverLocationViewModel)
final driverLocationViewModelProvider = DriverLocationViewModelProvider._();

final class DriverLocationViewModelProvider
    extends $NotifierProvider<DriverLocationViewModel, DriverLocationState> {
  DriverLocationViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverLocationViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverLocationViewModelHash();

  @$internal
  @override
  DriverLocationViewModel create() => DriverLocationViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverLocationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverLocationState>(value),
    );
  }
}

String _$driverLocationViewModelHash() =>
    r'f19357c84c34680290ca840fdc2552b5377c54ec';

abstract class _$DriverLocationViewModel
    extends $Notifier<DriverLocationState> {
  DriverLocationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DriverLocationState, DriverLocationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DriverLocationState, DriverLocationState>,
              DriverLocationState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
