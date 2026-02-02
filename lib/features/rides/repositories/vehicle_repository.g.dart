// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(vehicleRepository)
final vehicleRepositoryProvider = VehicleRepositoryProvider._();

final class VehicleRepositoryProvider
    extends
        $FunctionalProvider<
          VehicleRepository,
          VehicleRepository,
          VehicleRepository
        >
    with $Provider<VehicleRepository> {
  VehicleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehicleRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehicleRepositoryHash();

  @$internal
  @override
  $ProviderElement<VehicleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VehicleRepository create(Ref ref) {
    return vehicleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VehicleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VehicleRepository>(value),
    );
  }
}

String _$vehicleRepositoryHash() => r'a4ec7e2d102e5cbec7817db13341bdb7303c331f';

/// Provider for streaming user vehicles

@ProviderFor(userVehiclesStream)
final userVehiclesStreamProvider = UserVehiclesStreamFamily._();

/// Provider for streaming user vehicles

final class UserVehiclesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VehicleModel>>,
          List<VehicleModel>,
          Stream<List<VehicleModel>>
        >
    with
        $FutureModifier<List<VehicleModel>>,
        $StreamProvider<List<VehicleModel>> {
  /// Provider for streaming user vehicles
  UserVehiclesStreamProvider._({
    required UserVehiclesStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userVehiclesStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userVehiclesStreamHash();

  @override
  String toString() {
    return r'userVehiclesStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<VehicleModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<VehicleModel>> create(Ref ref) {
    final argument = this.argument as String;
    return userVehiclesStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserVehiclesStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userVehiclesStreamHash() =>
    r'2e1cbbe73db8370234dda5491eced03308fbbd25';

/// Provider for streaming user vehicles

final class UserVehiclesStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<VehicleModel>>, String> {
  UserVehiclesStreamFamily._()
    : super(
        retry: null,
        name: r'userVehiclesStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for streaming user vehicles

  UserVehiclesStreamProvider call(String userId) =>
      UserVehiclesStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'userVehiclesStreamProvider';
}

/// Provider for streaming active vehicle

@ProviderFor(activeVehicleStream)
final activeVehicleStreamProvider = ActiveVehicleStreamFamily._();

/// Provider for streaming active vehicle

final class ActiveVehicleStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<VehicleModel?>,
          VehicleModel?,
          Stream<VehicleModel?>
        >
    with $FutureModifier<VehicleModel?>, $StreamProvider<VehicleModel?> {
  /// Provider for streaming active vehicle
  ActiveVehicleStreamProvider._({
    required ActiveVehicleStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activeVehicleStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeVehicleStreamHash();

  @override
  String toString() {
    return r'activeVehicleStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<VehicleModel?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<VehicleModel?> create(Ref ref) {
    final argument = this.argument as String;
    return activeVehicleStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveVehicleStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeVehicleStreamHash() =>
    r'fd135bae464bea4c1067faa06d817cb33b322363';

/// Provider for streaming active vehicle

final class ActiveVehicleStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<VehicleModel?>, String> {
  ActiveVehicleStreamFamily._()
    : super(
        retry: null,
        name: r'activeVehicleStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for streaming active vehicle

  ActiveVehicleStreamProvider call(String userId) =>
      ActiveVehicleStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'activeVehicleStreamProvider';
}
