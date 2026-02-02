// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(callRepository)
final callRepositoryProvider = CallRepositoryProvider._();

final class CallRepositoryProvider
    extends $FunctionalProvider<CallRepository, CallRepository, CallRepository>
    with $Provider<CallRepository> {
  CallRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'callRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$callRepositoryHash();

  @$internal
  @override
  $ProviderElement<CallRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CallRepository create(Ref ref) {
    return callRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CallRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CallRepository>(value),
    );
  }
}

String _$callRepositoryHash() => r'9f3bf9c7be7a001bf177bdd47b0fe8d4d1bb9fcb';
