// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispute_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(disputeRepository)
final disputeRepositoryProvider = DisputeRepositoryProvider._();

final class DisputeRepositoryProvider
    extends
        $FunctionalProvider<
          DisputeRepository,
          DisputeRepository,
          DisputeRepository
        >
    with $Provider<DisputeRepository> {
  DisputeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'disputeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$disputeRepositoryHash();

  @$internal
  @override
  $ProviderElement<DisputeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DisputeRepository create(Ref ref) {
    return disputeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DisputeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DisputeRepository>(value),
    );
  }
}

String _$disputeRepositoryHash() => r'9f69ca0c7df8a94cdece024ba7c0f18792ffd72b';
