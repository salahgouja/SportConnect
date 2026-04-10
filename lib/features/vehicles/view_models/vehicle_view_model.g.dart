// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel for vehicle-related operations
/// Manages vehicle CRUD operations, active vehicle selection, and verification

@ProviderFor(VehicleViewModel)
final vehicleViewModelProvider = VehicleViewModelProvider._();

/// ViewModel for vehicle-related operations
/// Manages vehicle CRUD operations, active vehicle selection, and verification
final class VehicleViewModelProvider
    extends $NotifierProvider<VehicleViewModel, VehicleState> {
  /// ViewModel for vehicle-related operations
  /// Manages vehicle CRUD operations, active vehicle selection, and verification
  VehicleViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehicleViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehicleViewModelHash();

  @$internal
  @override
  VehicleViewModel create() => VehicleViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VehicleState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VehicleState>(value),
    );
  }
}

String _$vehicleViewModelHash() => r'135b7c26a4895c74b5c31297bf060234592a4241';

/// ViewModel for vehicle-related operations
/// Manages vehicle CRUD operations, active vehicle selection, and verification

abstract class _$VehicleViewModel extends $Notifier<VehicleState> {
  VehicleState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<VehicleState, VehicleState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VehicleState, VehicleState>,
              VehicleState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
