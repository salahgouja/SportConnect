// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mapService)
final mapServiceProvider = MapServiceProvider._();

final class MapServiceProvider
    extends $FunctionalProvider<MapService, MapService, MapService>
    with $Provider<MapService> {
  MapServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapServiceHash();

  @$internal
  @override
  $ProviderElement<MapService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MapService create(Ref ref) {
    return mapService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapService>(value),
    );
  }
}

String _$mapServiceHash() => r'805ea1eba589838030d09934db5c8803ad6154b3';
