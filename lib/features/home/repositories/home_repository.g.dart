// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for HomeRepository

@ProviderFor(homeRepository)
final homeRepositoryProvider = HomeRepositoryProvider._();

/// Provider for HomeRepository

final class HomeRepositoryProvider
    extends
        $FunctionalProvider<IHomeRepository, IHomeRepository, IHomeRepository>
    with $Provider<IHomeRepository> {
  /// Provider for HomeRepository
  HomeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeRepositoryHash();

  @$internal
  @override
  $ProviderElement<IHomeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IHomeRepository create(Ref ref) {
    return homeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IHomeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IHomeRepository>(value),
    );
  }
}

String _$homeRepositoryHash() => r'f491d9e14f8df40bdd03313ea2e582f4f030819f';

/// Stream provider for nearby rides

@ProviderFor(nearbyRidesStream)
final nearbyRidesStreamProvider = NearbyRidesStreamFamily._();

/// Stream provider for nearby rides

final class NearbyRidesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideModel>>,
          List<RideModel>,
          Stream<List<RideModel>>
        >
    with $FutureModifier<List<RideModel>>, $StreamProvider<List<RideModel>> {
  /// Stream provider for nearby rides
  NearbyRidesStreamProvider._({
    required NearbyRidesStreamFamily super.from,
    required (LatLng, double) super.argument,
  }) : super(
         retry: null,
         name: r'nearbyRidesStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nearbyRidesStreamHash();

  @override
  String toString() {
    return r'nearbyRidesStreamProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<RideModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideModel>> create(Ref ref) {
    final argument = this.argument as (LatLng, double);
    return nearbyRidesStream(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is NearbyRidesStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nearbyRidesStreamHash() => r'fb1810db342e59fa54c98cffc6ebf28e4fdd6644';

/// Stream provider for nearby rides

final class NearbyRidesStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RideModel>>, (LatLng, double)> {
  NearbyRidesStreamFamily._()
    : super(
        retry: null,
        name: r'nearbyRidesStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream provider for nearby rides

  NearbyRidesStreamProvider call(LatLng location, double radiusKm) =>
      NearbyRidesStreamProvider._(argument: (location, radiusKm), from: this);

  @override
  String toString() => r'nearbyRidesStreamProvider';
}

/// Stream provider for hotspots

@ProviderFor(hotspotsStream)
final hotspotsStreamProvider = HotspotsStreamProvider._();

/// Stream provider for hotspots

final class HotspotsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Hotspot>>,
          List<Hotspot>,
          Stream<List<Hotspot>>
        >
    with $FutureModifier<List<Hotspot>>, $StreamProvider<List<Hotspot>> {
  /// Stream provider for hotspots
  HotspotsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hotspotsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hotspotsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Hotspot>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Hotspot>> create(Ref ref) {
    return hotspotsStream(ref);
  }
}

String _$hotspotsStreamHash() => r'862504d1ce7d996e99f1bc732ed504e0b4a1bb37';
