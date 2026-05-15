// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_offer_ride_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DriverOfferRideViewModel)
final driverOfferRideViewModelProvider = DriverOfferRideViewModelProvider._();

final class DriverOfferRideViewModelProvider
    extends
        $NotifierProvider<DriverOfferRideViewModel, DriverOfferRideFormState> {
  DriverOfferRideViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverOfferRideViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverOfferRideViewModelHash();

  @$internal
  @override
  DriverOfferRideViewModel create() => DriverOfferRideViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverOfferRideFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverOfferRideFormState>(value),
    );
  }
}

String _$driverOfferRideViewModelHash() =>
    r'cbf84d2154b72584ca5cec3a022211a64788a11c';

abstract class _$DriverOfferRideViewModel
    extends $Notifier<DriverOfferRideFormState> {
  DriverOfferRideFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<DriverOfferRideFormState, DriverOfferRideFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DriverOfferRideFormState, DriverOfferRideFormState>,
              DriverOfferRideFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
