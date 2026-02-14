// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for location service

@ProviderFor(locationService)
final locationServiceProvider = LocationServiceProvider._();

/// Riverpod provider for location service

final class LocationServiceProvider
    extends
        $FunctionalProvider<
          ILocationService,
          ILocationService,
          ILocationService
        >
    with $Provider<ILocationService> {
  /// Riverpod provider for location service
  LocationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationServiceHash();

  @$internal
  @override
  $ProviderElement<ILocationService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ILocationService create(Ref ref) {
    return locationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ILocationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ILocationService>(value),
    );
  }
}

String _$locationServiceHash() => r'6ca7959dfb24f9332d30de11e503fefab7db998f';
