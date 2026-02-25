// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stripe_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for StripeService singleton

@ProviderFor(stripeService)
final stripeServiceProvider = StripeServiceProvider._();

/// Riverpod provider for StripeService singleton

final class StripeServiceProvider
    extends $FunctionalProvider<StripeService, StripeService, StripeService>
    with $Provider<StripeService> {
  /// Riverpod provider for StripeService singleton
  StripeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stripeServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stripeServiceHash();

  @$internal
  @override
  $ProviderElement<StripeService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StripeService create(Ref ref) {
    return stripeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StripeService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StripeService>(value),
    );
  }
}

String _$stripeServiceHash() => r'dd9f308310e599033eee7e5301f3194c1afbf378';
