// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Firestore instance provider
///
/// Provides the single source of truth for Firestore instance.
/// This enables easy mocking in tests and switching implementations.

@ProviderFor(firestoreInstance)
final firestoreInstanceProvider = FirestoreInstanceProvider._();

/// Firestore instance provider
///
/// Provides the single source of truth for Firestore instance.
/// This enables easy mocking in tests and switching implementations.

final class FirestoreInstanceProvider
    extends
        $FunctionalProvider<
          FirebaseFirestore,
          FirebaseFirestore,
          FirebaseFirestore
        >
    with $Provider<FirebaseFirestore> {
  /// Firestore instance provider
  ///
  /// Provides the single source of truth for Firestore instance.
  /// This enables easy mocking in tests and switching implementations.
  FirestoreInstanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firestoreInstanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firestoreInstanceHash();

  @$internal
  @override
  $ProviderElement<FirebaseFirestore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseFirestore create(Ref ref) {
    return firestoreInstance(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseFirestore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseFirestore>(value),
    );
  }
}

String _$firestoreInstanceHash() => r'0f2e17bd314d9ddd815f276c6b7b295c892bca8a';

/// Storage instance provider
///
/// Provides the single source of truth for Firebase Storage instance.

@ProviderFor(storageInstance)
final storageInstanceProvider = StorageInstanceProvider._();

/// Storage instance provider
///
/// Provides the single source of truth for Firebase Storage instance.

final class StorageInstanceProvider
    extends
        $FunctionalProvider<FirebaseStorage, FirebaseStorage, FirebaseStorage>
    with $Provider<FirebaseStorage> {
  /// Storage instance provider
  ///
  /// Provides the single source of truth for Firebase Storage instance.
  StorageInstanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageInstanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageInstanceHash();

  @$internal
  @override
  $ProviderElement<FirebaseStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirebaseStorage create(Ref ref) {
    return storageInstance(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseStorage>(value),
    );
  }
}

String _$storageInstanceHash() => r'a3f65dcd998c34f5f0b3b3068eba7ce2aa4c7555';
