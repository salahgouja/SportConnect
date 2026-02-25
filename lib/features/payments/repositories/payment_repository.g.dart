// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Payment Repository Provider

@ProviderFor(paymentRepository)
final paymentRepositoryProvider = PaymentRepositoryProvider._();

/// Payment Repository Provider

final class PaymentRepositoryProvider
    extends
        $FunctionalProvider<
          IPaymentRepository,
          IPaymentRepository,
          IPaymentRepository
        >
    with $Provider<IPaymentRepository> {
  /// Payment Repository Provider
  PaymentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentRepositoryHash();

  @$internal
  @override
  $ProviderElement<IPaymentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IPaymentRepository create(Ref ref) {
    return paymentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IPaymentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IPaymentRepository>(value),
    );
  }
}

String _$paymentRepositoryHash() => r'ac319e20f44eb223505e547c677c3ab483308606';
