// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Support Repository Provider

@ProviderFor(supportRepository)
final supportRepositoryProvider = SupportRepositoryProvider._();

/// Support Repository Provider

final class SupportRepositoryProvider
    extends
        $FunctionalProvider<
          ISupportRepository,
          ISupportRepository,
          ISupportRepository
        >
    with $Provider<ISupportRepository> {
  /// Support Repository Provider
  SupportRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supportRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supportRepositoryHash();

  @$internal
  @override
  $ProviderElement<ISupportRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ISupportRepository create(Ref ref) {
    return supportRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ISupportRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ISupportRepository>(value),
    );
  }
}

String _$supportRepositoryHash() => r'edd0c784f7244a5f42e7a9135bf12bcff1cb53c1';
