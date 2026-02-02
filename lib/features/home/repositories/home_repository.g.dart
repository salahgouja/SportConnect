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
    extends $FunctionalProvider<HomeRepository, HomeRepository, HomeRepository>
    with $Provider<HomeRepository> {
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
  $ProviderElement<HomeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HomeRepository create(Ref ref) {
    return homeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeRepository>(value),
    );
  }
}

String _$homeRepositoryHash() => r'955b1e3d0ff132ee69f8ed919072bb905127acfd';

/// Stream provider for nearby rides

@ProviderFor(nearbyRidesStream)
final nearbyRidesStreamProvider = NearbyRidesStreamFamily._();

/// Stream provider for nearby rides

final class NearbyRidesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NearbyRidePreview>>,
          List<NearbyRidePreview>,
          Stream<List<NearbyRidePreview>>
        >
    with
        $FutureModifier<List<NearbyRidePreview>>,
        $StreamProvider<List<NearbyRidePreview>> {
  /// Stream provider for nearby rides
  NearbyRidesStreamProvider._({
    required NearbyRidesStreamFamily super.from,
    required LatLng super.argument,
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
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<NearbyRidePreview>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<NearbyRidePreview>> create(Ref ref) {
    final argument = this.argument as LatLng;
    return nearbyRidesStream(ref, argument);
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

String _$nearbyRidesStreamHash() => r'ef3529270f65d1cf871b48185ae0f73d3cc22f1d';

/// Stream provider for nearby rides

final class NearbyRidesStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<NearbyRidePreview>>, LatLng> {
  NearbyRidesStreamFamily._()
    : super(
        retry: null,
        name: r'nearbyRidesStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream provider for nearby rides

  NearbyRidesStreamProvider call(LatLng location) =>
      NearbyRidesStreamProvider._(argument: location, from: this);

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
