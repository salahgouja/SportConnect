// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routing_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(routingService)
final routingServiceProvider = RoutingServiceProvider._();

final class RoutingServiceProvider
    extends $FunctionalProvider<RoutingService, RoutingService, RoutingService>
    with $Provider<RoutingService> {
  RoutingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routingServiceHash();

  @$internal
  @override
  $ProviderElement<RoutingService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RoutingService create(Ref ref) {
    return routingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoutingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoutingService>(value),
    );
  }
}

String _$routingServiceHash() => r'fcd5d18f8e1cc3aa50bcafac9f47f7ef208081d4';
