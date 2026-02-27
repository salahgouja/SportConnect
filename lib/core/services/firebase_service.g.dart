// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for Firebase service

@ProviderFor(firebaseService)
final firebaseServiceProvider = FirebaseServiceProvider._();

/// Riverpod provider for Firebase service

final class FirebaseServiceProvider
    extends
        $FunctionalProvider<
          IFirebaseService,
          IFirebaseService,
          IFirebaseService
        >
    with $Provider<IFirebaseService> {
  /// Riverpod provider for Firebase service
  FirebaseServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseServiceHash();

  @$internal
  @override
  $ProviderElement<IFirebaseService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IFirebaseService create(Ref ref) {
    return firebaseService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IFirebaseService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IFirebaseService>(value),
    );
  }
}

String _$firebaseServiceHash() => r'd992ad78be9e141dccaa9ccda194dd220b339177';
